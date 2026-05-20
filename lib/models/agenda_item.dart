import 'package:flutter/material.dart';

class AgendaItem {
  const AgendaItem({
    required this.title,
    required this.dateLabel,
    required this.likesCount,
    this.commentsCount,
    this.description,
    this.hasImage = false,
    this.accent = const Color(0xFFB91C1C),
  });

  final String title;
  final String dateLabel;
  final int likesCount;
  final int? commentsCount;
  final String? description;
  final bool hasImage;
  final Color accent;
}
