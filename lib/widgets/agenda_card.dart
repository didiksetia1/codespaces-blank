import 'package:flutter/material.dart';

import '../models/agenda_item.dart';

class AgendaCard extends StatelessWidget {
  const AgendaCard({required this.agenda, super.key});

  final AgendaItem agenda;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3D1D1)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.red.shade200.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _AgendaThumbnail(agenda: agenda),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  agenda.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7F1D1D),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        agenda.dateLabel,
                        style: const TextStyle(
                          color: Color(0xFF8A4A4A),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '❤️ ${agenda.likesCount}',
                      style: const TextStyle(
                        color: Color(0xFF8A4A4A),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AgendaThumbnail extends StatelessWidget {
  const _AgendaThumbnail({required this.agenda});

  final AgendaItem agenda;

  @override
  Widget build(BuildContext context) {
    if (agenda.hasImage) {
      return Container(
        height: 154,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              agenda.accent,
              Color.lerp(agenda.accent, Colors.white, 0.15) ?? agenda.accent,
            ],
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Agenda Kampus',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 154,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFFEE2E2), Color(0xFFFCA5A5)],
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.image_not_supported_outlined, size: 34, color: Color(0xFF991B1B)),
          SizedBox(height: 8),
          Text(
            'No Image',
            style: TextStyle(
              color: Color(0xFF991B1B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
