// lib/data/reminder_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class MaintenanceReminder {
  final int id;
  final int gearId;
  final DateTime? reminderDate; // date only
  final String? reminderTime;   // 'HH:MM:SS' from API
  final String? message;
  final bool sent;

  MaintenanceReminder({
    required this.id,
    required this.gearId,
    required this.reminderDate,
    required this.reminderTime,
    required this.message,
    required this.sent,
  });

  factory MaintenanceReminder.fromJson(Map<String, dynamic> j) {
    // reminder_date is 'YYYY-MM-DD' or null
    DateTime? d;
    if (j['reminder_date'] != null) {
      d = DateTime.parse(j['reminder_date']);
    }
    return MaintenanceReminder(
      id: j['id'] as int,
      gearId: j['gear_id'] as int,
      reminderDate: d,
      reminderTime: j['reminder_time'] as String?,
      message: j['message'] as String?,
      sent: (j['sent'] as bool?) ?? false,
    );
  }
}

class ReminderApi {
  // Change to your actual base URL / port
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator to local FastAPI

  static Future<List<MaintenanceReminder>> getAll() async {
    final url = Uri.parse('$baseUrl/reminders/');
    final res = await http.get(url, headers: {'Accept': 'application/json'});
    if (res.statusCode != 200) {
      throw Exception('GET /reminders failed: ${res.statusCode} ${res.body}');
    }
    final List data = jsonDecode(res.body) as List;
    return data.map((e) => MaintenanceReminder.fromJson(e as Map<String, dynamic>)).toList();
  }
}