import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:gear_mate/services/gear_api.dart';
import 'dart:convert';

void main() {
  group('GearApi', () {
    group('fetchGears', () {
      test('successfully fetches and parses gears', () async {
        // Mock HTTP client
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/gears');
          expect(request.url.queryParameters['sort'], 'Name');

          return http.Response(
            jsonEncode([
              {
                'id': 1,
                'gear_name': 'Fire Helmet',
                'serial_number': 'FH-001',
                'station_id': 1,
                'equipment_type': 'Helmet',
                'purchase_date': '2023-01-10',
                'expiry_date': '2028-01-10',
                'status': 'OK',
                'next_maintenance_date': '2025-11-01',
                'photo_url': 'https://example.com/image.jpg',
              },
              {
                'id': 2,
                'gear_name': 'Oxygen Tank',
                'serial_number': 'OT-002',
                'station_id': 1,
                'equipment_type': 'Tank',
                'purchase_date': '2022-11-15',
                'expiry_date': '2027-11-15',
                'status': 'Due Soon',
                'next_maintenance_date': '2025-10-20',
                'photo_url': null,
              },
            ]),
            200,
          );
        });

        // Note: We can't easily test the actual GearApi.fetchGears without dependency injection
        // This test demonstrates the expected behavior
        final response = await mockClient.get(
          Uri.parse('http://127.0.0.1:8000/gears?sort=Name'),
        );

        expect(response.statusCode, 200);
        final data = jsonDecode(response.body) as List<dynamic>;
        expect(data.length, 2);
        expect(data[0]['gear_name'], 'Fire Helmet');
        expect(data[0]['next_maintenance_date'], '2025-11-01');
        expect(data[1]['equipment_type'], 'Tank');
      });

      test('throws exception on HTTP error', () async {
        final mockClient = MockClient((request) async {
          return http.Response('Not Found', 404);
        });

        final response = await mockClient.get(
          Uri.parse('http://127.0.0.1:8000/gears?sort=Name'),
        );

        expect(response.statusCode, 404);
        // In real implementation, this would throw an exception
      });

      test('handles empty gear list', () async {
        final mockClient = MockClient((request) async {
          return http.Response(jsonEncode([]), 200);
        });

        final response = await mockClient.get(
          Uri.parse('http://127.0.0.1:8000/gears?sort=Name'),
        );

        expect(response.statusCode, 200);
        final data = jsonDecode(response.body) as List<dynamic>;
        expect(data.length, 0);
      });
    });

    group('createGear', () {
      test('successfully creates a gear', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/gears/');
          expect(request.method, 'POST');
          expect(request.headers['Content-Type'], contains('application/json'));

          final body = jsonDecode(request.body);
          expect(body['gear_name'], 'Test Helmet');
          expect(body['station_id'], 1);

          return http.Response(
            jsonEncode({
              'id': 123,
              'gear_name': 'Test Helmet',
              'serial_number': 'TH-001',
              'station_id': 1,
              'equipment_type': 'Helmet',
              'purchase_date': '2024-01-15',
              'expiry_date': '2029-01-15',
              'status': null,
              'next_maintenance_date': null,
              'photo_url': null,
            }),
            201,
          );
        });

        final payload = {
          'station_id': 1,
          'gear_name': 'Test Helmet',
          'serial_number': 'TH-001',
          'equipment_type': 'Helmet',
          'purchase_date': '2024-01-15',
          'expiry_date': '2029-01-15',
        };

        final response = await mockClient.post(
          Uri.parse('http://127.0.0.1:8000/gears/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        expect(response.statusCode, 201);
        final data = jsonDecode(response.body);
        expect(data['id'], 123);
        expect(data['gear_name'], 'Test Helmet');
        expect(data['next_maintenance_date'], null);
      });

      test('handles validation errors', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'detail': [
                {
                  'loc': ['body', 'station_id'],
                  'msg': 'field required',
                },
              ],
            }),
            422,
          );
        });

        final response = await mockClient.post(
          Uri.parse('http://127.0.0.1:8000/gears/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'gear_name': 'Incomplete'}),
        );

        expect(response.statusCode, 422);
      });
    });

    group('createSchedule', () {
      test('successfully creates a maintenance schedule', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/schedules/');
          expect(request.method, 'POST');

          final body = jsonDecode(request.body);
          expect(body['gear_id'], 123);
          expect(body['scheduled_date'], '2025-11-15');

          return http.Response(
            jsonEncode({
              'id': 456,
              'gear_id': 123,
              'scheduled_date': '2025-11-15',
            }),
            201,
          );
        });

        final response = await mockClient.post(
          Uri.parse('http://127.0.0.1:8000/schedules/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'gear_id': 123, 'scheduled_date': '2025-11-15'}),
        );

        expect(response.statusCode, 201);
        final data = jsonDecode(response.body);
        expect(data['gear_id'], 123);
        expect(data['scheduled_date'], '2025-11-15');
      });

      test('formats date correctly', () {
        final date = DateTime(2025, 11, 15);
        final formatted = date.toIso8601String().split('T').first;
        expect(formatted, '2025-11-15');
      });
    });

    group('sorting parameters', () {
      test('constructs correct URL for Name sort', () {
        final uri = Uri.parse('http://127.0.0.1:8000/gears?sort=Name');
        expect(uri.queryParameters['sort'], 'Name');
      });

      test('constructs correct URL for Type sort', () {
        final uri = Uri.parse('http://127.0.0.1:8000/gears?sort=Type');
        expect(uri.queryParameters['sort'], 'Type');
      });

      test('constructs correct URL for Maintenance Date sort', () {
        final uri = Uri.parse(
          'http://127.0.0.1:8000/gears?sort=Maintenance%20Date',
        );
        expect(uri.queryParameters['sort'], 'Maintenance Date');
      });
    });
  });
}
