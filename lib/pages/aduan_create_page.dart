import 'package:flutter/material.dart';

class AduanCreatePage extends StatefulWidget {
  const AduanCreatePage({super.key});

  static const String routeName = '/aduan-baru';

  @override
  State<AduanCreatePage> createState() => _AduanCreatePageState();
}

class _AduanCreatePageState extends State<AduanCreatePage> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _isiController = TextEditingController();
  final List<String> _categories = <String>[
    'Perkuliahan',
    'Administrasi',
    'Fasilitas',
    'Layanan Kampus',
  ];
  String? _selectedCategory;

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  void _submitComplaint() {
    final String category = _selectedCategory ?? '';
    final String judul = _judulController.text.trim();
    final String isi = _isiController.text.trim();

    if (category.isEmpty || judul.isEmpty || isi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi kategori, judul, dan deskripsi aduan.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aduan berhasil dikirim.')),
    );
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF3D1D1)),
                          ),
                          child: const Text(
                            'Choose File   No file chosen',
                            style: TextStyle(color: Color(0xFF8A4A4A)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _submitComplaint,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB91C1C),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
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
