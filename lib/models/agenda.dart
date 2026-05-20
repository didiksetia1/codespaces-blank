class Agenda {
  final String id;
  final String judul;
  final String kategori;
  final String deskripsi;
  final String? imageUrl;
  final DateTime tanggal;
  int likes;
  int comments;
  final List<Komentar> daftarKomentar;

  Agenda({
    required this.id,
    required this.judul,
    required this.kategori,
    required this.deskripsi,
    this.imageUrl,
    required this.tanggal,
    this.likes = 0,
    this.comments = 0,
    this.daftarKomentar = const [],
  });

  factory Agenda.fromJson(Map<String, dynamic> json) {
    dynamic readRawValue(Map<String, dynamic> source, List<String> keys) {
      for (final key in keys) {
        final value = source[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
        if (value is int) return value;
        if (value is Map<String, dynamic>) return value;
      }
      return null;
    }

    String readId(Map<String, dynamic> source, List<String> keys, {String fallback = ''}) {
      final value = readRawValue(source, keys);
      if (value is String) return value;
      if (value is int) return value.toString();
      return fallback;
    }

    String readString(Map<String, dynamic> source, List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        final value = source[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
        if (value is num) {
          return value.toString();
        }
      }
      return fallback;
    }

    int readInt(Map<String, dynamic> source, List<String> keys, {int fallback = 0}) {
      for (final key in keys) {
        final value = source[key];
        if (value is int) return value;
        if (value is num) return value.toInt();
        if (value is String) {
          final parsed = int.tryParse(value);
          if (parsed != null) return parsed;
        }
      }
      return fallback;
    }

    DateTime readDate(Map<String, dynamic> source, List<String> keys) {
      for (final key in keys) {
        final value = source[key];
        if (value is String) {
          final parsed = DateTime.tryParse(value);
          if (parsed != null) return parsed;
        }
      }
      return DateTime.now();
    }

    Map<String, dynamic> pickNestedSource(Map<String, dynamic> source) {
      for (final key in <String>['agenda', 'data', 'attributes', 'item']) {
        final value = source[key];
        if (value is Map<String, dynamic>) return value;
      }
      return source;
    }

    final source = pickNestedSource(json);

    List<Komentar> readKomentar(Map<String, dynamic> source) {
      final rawComments = source['comments'] ?? source['daftarKomentar'] ?? source['komentar'];
      if (rawComments is List) {
        return rawComments
            .whereType<Map>()
            .map(
              (Map comment) {
                final Map<String, dynamic> commentMap = Map<String, dynamic>.from(comment);
                final dynamic nestedUser = commentMap['user'];
                final Map<String, dynamic>? userMap = nestedUser is Map<String, dynamic>
                    ? nestedUser
                    : nestedUser is Map
                        ? Map<String, dynamic>.from(nestedUser)
                        : null;

                String readCommentText(List<String> keys, {String fallback = ''}) {
                  for (final key in keys) {
                    final value = commentMap[key];
                    if (value is String && value.trim().isNotEmpty) return value.trim();
                    if (value is num) return value.toString();
                  }
                  return fallback;
                }

                String readUserName() {
                  final candidates = <String>[
                    if (userMap != null) ...<String>[
                      if ((userMap['name'] ?? '').toString().trim().isNotEmpty) userMap['name'].toString(),
                      if ((userMap['nama'] ?? '').toString().trim().isNotEmpty) userMap['nama'].toString(),
                      if ((userMap['username'] ?? '').toString().trim().isNotEmpty) userMap['username'].toString(),
                    ],
                    readCommentText(<String>['nama', 'name', 'username', 'author_name', 'user_name'], fallback: ''),
                  ];

                  for (final value in candidates) {
                    if (value.trim().isNotEmpty) return value.trim();
                  }
                  return 'Anonim';
                }

                return Komentar(
                  id: '${commentMap['id'] ?? commentMap['comment_id'] ?? DateTime.now().microsecondsSinceEpoch}',
                  nama: readUserName(),
                  isi: readCommentText(<String>['isi', 'comment', 'comment_text', 'text', 'content', 'body', 'message', 'komentar'], fallback: 'Komentar tidak memiliki isi'),
                  tanggal: DateTime.tryParse((commentMap['created_at'] ?? commentMap['tanggal'] ?? commentMap['date'] ?? commentMap['posted_at'] ?? '').toString()) ?? DateTime.now(),
                );
              },
            )
            .toList();
      }
      return const <Komentar>[];
    }

    return Agenda(
      id: readId(source, <String>['id', 'agenda_id', 'id_agenda', 'agendaId', 'agenda_id_agenda', 'agenda_id_number'], fallback: '-'),
      judul: readString(source, <String>['judul', 'title', 'name', 'nama', 'judul_agenda'], fallback: 'Agenda'),
      kategori: readString(source, <String>['kategori', 'category', 'jenis', 'type'], fallback: 'Agenda Kampus'),
      deskripsi: readString(source, <String>['deskripsi', 'description', 'isi', 'content', 'body'], fallback: ''),
      imageUrl: readString(source, <String>['image_url', 'image', 'thumbnail', 'foto', 'gambar']).isEmpty
          ? null
          : readString(source, <String>['image_url', 'image', 'thumbnail', 'foto', 'gambar']),
      tanggal: readDate(source, <String>['tanggal', 'date', 'published_at', 'created_at', 'posted_at']),
      likes: readInt(source, <String>['likes_count', 'likes', 'like_count', 'jumlah_like']),
      comments: readInt(source, <String>['comments_count', 'comments', 'comment_count', 'jumlah_komentar']),
      daftarKomentar: readKomentar(source),
    );
  }

  Agenda copyWith({
    String? id,
    String? judul,
    String? kategori,
    String? deskripsi,
    String? imageUrl,
    DateTime? tanggal,
    int? likes,
    int? comments,
    List<Komentar>? daftarKomentar,
  }) {
    return Agenda(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      kategori: kategori ?? this.kategori,
      deskripsi: deskripsi ?? this.deskripsi,
      imageUrl: imageUrl ?? this.imageUrl,
      tanggal: tanggal ?? this.tanggal,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      daftarKomentar: daftarKomentar ?? this.daftarKomentar,
    );
  }

  String get formatTanggal {
    return '${tanggal.day} ${_getNamaBulan(tanggal.month)} ${tanggal.year}';
  }

  String _getNamaBulan(int bulan) {
    const bulanList = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return bulanList[bulan - 1];
  }
}

class Komentar {
  final String id;
  final String nama;
  final String isi;
  final DateTime tanggal;

  Komentar({
    required this.id,
    required this.nama,
    required this.isi,
    required this.tanggal,
  });

  String get formatTanggal {
    final now = DateTime.now();
    final diff = now.difference(tanggal);

    if (diff.inHours < 1) {
      return '${diff.inMinutes} menit lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else {
      return '${tanggal.day} ${_getNamaBulan(tanggal.month)} ${tanggal.year}';
    }
  }

  String _getNamaBulan(int bulan) {
    const bulanList = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return bulanList[bulan - 1];
  }
}
