import 'package:flutter/material.dart';

class ComplaintHistoryEntry {
  const ComplaintHistoryEntry({
    required this.title,
    required this.category,
    required this.status,
    required this.dateLabel,
    required this.description,
    required this.activeStep,
  });

  final String title;
  final String category;
  final String status;
  final String dateLabel;
  final String description;
  final int activeStep;
}

class ComplaintHistoryDetail extends StatelessWidget {
  const ComplaintHistoryDetail({required this.entry, super.key});

  final ComplaintHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final List<_TimelineStage> stages = <_TimelineStage>[
      const _TimelineStage(label: 'Dikirim', dateLabel: '06 May 2026, 09:02'),
      const _TimelineStage(label: 'Ditinjau'),
      const _TimelineStage(label: 'Diproses'),
      const _TimelineStage(label: 'Selesai'),
    ];

    return Container(
      height: 360,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF5D2D2)),
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
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFB91C1C),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF2FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  entry.status,
                  style: const TextStyle(
                    color: Color(0xFF0F8BD5),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              entry.category,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF6D7280),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF6F6),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF7CACA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'TIMELINE STATUS',
                  style: TextStyle(
                    color: Color(0xFFB23A3A),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 14),
                ...stages.asMap().entries.map(
                  (MapEntry<int, _TimelineStage> stage) => _TimelineRow(
                    stage: stage.value,
                    active: stage.key <= entry.activeStep,
                    isLast: stage.key == stages.length - 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            entry.description,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF8A4A4A),
              height: 1.5,
            ),
          ),
          const Spacer(),
          Text(
            'Dikirim pada: ${entry.dateLabel}',
            style: const TextStyle(
              color: Color(0xFFC08D8D),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStage {
  const _TimelineStage({required this.label, this.dateLabel});

  final String label;
  final String? dateLabel;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.stage,
    required this.active,
    required this.isLast,
  });

  final _TimelineStage stage;
  final bool active;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFFFB4F72);
    final Color inactiveColor = const Color(0xFFC9D1DC);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: active ? activeColor : inactiveColor, width: 2),
              ),
              child: active
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFB4F72),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 24,
                color: active
                    ? activeColor.withValues(alpha: 0.45)
                    : inactiveColor.withValues(alpha: 0.55),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  stage.label,
                  style: TextStyle(
                    color: active ? const Color(0xFFB91C1C) : const Color(0xFF798191),
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                if (stage.dateLabel != null)
                  Text(
                    stage.dateLabel!,
                    style: TextStyle(
                      color: active ? const Color(0xFFFB4F72) : const Color(0xFF9AA3AF),
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
