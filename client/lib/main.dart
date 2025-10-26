import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'data/reminder_api.dart';
import 'pages/homepage.dart';
import 'add_maintenance_schedule_page.dart';
import 'pages/AddNewGear.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();

  // Schedule daily 08:00 reminder (Bangkok)
  await NotificationService.instance.scheduleDailyMorning(
    hour: 8,
    minute: 0,
    body: "Don't forget to check your gear and maintenance schedule!",
  );

  // Schedule DB-driven reminders
  try {
    final reminders = await ReminderApi.getAll();
    final now = DateTime.now();
    int baseId = 20000; // keep away from other IDs

    // Optional: sort by date/time for readability
    reminders.sort((a, b) {
      final da = a.reminderDate ?? DateTime(2100);
      final db = b.reminderDate ?? DateTime(2100);
      final ta = a.reminderTime ?? '00:00:00';
      final tb = b.reminderTime ?? '00:00:00';
      final aa = DateTime(
        da.year,
        da.month,
        da.day,
        int.parse(ta.split(':')[0]),
        int.parse(ta.split(':')[1]),
      );
      final bb = DateTime(
        db.year,
        db.month,
        db.day,
        int.parse(tb.split(':')[0]),
        int.parse(tb.split(':')[1]),
      );
      return aa.compareTo(bb);
    });

    for (final r in reminders) {
      if (r.reminderDate == null || r.reminderTime == null) {
        continue;
      }

      final parts = r.reminderTime!.split(':'); // HH:MM:SS
      final hh = int.tryParse(parts[0]) ?? 9;
      final mm = int.tryParse(parts[1]) ?? 0;
      final ss = int.tryParse(parts[2]) ?? 0;

      final whenLocal = DateTime(
        r.reminderDate!.year,
        r.reminderDate!.month,
        r.reminderDate!.day,
        hh,
        mm,
        ss,
      );

      if (whenLocal.isBefore(now)) {
        continue;
      }

      await NotificationService.instance.scheduleOneShot(
        id: baseId + r.id,
        whenLocal: whenLocal,
        title: 'Maintenance Reminder',
        body: r.message ?? 'Scheduled maintenance reminder',
      );
    }
  } catch (e) {
    // Keep app alive even if API is down
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
      // theme: ThemeData(primaryColor: Color(0xFFFF473F), fontFamily: 'WorkSan'),
      // home: homepage(),
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
