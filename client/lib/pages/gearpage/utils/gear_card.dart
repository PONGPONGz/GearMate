import 'package:flutter/material.dart';
import 'package:gear_mate/widget/helper_widget.dart';

class GearCard extends StatelessWidget {
  final Widget typeChip;
  final Widget statusChip;
  final String title;
  final String subtitle;
  final String nextDateLabel;
  final String nextDate;
  final String footerText;
  final Widget image;

  const GearCard({
    super.key,
    required this.typeChip,
    required this.statusChip,
    required this.title,
    required this.subtitle,
    required this.nextDateLabel,
    required this.nextDate,
    required this.footerText,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF0F1A2A);
    const subColor = Color(0xFF6B7280);
    const divider = Color(0xFFE1E5EA);

    return Container(
      decoration: HelperWidget.cardDecoration(radius: 20),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ---------- TOP ROW ----------
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // LEFT: text block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [typeChip, statusChip],
                    ),
                    const SizedBox(height: 10),

                    // Title
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: titleColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Subtitle
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: subColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Next date block (icon + 2 lines)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/icons/ic_calendar.png',
                          width: 32,
                          height: 32,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nextDateLabel,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              nextDate,
                              style: const TextStyle(
                                color: subColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // RIGHT: image in white card with shadow
              _ImageFrame(width: 130, height: 110, child: image),
            ],
          ),

          const SizedBox(height: 12),

          // ---------- DIVIDER ----------
          const Divider(height: 1, thickness: 1, color: divider),

          const SizedBox(height: 10),

          // ---------- FOOTER ----------
          Align(
            alignment: Alignment.center,
            child: Text(
              footerText,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Color(0xFF8C95A3),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// กรอบรูปขาวมุมโค้ง + เงา (เหมือนภาพตัวอย่าง)
class _ImageFrame extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;

  const _ImageFrame({
    required this.width,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(12),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.08),
      //       blurRadius: 14,
      //       offset: const Offset(0, 8),
      //     ),
      //   ],
      // ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FittedBox(fit: BoxFit.contain, child: child),
      ),
    );
  }
}
