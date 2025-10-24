import 'package:flutter/material.dart';

class LegendRow extends StatelessWidget {
  const LegendRow({super.key});

  @override
  Widget build(BuildContext context) {
    Widget dot(Color c) => Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );
    Widget item(Color c, String t) => Row(
      children: [
        dot(c),
        const SizedBox(width: 6),
        Text(t, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        item(const Color(0xFFD6D1CF), 'Today'),
        const SizedBox(width: 16),
        item(const Color(0xFF577BFF), 'Selected Day'),
        const SizedBox(width: 16),
        item(const Color(0xFFF1A344), 'Maintenance Needed'),
      ],
    );
  }
}
