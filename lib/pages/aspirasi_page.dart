import 'package:flutter/material.dart';
import '../models/aspirasi.dart';
import '../widgets/info_panel.dart';

class AspirasiPage extends StatefulWidget {
  const AspirasiPage({super.key});

  static const String routeName = '/aspirasi';

  @override
  State<AspirasiPage> createState() => _AspirasiPageState();
}

class _AspirasiPageState extends State<AspirasiPage> {
  int _currentIndex = 0;
  final List<Aspirasi> _daftarAspirasi = [
    Aspirasi(
      id: '1',
      judul: 'parkiran bawah di perluas',
      kategori: 'Akademik',
      deskripsi: 'di parkiran barat gedung lebih baik di perluas karena saat ini parkiran barat sudah full',
      tujuanManfaat: 'Memudahkan parkiran bagi mahasiswa',
      tanggalBuat: DateTime(2026, 5, 6),
      anonim: true,
      status: 'submitted',
      votes: 0,
      komentar: 0,
    ),
    Aspirasi(
      id: '2',
      judul: 'memek kontol memek kontol memek kontol',
      kategori: 'Fasilitas',
      deskripsi: 'memek kontol memek kontol memek kontol',
      tujuanManfaat: 'Meningkatkan fasilitas',
      tanggalBuat: DateTime(2026, 5, 6),
      anonim: true,
      status: 'submitted',
      votes: 0,
      komentar: 0,
    ),
    Aspirasi(
      id: '3',
      judul: 'ayo judi online disini gratis',
      kategori: 'Fasilitas',
      deskripsi: 'ayo judi online disini gratis',
      tujuanManfaat: 'Hiburan',
      tanggalBuat: DateTime(2026, 5, 6),
      anonim: true,
      status: 'submitted',
      votes: 0,
      komentar: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aspirasi'),
        backgroundColor: const Color(0xFFFDF2F2),
        surfaceTintColor: const Color(0xFFFDF2F2),
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: _currentIndex == 0
          ? _buildLandingPage(context)
          : _currentIndex == 1
              ? _buildCreateAspirasiPage(context)
              : _buildDaftarAspirasiPage(context),
    );
  }

  Widget _buildLandingPage(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Pusat Layanan Aspirasi',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF7F1D1D),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pilih menu di bawah ini untuk mengirim aspirasi baru atau melihat aspirasi yang sudah masuk.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.55,
                  color: Color(0xFF8A4A4A),
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () => setState(() => _currentIndex = 1),
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDE8E8),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(
                          Icons.add_circle_outline,
                          size: 40,
                          color: Color(0xFF7F1D1D),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Buat Aspirasi Baru',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7F1D1D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sampaikan kritik, saran, dan masukan Anda melalui form aspirasi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFF8A4A4A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => setState(() => _currentIndex = 2),
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDE8E8),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(
                          Icons.list_alt_outlined,
                          size: 40,
                          color: Color(0xFF7F1D1D),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Lihat Aspirasi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7F1D1D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Lihat aspirasi yang sudah masuk, termasuk vote, komentar, dan status tidak lanjut.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFF8A4A4A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateAspirasiPage(BuildContext context) {
    final judulController = TextEditingController();
    final deskripsiController = TextEditingController();
    final tujuanController = TextEditingController();
    String selectedCategory = '-- Pilih Kategori --';
    bool isAnonymous = false;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => setState(() => _currentIndex = 0),
                child: const Text(
                  '← Kembali ke Pusat Layanan',
                  style: TextStyle(
                    color: Color(0xFFC41C1C),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Buat Aspirasi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF7F1D1D),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sampaikan aspirasi Anda secara detail agar segera dapat diproses.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8A4A4A),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Judul',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: judulController,
                decoration: InputDecoration(
                  hintText: 'Contoh: Penambahan WiFi di parkiran',
                  hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setDropdownState) {
                  return DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: [
                      '-- Pilih Kategori --',
                      'Akademik',
                      'Fasilitas',
                      'Keamanan',
                      'Layanan',
                      'Lainnya',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setDropdownState(() {
                        selectedCategory = newValue ?? selectedCategory;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Deskripsi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: deskripsiController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Jelaskan aspirasi Anda secara detail...',
                  hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tujuan/Manfaat',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: tujuanController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Jelaskan tujuan atau manfaat dari aspirasi ini...',
                  hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Lampiran (Opsional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () {},
                      child: const Text('Choose File'),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'No file chosen',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Maksimal ukuran file 5MB',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setCheckboxState) {
                  return Row(
                    children: [
                      Checkbox(
                        value: isAnonymous,
                        onChanged: (value) {
                          setCheckboxState(() {
                            isAnonymous = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFFC41C1C),
                      ),
                      const Text(
                        'Kirim sebagai Anonim',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7F1D1D),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC41C1C),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () {
                    if (judulController.text.isEmpty ||
                        deskripsiController.text.isEmpty ||
                        selectedCategory == '-- Pilih Kategori --') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Harap isi semua field yang wajib'),
                          backgroundColor: Color(0xFFC41C1C),
                        ),
                      );
                      return;
                    }

                    final newAspirasi = Aspirasi(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      judul: judulController.text,
                      kategori: selectedCategory,
                      deskripsi: deskripsiController.text,
                      tujuanManfaat: tujuanController.text,
                      tanggalBuat: DateTime.now(),
                      anonim: isAnonymous,
                    );

                    setState(() {
                      _daftarAspirasi.add(newAspirasi);
                      _currentIndex = 0;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Aspirasi berhasil dikirim!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text(
                    'Kirim Aspirasi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaftarAspirasiPage(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => setState(() => _currentIndex = 0),
                child: const Text(
                  '← Kembali ke Pusat Layanan',
                  style: TextStyle(
                    color: Color(0xFFC41C1C),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Daftar Aspirasi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF7F1D1D),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lihat aspirasi yang telah disampaikan oleh mahasiswa.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8A4A4A),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Cari judul, deskripsi...',
                  hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFD1D5DB),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_daftarAspirasi.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'Tidak ada aspirasi',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF8A4A4A),
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _daftarAspirasi.length,
                  itemBuilder: (context, index) {
                    final aspirasi = _daftarAspirasi[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  aspirasi.judul,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF7F1D1D),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Submitted',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFC41C1C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '● ${aspirasi.kategori}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF7F1D1D),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.person_outline,
                                size: 14,
                                color: Color(0xFF8A4A4A),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Anonymous',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF8A4A4A),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: Color(0xFF8A4A4A),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                aspirasi.formatTanggal,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF8A4A4A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            aspirasi.deskripsi,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Lihat Selengkapnya →',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFC41C1C),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.thumb_up_outlined,
                                      size: 16,
                                      color: Color(0xFF8A4A4A),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${aspirasi.votes} Votes',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF8A4A4A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.comment_outlined,
                                      size: 16,
                                      color: Color(0xFF8A4A4A),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${aspirasi.komentar} Komentar',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF8A4A4A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
