import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service_sanctum.dart';

class AduanService {
  AduanService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) => Uri.parse('${SanctumAuthService.apiBaseUrl}$path');

  Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (auth) {
      final token = await _token();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<void> createComplaint({
    required String kategori,
    required String judul,
    required String deskripsi,
    XFile? imageFile,
  }) async {
    final request = http.MultipartRequest('POST', _uri('/api/aduan'));
    final headers = await _headers(auth: true);
    headers.remove('Content-Type');
    request.headers.addAll(headers);
    request.fields.addAll(<String, String>{
      'kategori': kategori,
      'judul': judul,
      'deskripsi': deskripsi,
    });

    if (imageFile != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'gambar',
          await imageFile.readAsBytes(),
          filename: imageFile.name,
        ),
      );
    }

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_decodeMessage(response));
    }
  }

  String _decodeMessage(http.Response response) {
    try {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }

        final errors = decoded['errors'];
        if (errors is Map<String, dynamic>) {
          for (final value in errors.values) {
            if (value is List && value.isNotEmpty && value.first is String) {
              return value.first as String;
            }
          }
        }
      }
    } catch (_) {
      // Fall back to raw body/status below.
    }

    final trimmed = response.body.trim();
    if (trimmed.isNotEmpty) return trimmed;
    return 'HTTP ${response.statusCode}';
  }
}