import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

class GearApi {
  // Determine base host for emulator vs local
  static String get _host {
    // Android emulator can't reach localhost directly
    if (Platform.isAndroid) return '10.0.2.2';
    return '127.0.0.1';
  }

  static Uri _uri(String sortBy) =>
      Uri.parse('http://$_host:8000/gears?sort=$sortBy');

  /// Fetch gears from API, sorted by one of: Name, Type, Maintenance Date
  static Future<List<Map<String, dynamic>>> fetchGears(String sortBy) async {
    final resp = await http.get(_uri(sortBy));
    if (resp.statusCode != 200) {
      throw Exception('Failed to load gears: ${resp.statusCode}');
    }
    final data = jsonDecode(resp.body) as List<dynamic>;
    // Each element is a Gear model from API
    return data.cast<Map<String, dynamic>>();
  }
}
