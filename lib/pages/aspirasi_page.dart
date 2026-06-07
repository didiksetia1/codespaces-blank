import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/aspirasi.dart';
import '../services/aspirasi_service.dart';
import 'aspirasi_detail_page.dart';

class AspirasiPage extends StatefulWidget {
  const AspirasiPage({super.key});

  static const String routeName = '/aspirasi';

  @override
  State<AspirasiPage> createState() => _AspirasiPageState();
}

class _AspirasiPageState extends State<AspirasiPage> {
  int _currentIndex = 0;
  final AspirasiService _service = AspirasiService();
  final TextEditingController _searchController = TextEditingController();

  List<Aspirasi> _daftarAspirasi = [];
  List<Aspirasi> _filteredAspirasi = [];
  bool _isLoadingList = false;
  String? _listError;
  AspirasiEvent? _activeEvent;

  // Create form controllers
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _tujuanController = TextEditingController();
  String _selectedCategory = '-- Pilih Kategori --';
  bool _isAnonymous = false;
  bool _isSubmitting = false;
  XFile? _selectedImage;

  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _categories = [
    '-- Pilih Kategori --',
    'akademik',
    'fasilitas',
    'kesejahteraan',
    'kegiatan',
    'lingkungan',
    'teknologi',
    'lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _loadAspirasi();
    _loadEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _judulController.dispose();
    _deskripsiController.dispose();
    _tujuanController.dispose();
    super.dispose();
  }

  Future<void> _loadAspirasi() async {
    setState(() {
      _isLoadingList = true;
      _listError = null;
    });

    try {
      final aspirasis = await _service.fetchAspirasi();
      if (mounted) {
        setState(() {
          _daftarAspirasi = aspirasis;
          _filteredAspirasi = aspirasis;
          _isLoadingList = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _listError = e.toString();
          _isLoadingList = false;
        });
      }
    }
  }

