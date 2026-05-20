import 'package:flutter/material.dart';

import '../models/agenda_item.dart';
import 'stat_chip.dart';

class PopularAgendaCard extends StatelessWidget {
  const PopularAgendaCard({required this.agenda, super.key});

  final AgendaItem agenda;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFB91C1C), Color(0xFF7F1D1D)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF7F1D1D).withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Sedang Hangat Dibicarakan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            agenda.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            agenda.description ?? '',
            style: const TextStyle(
              color: Color(0xFFFDE8E8),
              height: 1.55,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              StatChip(icon: Icons.favorite_border, label: '${agenda.likesCount} Likes'),
              const SizedBox(width: 10),
              StatChip(
                icon: Icons.chat_bubble_outline,
                label: '${agenda.commentsCount ?? 0} Komentar',
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            children: <Widget>[
              Icon(Icons.chevron_right, color: Colors.white),
              SizedBox(width: 6),
              Text(
                'Lihat detail agenda',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
