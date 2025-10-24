import 'package:flutter/material.dart';
import 'package:gear_mate/widget/helper_widget.dart';
import 'package:gear_mate/widget/week_header.dart';

class CalendarCard extends StatelessWidget {
  final String monthTitle;
  final int selected;
  final void Function(int day) onSelect;

  const CalendarCard({
    super.key,
    required this.monthTitle,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    // ปฏิทินจำลอง November 2025 (วัน 1 เริ่มที่ WED)
    final days = List.generate(30, (i) => i + 1);
    const startWeekdayIndex = 3; // 0=SUN, 3=WED
    final cells = List<int?>.filled(startWeekdayIndex, null, growable: true)
      ..addAll(days);

    // ใส่จุดสีส้มในบางวันตามภาพ
    const orangeDots = {17, 20, 27};

    return Container(
      decoration: HelperWidget.cardDecoration(radius: 16),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                monthTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              _miniNavBtn(Icons.chevron_left),
              const SizedBox(width: 8),
              _miniNavBtn(Icons.chevron_right),
            ],
          ),
          const SizedBox(height: 8),
          const WeekHeader(),
          const SizedBox(height: 6),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: ((cells.length / 7).ceil()) * 7,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 40,
            ),
            itemBuilder: (context, index) {
              final day = index < cells.length ? cells[index] : null;
              if (day == null) return const SizedBox.shrink();

              final isSelected = day == selected;
              return GestureDetector(
                onTap: () => onSelect(day),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? const Color(0xFF577BFF)
                                : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$day',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (orangeDots.contains(day))
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1A344),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static Widget _miniNavBtn(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: HelperWidget.cardDecoration(shapeCircle: true),
      child: Icon(icon, size: 20, color: Colors.black87),
    );
  }
}
