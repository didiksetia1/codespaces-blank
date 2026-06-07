import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import '../services/aduan_service.dart';

class AduanCreatePage extends StatefulWidget {
  const AduanCreatePage({super.key});

  static const String routeName = '/aduan-baru';

  @override
  State<AduanCreatePage> createState() => _AduanCreatePageState();
}

class _AduanCreatePageState extends State<AduanCreatePage> {
  final ImagePicker _imagePicker = ImagePicker();
  final AduanService _aduanService = AduanService();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _isiController = TextEditingController();
  final List<String> _categories = <String>[
    'Perkuliahan',
    'Administrasi',
    'Fasilitas',
    'Layanan Kampus',
  ];
  String? _selectedCategory;
  XFile? _selectedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
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

  Future<void> _submitComplaint() async {
    final String category = _selectedCategory ?? '';
    final String judul = _judulController.text.trim();
    final String isi = _isiController.text.trim();

    if (category.isEmpty || judul.isEmpty || isi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi kategori, judul, dan deskripsi aduan.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _aduanService.createComplaint(
        kategori: category,
        judul: judul,
        deskripsi: isi,
        imageFile: _selectedImage,
      );

      if (!mounted) return;

      _judulController.clear();
      _isiController.clear();
      setState(() {
        _selectedCategory = null;
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aduan berhasil dikirim.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim aduan: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Pengaduan'),
        backgroundColor: const Color(0xFFFDF2F2),
        surfaceTintColor: const Color(0xFFFDF2F2),
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Buat Pengaduan',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFB91C1C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sampaikan keluhan dan aduan Anda secara rinci agar segera dapat diproses.',
                    style: TextStyle(color: Color(0xFFB76B6B), fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFF3D1D1)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.red.shade100.withValues(alpha: 0.3),
                          blurRadius: 28,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const _ComplaintFieldLabel(text: 'Kategori'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          items: _categories
                              .map(
                                (String category) => DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                ),
                              )
                              .toList(),
                          onChanged: (String? value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                          decoration: _fieldDecoration(' -- Pilih Kategori -- '),
                        ),
                        const SizedBox(height: 18),
                        const _ComplaintFieldLabel(text: 'Topik / Judul Aduan'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _judulController,
                          decoration: _fieldDecoration('Contoh: AC Kelas Rusak'),
                        ),
                        const SizedBox(height: 18),
                        const _ComplaintFieldLabel(text: 'Deskripsi Detail'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _isiController,
                          minLines: 6,
                          maxLines: 8,
                          decoration: _fieldDecoration('Jelaskan secara detail mengenai aduan Anda...'),
                        ),
                        const SizedBox(height: 18),
                        const _ComplaintFieldLabel(text: 'Bukti Foto (Opsional)'),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF3D1D1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      _selectedImage == null ? 'Belum ada gambar dipilih' : _selectedImage!.name,
                                      style: const TextStyle(color: Color(0xFF8A4A4A)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  TextButton.icon(
                                    onPressed: _isSubmitting ? null : _pickImage,
                                    icon: const Icon(Icons.image_outlined),
                                    label: const Text('Pilih Gambar'),
                                  ),
                                ],
                              ),
                              if (_selectedImage != null) ...<Widget>[
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xFFF9FAFB),
                                    border: Border.all(color: const Color(0xFFE5E7EB)),
                                  ),
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(Icons.image_outlined, color: Color(0xFF9CA3AF), size: 40),
                                        SizedBox(height: 8),
                                        Text(
                                          'Gambar siap diupload',
                                          style: TextStyle(color: Color(0xFF6B7280)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitComplaint,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB91C1C),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Kirim Pengaduan',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFF3D1D1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFF3D1D1)),
      ),
    );
  }
}

class _ComplaintFieldLabel extends StatelessWidget {
  const _ComplaintFieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: Color(0xFF8A2222),
      ),
    );
  }
}
