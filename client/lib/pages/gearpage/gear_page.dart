import 'package:flutter/material.dart';
import 'package:gear_mate/pages/gearpage/utils/gear_card.dart';
import 'package:gear_mate/pages/gearpage/utils/gear_images.dart';
import 'package:gear_mate/widget/helper_widget.dart';
import 'package:gear_mate/add_maintenance_schedule_page.dart';

import '../../utils/helper_widget.dart';
import '../../widget/pill_widget.dart';

class GearPage extends StatelessWidget {
  const GearPage({super.key});

  @override
  Widget build(BuildContext context) {
    const coral = Color(0xFFE85A4F);
    return SafeArea(
      top: false,
      child: Column(
        children: [
          // Header
          Container(
            color: coral,
            padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/image_fire_alarm.png',
                      height: 32,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'GearMate',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                    const Spacer(),
                    _circleIcon(Icons.notifications_none_rounded),
                    const SizedBox(width: 10),
                    _circleIcon(Icons.person_outline_rounded),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _SearchField(
                        hint: 'Search by gear name, ID, or type',
                      ),
                    ),
                    const SizedBox(width: 10),
                    _circleIcon(Icons.tune_rounded),
                  ],
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              children: [
                Row(
                  children: [
                    const Text(
                      'My Gear List',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F1A2A),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => const AddMaintenanceSchedulePage(),
                          ),
                        );
                      },
                      child: const Text('+ Add new gear'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Card 1
                GearCard(
                  typeChip: Pill(
                    text: 'Helmet',
                    bg: const Color(0xFFEFF6FF),
                    fg: const Color(0xFF6B7AFF),
                  ),
                  statusChip: Pill.leadingIcon(
                    text: 'OK',
                    icon: Icons.check_circle,
                    bg: const Color(0xFFE7F7EF),
                    fg: const Color(0xFF1E8E5B),
                  ),
                  title: 'Fire Helmet',
                  subtitle: 'FH-001 | Station 1',
                  nextDateLabel: 'Next Maintenance Date',
                  nextDate: 'Sat, 1 November 2025',
                  footerText: 'Purchase: 2023-01-10 | Expiry: 2028-01-10',
                  image: GearImage(kind: GearIllustration.helmet),
                ),
                const SizedBox(height: 14),

                // Card 2
                GearCard(
                  typeChip: Pill(
                    text: 'Tank',
                    bg: const Color(0xFFFFF7EC),
                    fg: const Color(0xFF8A5B0A),
                  ),
                  statusChip: Pill.leadingIcon(
                    text: 'Due Soon',
                    icon: Icons.warning_amber_rounded,
                    bg: const Color(0xFFFFF3E0),
                    fg: const Color(0xFFB5700A),
                  ),
                  title: 'Oxygen Tank',
                  subtitle: 'OT-002 | Station 1',
                  nextDateLabel: 'Next Maintenance Date',
                  nextDate: 'Mon, 20 October 2025',
                  footerText: 'Purchase: 2022-11-15 | Expiry: 2027-11-15',
                  image: GearImage(kind: GearIllustration.tank),
                ),
                const SizedBox(height: 14),

                // Card 3
                GearCard(
                  typeChip: Pill(
                    text: 'Nozzle',
                    bg: const Color(0xFFF1F5F9),
                    fg: const Color(0xFF1F2937),
                  ),
                  statusChip: Pill.leadingIcon(
                    text: 'Needs Service',
                    icon: Icons.error_outline_rounded,
                    bg: const Color(0xFFFFEBEE),
                    fg: const Color(0xFFB00020),
                  ),
                  title: 'Fire Hose',
                  subtitle: 'FH-003 | Station 2',
                  nextDateLabel: 'Next Maintenance Date',
                  nextDate: 'Sat, 25 October 2025',
                  footerText: 'Purchase: 2023-06-01 | Expiry: 2023-06-01',
                  image: const GearImage(kind: GearIllustration.hose),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _circleIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Colors.white24,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}

class _SearchField extends StatelessWidget {
  final String hint;

  const _SearchField({required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: HelperWidget.cardDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.black45),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
