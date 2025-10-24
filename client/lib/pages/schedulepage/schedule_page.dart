import 'package:flutter/material.dart';
import 'package:gear_mate/widget/helper_widget.dart';
import 'package:gear_mate/add_maintenance_schedule_page.dart';

import '../../utils/helper_widget.dart';
import '../../widget/calendar_card.dart';
import '../../widget/legend_row.dart';
import '../../widget/pill_widget.dart';
import '../gearpage/utils/gear_images.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  int selectedDay = 1;

  @override
  Widget build(BuildContext context) {
    const coral = Color(0xFFE85A4F);
    return SafeArea(
      child: Column(
        children: [
          // Header (แถบแดง + ชื่อ)
          Container(
            color: coral,
            height: 64,
            alignment: Alignment.center,
            child: const Text(
              'Maintenance Schedule',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),

          // Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              children: [
                CalendarCard(
                  monthTitle: 'November 2025',
                  selected: selectedDay,
                  onSelect: (d) => setState(() => selectedDay = d),
                ),
                const SizedBox(height: 14),
                LegendRow(),
                const SizedBox(height: 48),
                Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Task List',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: Color(0xFF0F1A2A),
                          ),
                        ),
                        const Text(
                          '1 task due that day',
                          style: TextStyle(color: Colors.black45, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    const Spacer(),
                    _roundToolIcon(Icons.tune_rounded),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => const AddMaintenanceSchedulePage(),
                          ),
                        );
                      },
                      child: _roundToolIcon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                Container(
                  decoration: HelperWidget.cardDecoration(radius: 22),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              children: const [
                                Pill(
                                  text: 'Helmet',
                                  bg: Color(0xFFE9ECEF),
                                  fg: Color(0xFF606A76),
                                ),
                                Pill(
                                  text: 'Monthly',
                                  bg: Color(0xFFE6EFFA),
                                  fg: Color(0xFF2F5DAA),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            const Text(
                              'Fire Helmet',
                              style: TextStyle(
                                color: Color(0xFF0F1A2A),
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 4),

                            const Text(
                              'FH-001 | Station 1',
                              style: TextStyle(
                                color: Color(0xFF9AA2AE),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // ------- DATE BLOCK (icon "ห้อย" ซ้าย) -------
                            SizedBox(
                              height: 40,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // ไอคอนปฏิทิน 32px วางชิดซ้าย
                                  Positioned(
                                    left: 0,
                                    top: 4,
                                    child: Image.asset(
                                      'assets/icons/ic_calendar.png',
                                      width: 32,
                                      height: 32,
                                    ),
                                  ),
                                  // ข้อความขยับขวา 44 = 32 (icon) + 12 (gap)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 44),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Scheduled Date',
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Sat, 1 November 2025',
                                          style: TextStyle(
                                            color: Color(0xFF8C95A3),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // ------ RIGHT IMAGE ------
                      GearImage(kind: GearIllustration.helmet, big: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _roundToolIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: HelperWidget.cardDecoration(shapeCircle: true),
      child: Icon(icon, color: Colors.black87, size: 22),
    );
  }
}
