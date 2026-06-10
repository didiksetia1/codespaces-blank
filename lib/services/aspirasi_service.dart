import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/aspirasi.dart';
import 'auth_service_sanctum.dart';

class AspirasiService {
  AspirasiService({http.Client? client}) : _client = client ?? http.Client();

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

  Future<dynamic> _decodeBody(http.Response response) async {
    if (response.body.trim().isEmpty) return null;
    return jsonDecode(response.body);
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

  Map<String, dynamic>? _extractObject(dynamic data) {
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is Map<String, dynamic>) return nested;
      return data;
    }
    return null;
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    }

    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is List) {
        return nested.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
      }
    }

    return <Map<String, dynamic>>[];
  }

  // ==================== Events ====================

  Future<List<AspirasiEvent>> fetchEvents() async {
    final response = await _client.get(
      _uri('/api/aspirasi/events'),
      headers: await _headers(auth: true),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal memuat events (${response.statusCode})');
    }

    final data = await _decodeBody(response);
    final list = _extractList(data);

    return list.map((json) => AspirasiEvent.fromJson(json)).toList();
  }

  // ==================== Aspirasi List ====================

  Future<List<Aspirasi>> fetchAspirasi({String? query, String? status}) async {
    final queryParams = <String, String>{};
    if (query != null && query.isNotEmpty) queryParams['q'] = query;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;

    final uri = queryParams.isEmpty
        ? _uri('/api/aspirasi')
        : _uri('/api/aspirasi').replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: await _headers(auth: true),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal memuat aspirasi (${response.statusCode})');
    }

    final data = await _decodeBody(response);
    final list = _extractList(data);

    return list.map((json) => Aspirasi.fromJson(json)).toList();
  }

  // ==================== Aspirasi Detail ====================

  Future<Aspirasi> fetchAspirasiDetail(String id) async {
    final response = await _client.get(
      _uri('/api/aspirasi/$id'),
      headers: await _headers(auth: true),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal memuat detail aspirasi (${response.statusCode})');
    }

    final data = await _decodeBody(response);
    final obj = _extractObject(data);
    if (obj == null) {
      throw Exception('Format detail aspirasi tidak valid');
    }

    return Aspirasi.fromJson(obj);
  }

  // ==================== Create Aspirasi ====================

  Future<Aspirasi> createAspirasi({
    required String eventId,
    required String judul,
    required String kategori,
    required String deskripsi,
    String? tujuanManfaat,
    bool anonim = false,
    XFile? imageFile,
  }) async {
    final request = http.MultipartRequest('POST', _uri('/api/aspirasi/$eventId'));
    final headers = await _headers(auth: true);
    headers.remove('Content-Type');
    request.headers.addAll(headers);
    request.fields.addAll(<String, String>{
      'judul': judul,
      'kategori': kategori,
      'deskripsi': deskripsi,
      if (tujuanManfaat != null && tujuanManfaat.isNotEmpty)
        'tujuan_manfaat': tujuanManfaat,
      'anonim': anonim ? '1' : '0',
    });

    if (imageFile != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'lampiran',
          await imageFile.readAsBytes(),
          filename: imageFile.name,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_decodeMessage(response));
    }

    final data = jsonDecode(response.body);
    final obj = _extractObject(data);
    if (obj != null) {
      return Aspirasi.fromJson(obj);
    }

    return fetchAspirasiDetail(eventId);
  }

  // ==================== Vote ====================

  Future<bool> toggleVote(String id) async {
    final response = await _client.post(
      _uri('/api/aspirasi/$id/vote'),
      headers: await _headers(auth: true),
      body: jsonEncode(<String, dynamic>{}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_decodeMessage(response));
    }

    final data = await _decodeBody(response);
    if (data is Map<String, dynamic>) {
      final voted = data['voted'];
      if (voted is bool) return voted;
    }

    return false;
  }

  // ==================== Comment ====================

  Future<List<AspirasiComment>> fetchComments(String id) async {
    final response = await _client.get(
      _uri('/api/aspirasi/$id'),
      headers: await _headers(auth: true),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal memuat komentar (${response.statusCode})');
    }

    final data = await _decodeBody(response);
    if (data is Map<String, dynamic>) {
      final comments = data['comments'] ?? data['data']?['comments'];
      if (comments is List) {
        return comments
            .whereType<Map>()
            .map((c) => AspirasiComment.fromJson(Map<String, dynamic>.from(c)))
            .toList();
      }
    }

    return [];
  }

  Future<void> postComment(String id, String comment) async {
    final response = await _client.post(
      _uri('/api/aspirasi/$id/comment'),
      headers: await _headers(auth: true),
      body: jsonEncode(<String, dynamic>{
        'comment': comment,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_decodeMessage(response));
    }
  }
}
