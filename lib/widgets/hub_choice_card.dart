import 'package:flutter/material.dart';

class HubChoiceCard extends StatelessWidget {
  const HubChoiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Container(
          height: 352,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFF3D1D1)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.red.shade100.withValues(alpha: 0.25),
                blurRadius: 28,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 128,
                height: 128,
                decoration: const BoxDecoration(
                  color: Color(0xFFFCE8E8),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 74, color: const Color(0xFFB91C1C)),
              ),
              const SizedBox(height: 28),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF8A2222),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.55,
                  color: Color(0xFF6E7488),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
