import 'package:flutter/material.dart';

import '../models/agenda.dart';

class AgendaListCard extends StatelessWidget {
  const AgendaListCard({required this.agenda, required this.onTap, Key? key}) : super(key: key);

  final Agenda agenda;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: agenda.imageUrl != null
                  ? Image.network(
                      agenda.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_outlined,
                        color: Color(0xFF9CA3AF),
                        size: 40,
                      ),
                    )
                  : const Icon(
                      Icons.image_outlined,
                      color: Color(0xFF9CA3AF),
                      size: 40,
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        agenda.kategori,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC41C1C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      agenda.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7F1D1D),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 12,
                              color: Color(0xFF8A4A4A),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              agenda.formatTanggal,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8A4A4A),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.favorite_outline,
                              size: 12,
                              color: Color(0xFFC41C1C),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              agenda.likes.toString(),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFC41C1C),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.comment_outlined,
                              size: 12,
                              color: Color(0xFF8A4A4A),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              agenda.comments.toString(),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8A4A4A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
