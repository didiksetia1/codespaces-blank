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
  final int votes;
  int komentar;

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
  });

  String get formatTanggal {
    return '${tanggalBuat.day} ${_getNamaBulan(tanggalBuat.month)} ${tanggalBuat.year}';
  }

  String _getNamaBulan(int bulan) {
    const bulanList = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return bulanList[bulan - 1];
  }
}
