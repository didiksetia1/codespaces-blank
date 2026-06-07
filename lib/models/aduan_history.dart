class AduanHistoryEntry {
  const AduanHistoryEntry({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.description,
    required this.createdAt,
    required this.activeStep,
    this.ditinjauAt,
    this.diprosesAt,
    this.selesaiAt,
    this.tanggapan,
  });

  final String id;
  final String title;
  final String category;
  final String status;
  final String description;
  final DateTime createdAt;
  final DateTime? ditinjauAt;
  final DateTime? diprosesAt;
  final DateTime? selesaiAt;
  final String? tanggapan;
  final int activeStep;

  factory AduanHistoryEntry.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> pickSource(Map<String, dynamic> source) {
      final nested = source['data'];
      if (nested is Map<String, dynamic>) return nested;
      return source;
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

    DateTime? readDate(Map<String, dynamic> source, List<String> keys) {
      for (final key in keys) {
        final value = source[key];
        if (value is String && value.trim().isNotEmpty) {
          final parsed = DateTime.tryParse(value.trim());
          if (parsed != null) return parsed;
        }
      }
      return null;
    }

    int statusStep(String status) {
      switch (status.toLowerCase()) {
        case 'ditinjau':
          return 1;
        case 'diproses':
          return 2;
        case 'selesai':
          return 3;
        default:
          return 0;
      }
    }

    final source = pickSource(json);
    final status = readString(source, <String>['status'], fallback: 'dikirim');

    return AduanHistoryEntry(
      id: readString(source, <String>['id'], fallback: '-'),
      title: readString(source, <String>['judul', 'title', 'name'], fallback: 'Aduan'),
      category: readString(source, <String>['kategori', 'category'], fallback: 'Umum'),
      status: status.isEmpty ? 'dikirim' : status,
      description: readString(source, <String>['deskripsi', 'description', 'isi', 'content'], fallback: ''),
      createdAt: readDate(source, <String>['created_at', 'tanggal', 'date']) ?? DateTime.now(),
      ditinjauAt: readDate(source, <String>['ditinjau_at']),
      diprosesAt: readDate(source, <String>['diproses_at']),
      selesaiAt: readDate(source, <String>['selesai_at']),
      tanggapan: readString(source, <String>['tanggapan', 'response', 'balasan'], fallback: '').trim().isEmpty
          ? null
          : readString(source, <String>['tanggapan', 'response', 'balasan']),
      activeStep: statusStep(status),
    );
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'ditinjau':
        return 'DITINJAU';
      case 'diproses':
        return 'DIPROSES';
      case 'selesai':
        return 'SELESAI';
      default:
        return 'DIKIRIM';
    }
  }

  String get createdAtLabel => _formatDate(createdAt);

  String? timelineDateLabelFor(int step) {
    final DateTime? date = switch (step) {
      0 => createdAt,
      1 => ditinjauAt,
      2 => diprosesAt,
      3 => selesaiAt,
      _ => null,
    };

    if (date == null) return null;
    return _formatDate(date);
  }

  String _formatDate(DateTime value) {
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${value.day.toString().padLeft(2, '0')} ${months[value.month - 1]} ${value.year}, ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }
}