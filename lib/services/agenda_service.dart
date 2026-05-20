import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/agenda.dart';
import 'auth_service_sanctum.dart';

class AgendaService {
  AgendaService({http.Client? client}) : _client = client ?? http.Client();

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

  List<Map<String, dynamic>> _extractAgendaList(dynamic data) {
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

  Map<String, dynamic>? _extractAgendaObject(dynamic data) {
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is Map<String, dynamic>) return nested;
      return data;
    }
    return null;
  }

  Future<List<Agenda>> fetchAgendas() async {
    final response = await _client.get(
      _uri('/api/agenda'),
      headers: await _headers(auth: true),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal memuat agenda (${response.statusCode})');
    }

    final data = await _decodeBody(response);
    return _extractAgendaList(data).map(Agenda.fromJson).toList();
  }

  Future<Agenda> fetchAgenda(String id) async {
    final response = await _client.get(
      _uri('/api/agenda/$id'),
      headers: await _headers(auth: true),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal memuat detail agenda (${response.statusCode})');
    }

    final data = await _decodeBody(response);
    final agendaJson = _extractAgendaObject(data);
    if (agendaJson == null) {
      throw Exception('Format detail agenda tidak valid');
    }

    return Agenda.fromJson(agendaJson);
  }

  Future<Agenda> toggleLike(String id) async {
    final response = await _client.post(
      _uri('/api/agenda/$id/like'),
      headers: await _headers(auth: true),
      body: jsonEncode(<String, dynamic>{}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal memperbarui like (${response.statusCode})');
    }

    final data = await _decodeBody(response);
    final agendaJson = _extractAgendaObject(data);
    if (agendaJson != null) {
      return Agenda.fromJson(agendaJson);
    }

    return fetchAgenda(id);
  }

  Future<Agenda> comment(String id, String message) async {
    final response = await _client.post(
      _uri('/api/agenda/$id/comment'),
      headers: await _headers(auth: true),
      body: jsonEncode(<String, dynamic>{
        'comment': message,
        'isi': message,
        'message': message,
        'content': message,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal mengirim komentar (${response.statusCode})');
    }

    final data = await _decodeBody(response);
    final agendaJson = _extractAgendaObject(data);
    if (agendaJson != null) {
      return Agenda.fromJson(agendaJson);
    }

    return fetchAgenda(id);
  }

  Future<List<Komentar>> fetchComments(String id) async {
    final response = await _client.get(
      _uri('/api/agenda/$id/comments'),
      headers: await _headers(auth: true),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal memuat komentar (${response.statusCode})');
    }

    final data = await _decodeBody(response);
    final commentsList = <Komentar>[];

    if (data is Map<String, dynamic>) {
      final rawComments = data['data'];
      if (rawComments is List) {
        for (final comment in rawComments) {
          if (comment is Map) {
            final Map<String, dynamic> commentMap = Map<String, dynamic>.from(comment);
            final dynamic nestedUser = commentMap['user'];
            final Map<String, dynamic>? userMap = nestedUser is Map<String, dynamic>
                ? nestedUser
                : nestedUser is Map
                    ? Map<String, dynamic>.from(nestedUser)
                    : null;

            String userName = 'Anonim';
            if (userMap != null) {
              final name = userMap['name'] ?? userMap['nama'] ?? userMap['username'];
              if (name is String && name.trim().isNotEmpty) {
                userName = name.trim();
              }
            }

            final commentText = (commentMap['comment'] ?? commentMap['isi'] ?? commentMap['text'] ?? '').toString().trim();
            final createdAt = DateTime.tryParse((commentMap['created_at'] ?? commentMap['tanggal'] ?? '').toString());

            commentsList.add(
              Komentar(
                id: '${commentMap['id'] ?? DateTime.now().microsecondsSinceEpoch}',
                nama: userName,
                isi: commentText,
                tanggal: createdAt ?? DateTime.now(),
              ),
            );
          }
        }
      }
    }

    return commentsList;
  }
}