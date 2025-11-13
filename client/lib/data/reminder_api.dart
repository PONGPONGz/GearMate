// lib/data/reminder_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class MaintenanceReminder {
  final int id;
  final int gearId;
  final DateTime? reminderDate; 
  final String? reminderTime;  
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

  static String? _normalizeTime(String? s) {
    if (s == null) return null;
    final m = RegExp(r'(\d{2}):(\d{2}):(\d{2})').firstMatch(s);
    if (m == null) return null;
    return '${m.group(1)}:${m.group(2)}:${m.group(3)}';
  }

  factory MaintenanceReminder.fromJson(Map<String, dynamic> j) {
    DateTime? d;
    if (j['reminder_date'] != null) {
      // Backend sends 'YYYY-MM-DD'
      d = DateTime.parse(j['reminder_date']);
    }

    return MaintenanceReminder(
      id: j['id'] as int,
      gearId: j['gear_id'] as int,
      reminderDate: d,
      reminderTime: _normalizeTime(j['reminder_time'] as String?),
      message: j['message'] as String?,
      sent: (j['sent'] as bool?) ?? false,
    );
  }
}

class ReminderApi {
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<List<MaintenanceReminder>> getAll() async {
    final url = Uri.parse('$baseUrl/reminders/');
    final res = await http.get(url, headers: {'Accept': 'application/json'});
    if (res.statusCode != 200) {
      throw Exception('GET /reminders failed: ${res.statusCode} ${res.body}');
    }
    final List data = jsonDecode(res.body) as List;
    return data
        .map((e) => MaintenanceReminder.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}