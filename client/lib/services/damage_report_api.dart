import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class DamageReportApi {
  static String get _baseUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000';
  }

  static Future<Map<String, dynamic>> createDamageReport({
    required int gearId,
    required String reportDate,
    String? reporterName,
    String? notes,
    String? photoUrl,
  }) async {
    final url = Uri.parse('$_baseUrl/damage-reports/');
    
    final body = {
      'gear_id': gearId,
      'report_date': reportDate,
      if (reporterName != null && reporterName.isNotEmpty) 'reporter_name': reporterName,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (photoUrl != null && photoUrl.isNotEmpty) 'photo_url': photoUrl,
      'status': 'pending',
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create damage report: ${response.statusCode} ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllDamageReports() async {
    final url = Uri.parse('$_baseUrl/damage-reports/');
    
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch damage reports: ${response.statusCode}');
    }
  }
}
