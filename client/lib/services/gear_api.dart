import 'dart:convert';
import 'dart:io' show Platform, File;
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class GearApi {
  // Determine base host for emulator vs local
  static String get _host {
    // Android emulator can't reach localhost directly
    if (Platform.isAndroid) return '10.0.2.2';
    return '127.0.0.1';
  }

  static String get _base => 'http://$_host:8000';
  static Uri _uri(String sortBy) => Uri.parse('$_base/gears?sort=$sortBy');

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

  /// Create a new gear. Returns created gear JSON.
  static Future<Map<String, dynamic>> createGear(
    Map<String, dynamic> payload,
  ) async {
    final uri = Uri.parse('$_base/gears/');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('Failed to create gear: ${resp.statusCode} ${resp.body}');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  /// Create a maintenance schedule for a gear (optional step after gear creation)
  static Future<Map<String, dynamic>> createSchedule({
    required int gearId,
    required DateTime scheduledDate,
  }) async {
    final uri = Uri.parse('$_base/schedules/');
    final body = {
      'gear_id': gearId,
      'scheduled_date': scheduledDate.toIso8601String().split('T').first,
    };
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception(
        'Failed to create schedule: ${resp.statusCode} ${resp.body}',
      );
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  /// Upload a photo for a gear
  static Future<Map<String, dynamic>> uploadGearPhoto({
    required int gearId,
    required File imageFile,
  }) async {
    final uri = Uri.parse('$_base/gears/$gearId/upload-photo');

    var request = http.MultipartRequest('POST', uri);

    // Detect MIME type
    final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
    final mimeTypeParts = mimeType.split('/');

    // Add the file to the request
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType(mimeTypeParts[0], mimeTypeParts[1]),
      ),
    );

    // Send the request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to upload photo: ${response.statusCode} ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
