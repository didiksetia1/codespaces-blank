import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Token-based auth helper for Laravel Sanctum/API.
///
/// This version is intended for Flutter APK/mobile apps:
/// - POST /api/login -> returns token + user
/// - POST /api/register -> may return token + user
/// - GET /api/user -> protected with Bearer token
/// - POST /api/logout -> revokes token
class SanctumAuthService {
  static const String _tokenKey = 'auth_token';
  static const String apiBaseUrl =
  'http://202.10.44.249';

  final String baseUrl;
  final http.Client _client;

  SanctumAuthService(this.baseUrl) : _client = http.Client();

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<String?> token() async {
    final prefs = await _prefs;
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String value) async {
    final prefs = await _prefs;
    await prefs.setString(_tokenKey, value);
  }

  Future<void> clearToken() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
  }

  Future<Map<String, String>> _jsonHeaders({bool auth = false}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (auth) {
      final savedToken = await token();
      if (savedToken != null && savedToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $savedToken';
      }
    }

    return headers;
  }

  String _decodeMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String && message.isNotEmpty) return message;

        final errors = data['errors'];
        if (errors is Map<String, dynamic>) {
          final firstKey = errors.keys.isNotEmpty ? errors.keys.first : null;
          if (firstKey != null) {
            final firstError = errors[firstKey];
            if (firstError is List && firstError.isNotEmpty) {
              final firstItem = firstError.first;
              if (firstItem is String && firstItem.isNotEmpty) return firstItem;
            }
          }
        }
      }
    } catch (_) {
      // Ignore parse errors and fall back to raw body/status.
    }

    final trimmed = response.body.trim();
    if (trimmed.isNotEmpty) return trimmed;
    return 'HTTP ${response.statusCode}';
  }

  Future<http.Response> _get(String path, {bool auth = false}) async {
    return _client.get(_uri(path), headers: await _jsonHeaders(auth: auth));
  }

  Future<http.Response> _post(
    String path,
    Map<String, dynamic> payload, {
    bool auth = false,
  }) async {
    return _client.post(
      _uri(path),
      headers: await _jsonHeaders(auth: auth),
      body: jsonEncode(payload),
    );
  }

  Future<bool> _storeTokenFromResponse(http.Response response) async {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_decodeMessage(response));
    }

    try {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        final tokenValue = data['token'];
        if (tokenValue is String && tokenValue.isNotEmpty) {
          await saveToken(tokenValue);
        }
      }
      return true;
    } catch (e) {
      throw Exception('Response JSON tidak valid: $e');
    }
  }

  Future<bool> login(String nim, String password) async {
    try {
      final response = await _post('/api/login', {
        'nim': nim,
        'password': password,
      });
      return await _storeTokenFromResponse(response);
    } catch (e) {
      // ignore: avoid_print
      print('Login failed: $e');
      return false;
    }
  }

  Future<bool> register({
    required String nim,
    required String name,
    required String password,
    String? faculty,
    String? program,
  }) async {
    try {
      final response = await _post('/api/register', {
        'nama': name,
        'nim': nim,
        'jurusan': faculty ?? '',
        'prodi': program ?? '',
        'password': password,
      });

      final success = await _storeTokenFromResponse(response);
      return success;
    } catch (e) {
      // ignore: avoid_print
      print('Register failed: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchUser() async {
    try {
      final response = await _get('/api/user', auth: true);
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Fetch user failed: $e');
    }
    return null;
  }

  Future<bool> logout() async {
    try {
      final response = await _post('/api/logout', {}, auth: true);
      final ok = response.statusCode >= 200 && response.statusCode < 300;
      if (ok) {
        await clearToken();
      }
      return ok;
    } catch (e) {
      // Clear local token even if revoke failed on server.
      await clearToken();
      // ignore: avoid_print
      print('Logout failed: $e');
      return false;
    }
  }
}
