import 'package:flutter/material.dart';

class Pill extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color bg;
  final Color fg;

  const Pill({
    super.key,
    required this.text,
    this.icon,
    required this.bg,
    required this.fg,
  });

  const Pill.leadingIcon({
    super.key,
    required this.text,
    required IconData icon,
    required this.bg,
    required this.fg,
  }) : icon = icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bg.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}