  Future<void> _loadEvents() async {
    try {
      final events = await _service.fetchEvents();
      if (events.isNotEmpty && mounted) {
        setState(() {
          _activeEvent = events.first;
        });
      }
    } catch (_) {
      // Silently fail for events
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAspirasi = _daftarAspirasi;
      } else {
        _filteredAspirasi = _daftarAspirasi
            .where((a) =>
                a.judul.toLowerCase().contains(query.toLowerCase()) ||
                a.deskripsi.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null || !mounted) return;

    setState(() {
      _selectedImage = image;
    });
  }

  Future<void> _submitAspirasi() async {
    if (_judulController.text.isEmpty ||
        _deskripsiController.text.isEmpty ||
        _selectedCategory == '-- Pilih Kategori --') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap isi semua field yang wajib'),
          backgroundColor: Color(0xFFC41C1C),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final newAspirasi = await _service.createAspirasi(
        eventId: _activeEvent?.id ?? '1',
        judul: _judulController.text,
        kategori: _selectedCategory,
        deskripsi: _deskripsiController.text,
        tujuanManfaat: _tujuanController.text,
        anonim: _isAnonymous,
        imageFile: _selectedImage,
      );

      if (mounted) {
        setState(() {
          _daftarAspirasi.insert(0, newAspirasi);
          _filteredAspirasi = _daftarAspirasi;
          _currentIndex = 0;
          _isSubmitting = false;
        });

        _judulController.clear();
        _deskripsiController.clear();
        _tujuanController.clear();
        _selectedCategory = '-- Pilih Kategori --';
        _isAnonymous = false;
        _selectedImage = null;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aspirasi berhasil dikirim!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim aspirasi: $e'),
            backgroundColor: const Color(0xFFC41C1C),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F2),
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

  // ==================== Landing Page ====================

  Widget _buildLandingPage(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Pusat Layanan Aspirasi',
                textAlign: TextAlign.center,
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
              // Buat Aspirasi Card
              _buildActionCard(
                icon: Icons.lightbulb_outline,
                title: 'Buat Aspirasi Baru',
                description:
                    'Sampaikan kritik, saran, dan masukan Anda melalui form aspirasi.',
                onTap: () => setState(() => _currentIndex = 1),
              ),
              const SizedBox(height: 20),
              // Lihat Aspirasi Card
              _buildActionCard(
                icon: Icons.comment_outlined,
                title: 'Lihat Aspirasi',
                description:
                    'Lihat aspirasi yang sudah masuk, termasuk vote, komentar, dan status tindak lanjut.',
                onTap: () {
                  setState(() => _currentIndex = 2);
                  _loadAspirasi();
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x1ADCDCDC)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB91C1C).withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                icon,
                size: 40,
                color: const Color(0xFFB91C1C),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF7F1D1D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Create Aspirasi Page ====================

  Widget _buildCreateAspirasiPage(BuildContext context) {
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
                controller: _judulController,
                decoration: InputDecoration(
                  hintText: 'Contoh: Penambahan WiFi di parkiran',
                  hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFFDCDCDC), width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: const Color(0x33DCDCDC), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color(0xFFDC2626), width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
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
                    initialValue: _selectedCategory,
                    items: _categories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setDropdownState(() {
                        _selectedCategory = newValue ?? _selectedCategory;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: const Color(0x33DCDCDC), width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: const Color(0x33DCDCDC), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color(0xFFDC2626), width: 1),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
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
                controller: _deskripsiController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Jelaskan aspirasi Anda secara detail...',
                  hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFFDCDCDC), width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: const Color(0x33DCDCDC), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color(0xFFDC2626), width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
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
                controller: _tujuanController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'Jelaskan tujuan atau manfaat dari aspirasi ini...',
                  hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFFDCDCDC), width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: const Color(0x33DCDCDC), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color(0xFFDC2626), width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFDCDCDC)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                          onPressed: _isSubmitting ? null : _pickImage,
                          child: const Text('Choose File'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedImage == null
                                ? 'No file chosen'
                                : _selectedImage!.name,
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_selectedImage != null)
                          IconButton(
                            onPressed: _isSubmitting
                                ? null
                                : () {
                                    setState(() {
                                      _selectedImage = null;
                                    });
                                  },
                            icon: const Icon(Icons.close,
                                color: Color(0xFF9CA3AF), size: 20),
                            tooltip: 'Hapus gambar',
                          ),
                      ],
                    ),
                    if (_selectedImage != null) ...<Widget>[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_selectedImage!.path),
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 160,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: const Color(0xFFF9FAFB),
                                border:
                                    Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.broken_image_outlined,
                                        color: Color(0xFF9CA3AF), size: 36),
                                    SizedBox(height: 6),
                                    Text(
                                      'Gagal memuat gambar',
                                      style:
                                          TextStyle(color: Color(0xFF6B7280)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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
                        value: _isAnonymous,
                        onChanged: (value) {
                          setCheckboxState(() {
                            _isAnonymous = value ?? false;
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
                    backgroundColor: const Color(0xFFB91C1C),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submitAspirasi,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
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

  // ==================== Daftar Aspirasi Page ====================

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
              // Search bar
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Cari judul, deskripsi...',
                  hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFD1D5DB),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFFDCDCDC)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFFDCDCDC)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFFDC2626)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Loading
              if (_isLoadingList)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(
                      color: Color(0xFFB91C1C),
                    ),
                  ),
                )

              // Error
              else if (_listError != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 40,
                          color: Color(0xFFC41C1C),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Gagal memuat aspirasi',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _loadAspirasi,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Coba Lagi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB91C1C),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )

              // Empty state
              else if (_filteredAspirasi.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 40,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _searchController.text.isNotEmpty
                                ? 'Tidak ada aspirasi yang cocok'
                                : 'Belum ada aspirasi yang ditemukan.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )

              // List
              else
                RefreshIndicator(
                  onRefresh: _loadAspirasi,
                  color: const Color(0xFFB91C1C),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredAspirasi.length,
                    itemBuilder: (context, index) {
                      final aspirasi = _filteredAspirasi[index];
                      return _buildAspirasiCard(aspirasi);
                    },
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAspirasiCard(Aspirasi aspirasi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x1ADCDCDC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .pushNamed(
                AspirasiDetailPage.routeName,
                arguments: aspirasi.id,
              )
              .then((_) => _loadAspirasi());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Text(
                      aspirasi.status.replaceAll('_', ' '),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB91C1C),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Meta info
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  // Kategori
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
                  // Author
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 14,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        aspirasi.displayAuthor,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  // Date
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        aspirasi.formatTanggal,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  // Votes
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.thumb_up_outlined,
                        size: 14,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${aspirasi.votes} Votes',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description preview
              Text(
                aspirasi.deskripsi,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 12),

              // Lihat Selengkapnya
              GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(
                        AspirasiDetailPage.routeName,
                        arguments: aspirasi.id,
                      )
                      .then((_) => _loadAspirasi());
                },
                child: const Text(
                  'Lihat Selengkapnya →',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFB91C1C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
