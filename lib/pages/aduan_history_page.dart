import 'package:flutter/material.dart';

import '../widgets/complaint_history_detail.dart';

class AduanHistoryPage extends StatelessWidget {
  const AduanHistoryPage({super.key});

  static const String routeName = '/aduan-riwayat';

  static const List<ComplaintHistoryEntry> entries = <ComplaintHistoryEntry>[
    ComplaintHistoryEntry(
      title: 'coba test',
      category: 'Perkuliahan',
      status: 'DIKIRIM',
      dateLabel: '06 May 2026, 09:02',
      description: 'coba test',
      activeStep: 0,
    ),
    ComplaintHistoryEntry(
      title: 'Fasilitas Wi-Fi lab lambat',
      category: 'Fasilitas',
      status: 'DIPROSES',
      dateLabel: '02 Mei 2026, 14:12',
      description: 'Keluhan mengenai jaringan internet di laboratorium.',
      activeStep: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pengaduan Saya'),
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
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Riwayat Pengaduan Saya',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFB91C1C),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFF3D1D1)),
                    ),
                    child: ComplaintHistoryDetail(entry: entries.first),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
