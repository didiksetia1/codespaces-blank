import 'package:flutter/material.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({required this.message, required this.onRetry, super.key});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFC41C1C)),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat agenda',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF8A4A4A)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => onRetry(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC41C1C),
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({required this.onRetry, super.key});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.event_busy_outlined, size: 48, color: Color(0xFF8A4A4A)),
            const SizedBox(height: 12),
            const Text(
              'Belum ada agenda',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF7F1D1D),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Data agenda dari server masih kosong.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF8A4A4A)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => onRetry(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC41C1C),
                foregroundColor: Colors.white,
              ),
              child: const Text('Muat Ulang'),
            ),
          ],
        ),
      ),
    );
  }
}

class InlineMessage extends StatelessWidget {
  const InlineMessage({required this.message, required this.onRetry, super.key});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3D1D1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            message,
            style: const TextStyle(color: Color(0xFF8A4A4A)),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: () => onRetry(),
              child: const Text('Coba Lagi'),
            ),
          ),
        ],
      ),
    );
  }
}
