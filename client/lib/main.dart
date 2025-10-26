// lib/main.dart
import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'data/reminder_api.dart';
import 'pages/homepage.dart';
import 'add_maintenance_schedule_page.dart';
import 'pages/AddNewGear.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();

  // ===================================================
  // REAL DAILY REMINDER (08:00 Bangkok)
  // ===================================================
  await NotificationService.instance.scheduleDailyMorning(
    hour: 8,
    minute: 0,
    body: "Don't forget to check your gear and maintenance schedule!",
  );

  // ===================================================
  // REAL DB REMINDERS
  // ===================================================
  try {
    final reminders = await ReminderApi.getAll();
    final now = DateTime.now();
    int baseId = 20000; // keep away from other IDs

    debugPrint('DB reminders fetched: ${reminders.length}');

    // Sort by date+time (with seconds)
    reminders.sort((a, b) {
      DateTime toDt(r) {
        final d = r.reminderDate ?? DateTime(2100);
        final t = r.reminderTime ?? '00:00:00';
        final p = t.split(':');
        final hh = int.tryParse(p[0]) ?? 0;
        final mm = int.tryParse(p[1]) ?? 0;
        final ss = int.tryParse(p.length > 2 ? p[2] : '0') ?? 0;
        return DateTime(d.year, d.month, d.day, hh, mm, ss);
      }

      return toDt(a).compareTo(toDt(b));
    });

    for (final r in reminders) {
      if (r.reminderDate == null || r.reminderTime == null) {
        debugPrint('Skip reminder id=${r.id} (missing date/time)');
        continue;
      }

      final parts = r.reminderTime!.split(':'); // HH:MM:SS
      final hh = int.tryParse(parts[0]) ?? 9;
      final mm = int.tryParse(parts[1]) ?? 0;
      final ss = int.tryParse(parts.length > 2 ? parts[2] : '0') ?? 0;

      final whenLocal = DateTime(
        r.reminderDate!.year,
        r.reminderDate!.month,
        r.reminderDate!.day,
        hh,
        mm,
        ss,
      );

      if (whenLocal.isBefore(now)) {
        debugPrint('Skip past reminder id=${r.id} at $whenLocal');
        continue;
      }

      debugPrint('Schedule reminder id=${r.id} at $whenLocal');
      await NotificationService.instance.scheduleOneShot(
        id: baseId + r.id,
        whenLocal: whenLocal,
        title: 'Maintenance Reminder',
        body: r.message ?? 'Scheduled maintenance reminder',
      );
    }
  } catch (e) {
    debugPrint('Failed to fetch/schedule DB reminders: $e');
  }

  runApp(const GearMateApp());
}

class GearMateApp extends StatelessWidget {
  const GearMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    const coral = Color(0xFFE85A4F);
    return MaterialApp(
      title: 'GearMate',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => homepage(),
        '/schedule': (context) => const AddMaintenanceSchedulePage(),
        '/addgear': (context) => addnewgearpage(),
      },
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: coral,
        scaffoldBackgroundColor: const Color(0xFFF5F6F8),
        fontFamily: 'SF Pro',
        colorScheme: ColorScheme.fromSeed(seedColor: coral, primary: coral),
      ),
    );
  }
}