import 'package:flutter/material.dart';

import '../models/aduan_history.dart';
import '../services/aduan_history_service.dart';
import '../widgets/complaint_history_detail.dart';

class AduanHistoryPage extends StatefulWidget {
  const AduanHistoryPage({super.key});

  static const String routeName = '/aduan-riwayat';

  @override
  State<AduanHistoryPage> createState() => _AduanHistoryPageState();
}

class _AduanHistoryPageState extends State<AduanHistoryPage> {
  final AduanHistoryService _service = AduanHistoryService();
  late Future<List<AduanHistoryEntry>> _historyFuture;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadHistory();
  }

  Future<List<AduanHistoryEntry>> _loadHistory() async {
    final entries = await _service.fetchHistory();
    if (_selectedIndex >= entries.length) {
      _selectedIndex = 0;
    }
    return entries;
  }

  Future<void> _refreshHistory() async {
    setState(() {
      _historyFuture = _loadHistory();
    });
    await _historyFuture;
  }

  void _selectEntry(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildSummaryCard({
    required AduanHistoryEntry entry,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF7F7) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFFB91C1C) : const Color(0xFFF3D1D1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    entry.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF7F1D1D),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  entry.statusLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFC41C1C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              entry.category,
              style: const TextStyle(
                color: Color(0xFF8A4A4A),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              entry.createdAtLabel,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9AA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        child: FutureBuilder<List<AduanHistoryEntry>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC41C1C)),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(Icons.error_outline, color: Color(0xFFC41C1C), size: 42),
                      const SizedBox(height: 12),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF8A4A4A)),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshHistory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB91C1C),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final entries = snapshot.data ?? <AduanHistoryEntry>[];

            if (entries.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refreshHistory,
                color: const Color(0xFFC41C1C),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: <Widget>[
                    const Text(
                      'Riwayat Pengaduan Saya',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB91C1C),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFF3D1D1)),
                      ),
                      child: const Column(
                        children: <Widget>[
                          Icon(Icons.inbox_outlined, size: 42, color: Color(0xFFC08D8D)),
                          SizedBox(height: 12),
                          Text(
                            'Belum ada riwayat pengaduan.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8A4A4A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            final int safeIndex = _selectedIndex.clamp(0, entries.length - 1);
            final AduanHistoryEntry selectedEntry = entries[safeIndex];

            return RefreshIndicator(
              onRefresh: _refreshHistory,
              color: const Color(0xFFC41C1C),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: <Widget>[
                  const Text(
                    'Riwayat Pengaduan Saya',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFB91C1C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tarik ke bawah untuk memuat ulang daftar pengaduan terbaru dari server.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8A4A4A),
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
                    child: ComplaintHistoryDetail(entry: selectedEntry),
                  ),
                  if (entries.length > 1) ...<Widget>[
                    const SizedBox(height: 20),
                    const Text(
                      'Riwayat Lainnya',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7F1D1D),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...entries.asMap().entries.map(
                      (MapEntry<int, AduanHistoryEntry> item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildSummaryCard(
                          entry: item.value,
                          selected: item.key == safeIndex,
                          onTap: () => _selectEntry(item.key),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
