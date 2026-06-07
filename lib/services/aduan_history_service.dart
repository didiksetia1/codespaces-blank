import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/aduan_history.dart';
import 'auth_service_sanctum.dart';

class AduanHistoryService {
  AduanHistoryService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) => Uri.parse('${SanctumAuthService.apiBaseUrl}$path');

  Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _headers() async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final token = await _token();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<List<AduanHistoryEntry>> fetchHistory() async {
    final response = await _client.get(
      _uri('/api/aduan/history'),
      headers: await _headers(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_decodeMessage(response));
    }

    if (response.body.trim().isEmpty) {
      return <AduanHistoryEntry>[];
    }

    final dynamic decoded = jsonDecode(response.body);
    final dynamic rawData = decoded is Map<String, dynamic> ? decoded['data'] : decoded;

    if (rawData is! List) {
      return <AduanHistoryEntry>[];
    }

    return rawData
        .whereType<Map>()
        .map((Map item) => AduanHistoryEntry.fromJson(Map<String, dynamic>.from(item)))
        .toList();
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
          final firstError = errors.values.cast<dynamic>().firstWhere(
                (dynamic value) => value is List && value.isNotEmpty,
                orElse: () => null,
              );
          if (firstError is List && firstError.first is String) {
            return firstError.first as String;
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