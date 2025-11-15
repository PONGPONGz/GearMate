import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

class FirefighterApi {
  static String get _host => Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
  static String get _base => 'http://$_host:8000';

  // Fetch all firefighters
  static Future<List<Map<String, dynamic>>> fetchFirefighters() async {
    final uri = Uri.parse('$_base/firefighters/');
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Failed to load firefighters: ${resp.statusCode}');
    }
    final data = jsonDecode(resp.body) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }
}
