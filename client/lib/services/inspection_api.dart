import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

class InspectionApi {
  static String get _host => Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
  static String get _base => 'http://$_host:8000';

  static Future<Map<String, dynamic>> createInspection({
    required int gearId,
    required String inspectionDate,
    int? inspectorId,
    String? inspectionType,
    String? conditionNotes,
    String? result,
  }) async {
    final url = Uri.parse('$_base/inspections/');
    
    final body = {
      'gear_id': gearId,
      'inspection_date': inspectionDate,
      if (inspectorId != null) 'inspector_id': inspectorId,
      if (inspectionType != null && inspectionType.isNotEmpty) 'inspection_type': inspectionType,
      if (conditionNotes != null && conditionNotes.isNotEmpty) 'condition_notes': conditionNotes,
      if (result != null && result.isNotEmpty) 'result': result,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create inspection: ${response.statusCode} ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<List<Map<String, dynamic>>> getInspections() async {
    final url = Uri.parse('$_base/inspections/');
    final resp = await http.get(url);
    
    if (resp.statusCode != 200) {
      throw Exception('Failed to load inspections: ${resp.statusCode}');
    }
    
    final data = jsonDecode(resp.body) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }
}
