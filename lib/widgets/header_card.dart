import 'package:flutter/material.dart';

class HeaderCard extends StatelessWidget {
  const HeaderCard({
    required this.name,
    required this.nim,
    required this.jurusan,
    required this.prodi,
    super.key,
  });

  final String name;
  final String nim;
  final String jurusan;
  final String prodi;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFDC2626).withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB91C1C).withOpacity(0.10),
            blurRadius: 35,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome title with gradient
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFB91C1C), Color(0xFFEF4444)],
            ).createShader(bounds),
            child: Text(
              'Selamat Datang, $name!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Anda berada di beranda utama Talkyu. Pantau informasi, agenda terbaru, serta kirim pengaduan dan aspirasi Anda di sini.',
            style: TextStyle(
              color: const Color(0xFF7F1D1D).withOpacity(0.78),
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          // User info grid (mirip web: 3 kolom)
          Row(
            children: [
              Expanded(child: _InfoCard(label: 'NIM', value: nim)),
              const SizedBox(width: 12),
              Expanded(child: _InfoCard(label: 'Fakultas / Jurusan', value: jurusan)),
              const SizedBox(width: 12),
              Expanded(child: _InfoCard(label: 'Program Studi', value: prodi)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFDC2626).withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFFDC2626),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7F1D1D),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
