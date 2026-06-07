class Aspirasi {
  final String id;
  final String judul;
  final String kategori;
  final String deskripsi;
  final String tujuanManfaat;
  final String? lampiran;
  final DateTime tanggalBuat;
  final bool anonim;
  final String status; // 'submitted', 'diproses', 'ditolak', 'diterima'
  int votes;
  int komentar;
  final String? bemResponse;
  final String? userName;
  final bool? hasVoted;

  Aspirasi({
    required this.id,
    required this.judul,
    required this.kategori,
    required this.deskripsi,
    required this.tujuanManfaat,
    this.lampiran,
    required this.tanggalBuat,
    required this.anonim,
    this.status = 'submitted',
    this.votes = 0,
    this.komentar = 0,
    this.bemResponse,
    this.userName,
    this.hasVoted,
  });

  factory Aspirasi.fromJson(Map<String, dynamic> json) {
    String readString(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        final value = json[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
        if (value is num) return value.toString();
      }
      return fallback;
    }

    int readInt(List<String> keys, {int fallback = 0}) {
      for (final key in keys) {
        final value = json[key];
        if (value is int) return value;
        if (value is num) return value.toInt();
        if (value is String) {
          final parsed = int.tryParse(value);
          if (parsed != null) return parsed;
        }
      }
      return fallback;
    }

    DateTime readDate(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value is String) {
          final parsed = DateTime.tryParse(value);
          if (parsed != null) return parsed;
        }
      }
      return DateTime.now();
    }

    bool readBool(List<String> keys, {bool fallback = false}) {
      for (final key in keys) {
        final value = json[key];
        if (value is bool) return value;
        if (value is int) return value == 1;
        if (value is String) {
          if (value == '1' || value.toLowerCase() == 'true') return true;
        }
      }
      return fallback;
    }

    // Handle nested user object
    String readUserName() {
      final user = json['user'];
      if (user is Map<String, dynamic>) {
        return user['name']?.toString().trim() ??
            user['nama']?.toString().trim() ??
            'Anonymous';
      }
      return readString(['user_name', 'author_name', 'nama'], fallback: 'Anonymous');
    }

    return Aspirasi(
      id: readString(['id', 'aspirasi_id'], fallback: '-'),
      judul: readString(['judul', 'title', 'name'], fallback: 'Tanpa Judul'),
      kategori: readString(['kategori', 'category'], fallback: 'Lainnya'),
      deskripsi: readString(['deskripsi', 'description', 'isi', 'content'], fallback: ''),
      tujuanManfaat: readString(['tujuan_manfaat', 'tujuanManfaat', 'tujuan', 'manfaat'], fallback: ''),
      lampiran: json['lampiran']?.toString(),
      tanggalBuat: readDate(['created_at', 'tanggal_buat', 'tanggalBuat', 'date', 'tanggal']),
      anonim: readBool(['anonim', 'is_anonim', 'is_anonymous']),
      status: readString(['status'], fallback: 'submitted'),
      votes: readInt(['votes_count', 'votes', 'vote_count', 'jumlah_vote']),
      komentar: readInt(['comments_count', 'comments', 'comment_count', 'jumlah_komentar', 'komentar']),
      bemResponse: json['bem_response']?.toString(),
      userName: readUserName(),
      hasVoted: json['has_voted'] as bool?,
    );
  }

  String get formatTanggal {
    return '${tanggalBuat.day} ${_getNamaBulan(tanggalBuat.month)} ${tanggalBuat.year}';
  }

  String get displayAuthor => anonim ? 'Anonymous' : (userName ?? 'Anonymous');

  String _getNamaBulan(int bulan) {
    const bulanList = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return bulanList[bulan - 1];
  }

  Aspirasi copyWith({
    String? id,
    String? judul,
    String? kategori,
    String? deskripsi,
    String? tujuanManfaat,
    String? lampiran,
    DateTime? tanggalBuat,
    bool? anonim,
    String? status,
    int? votes,
    int? komentar,
    String? bemResponse,
    String? userName,
    bool? hasVoted,
  }) {
    return Aspirasi(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      kategori: kategori ?? this.kategori,
      deskripsi: deskripsi ?? this.deskripsi,
      tujuanManfaat: tujuanManfaat ?? this.tujuanManfaat,
      lampiran: lampiran ?? this.lampiran,
      tanggalBuat: tanggalBuat ?? this.tanggalBuat,
      anonim: anonim ?? this.anonim,
      status: status ?? this.status,
      votes: votes ?? this.votes,
      komentar: komentar ?? this.komentar,
      bemResponse: bemResponse ?? this.bemResponse,
      userName: userName ?? this.userName,
      hasVoted: hasVoted ?? this.hasVoted,
    );
  }
}

class AspirasiEvent {
  final String id;
  final String title;
  final String description;
  final bool isActive;

  AspirasiEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.isActive,
  });

  factory AspirasiEvent.fromJson(Map<String, dynamic> json) {
    return AspirasiEvent(
      id: json['id']?.toString() ?? '-',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }
}

class AspirasiComment {
  final String id;
  final String userName;
  final String text;
  final DateTime createdAt;

  AspirasiComment({
    required this.id,
    required this.userName,
    required this.text,
    required this.createdAt,
  });

  factory AspirasiComment.fromJson(Map<String, dynamic> json) {
    String readUserName() {
      final user = json['user'];
      if (user is Map<String, dynamic>) {
        return user['name']?.toString().trim() ??
            user['nama']?.toString().trim() ??
            'Mahasiswa';
      }
      return json['user_name']?.toString() ??
          json['nama']?.toString() ??
          'Mahasiswa';
    }

    return AspirasiComment(
      id: json['id']?.toString() ?? '-',
      userName: readUserName(),
      text: json['comment']?.toString() ??
          json['text']?.toString() ??
          json['isi']?.toString() ??
          '',
      createdAt: DateTime.tryParse(
            (json['created_at'] ?? json['date'] ?? '').toString(),
          ) ??
          DateTime.now(),
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inHours < 1) return '${diff.inMinutes} menit lalu';
    if (diff.inDays < 1) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${createdAt.day} ${_getNamaBulan(createdAt.month)} ${createdAt.year}';
  }

  String _getNamaBulan(int bulan) {
    const bulanList = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return bulanList[bulan - 1];
  }
}
