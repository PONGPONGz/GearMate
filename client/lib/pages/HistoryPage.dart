import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:gear_mate/pages/damage_report_page.dart';
import 'package:gear_mate/pages/inspection_log_page.dart';
import 'package:gear_mate/services/inspection_api.dart';
import 'package:gear_mate/services/gear_api.dart';
import 'package:gear_mate/services/firefighter_api.dart';
import 'package:intl/intl.dart';

class ServiceHistoryPage extends StatefulWidget {
  const ServiceHistoryPage({super.key});

  @override
  State<ServiceHistoryPage> createState() => _ServiceHistoryPageState();
}

class _ServiceHistoryPageState extends State<ServiceHistoryPage> {
  List<Map<String, dynamic>> _inspections = [];
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _gears = [];
  List<Map<String, dynamic>> _firefighters = [];

  @override
  void initState() {
    super.initState();
    _loadInspections();
    _loadGears();
    _loadFirefighters();
  }

  Future<void> _loadInspections() async {
    try {
      final inspections = await InspectionApi.getInspections();
      setState(() {
        _inspections = inspections;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEE, dd MMMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _loadGears() async {
    try {
      final gears = await GearApi.fetchGears('Name');
      setState(() {
        _gears = gears;
      });
    } catch (e) {
      // Silently ignore; cards fallback without image
    }
  }

  Future<void> _loadFirefighters() async {
    try {
      final people = await FirefighterApi.fetchFirefighters();
      setState(() {
        _firefighters = people;
      });
    } catch (e) {
      // Ignore for now; we'll show ID when name unavailable
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 3,
        selectedItemColor: Color(0xFFFF473F),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 1) {
            Navigator.pushNamed(context, DamageReportPage.route);
          } else if (index == 2) {
            Navigator.pushNamed(context, '/schedule');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Gear'),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: 'Report',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'History'),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header bar
            Container(
              width: double.infinity,
              color: const Color(0xFFFF473F),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: const Center(
                child: Text(
                  'Service History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Add button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    elevation: 4,
                  ),
                  onPressed: () async {
                    final result = await Navigator.pushNamed(context, InspectionLogPage.route);
                    if (result == true) {
                      _loadInspections(); // Refresh list after adding inspection
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Repair & Inspection',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Loading indicator
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),

            // Error message
            if (_error != null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error: $_error',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

            // List of service cards
            if (!_isLoading && _error == null)
              Expanded(
                child: _inspections.isEmpty
                    ? const Center(
                        child: Text(
                          'No inspections yet.\nAdd your first inspection!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _inspections.length,
                        itemBuilder: (context, index) {
                          final item = _inspections[index];
                          final gear = _gears.firstWhere(
                            (g) => g['id'] == item['gear_id'],
                            orElse: () => <String, dynamic>{},
                          );
                          final photoUrl = gear['photo_url'] as String?;
                          final inspector = _firefighters.firstWhere(
                            (f) => f['id'] == item['inspector_id'],
                            orElse: () => <String, dynamic>{},
                          );
                          final inspectorName = inspector['name'] as String?;
                          return Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                  Row(
                                    children: [
                                      _buildStatusChip(
                                        item['result'] ?? 'Pending',
                                        (item['result'] ?? 'Pending') == 'Passed'
                                            ? Colors.green[100]!
                                            : Colors.orange[100]!,
                                        (item['result'] ?? 'Pending') == 'Passed'
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                      const SizedBox(width: 8),
                                      _buildStatusChip(
                                        item['inspection_type'] ?? 'General',
                                        Colors.blue[100]!,
                                        Colors.blue,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Gear ID: ${item['gear_id']}${gear['gear_name'] != null ? ' | ${gear['gear_name']}' : ''}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                      Text(
                                        inspectorName != null
                                            ? 'Inspector: ID ${item['inspector_id']} - $inspectorName'
                                            : 'Inspector ID: ${item['inspector_id'] ?? 'N/A'}',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 6),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Inspection Date',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            _formatDate(item['inspection_date']),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (item['condition_notes'] != null &&
                                      (item['condition_notes'] as String).isNotEmpty)
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.edit_note_outlined,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Condition Notes',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              Text(
                                                item['condition_notes'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: _buildGearImage(photoUrl),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGearImage(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }
    // If backend returned relative path like /uploads/gears/xxx.jpg, prepend base
    String resolved = url;
    if (url.startsWith('/')) {
      final host = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
      resolved = 'http://$host:8000$url';
    }
    if (resolved.startsWith('http')) {
      return Image.network(
        resolved,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 80,
          height: 80,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.redAccent),
        ),
      );
    }
    // Treat as asset path
    return Image.asset(
      resolved,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
    );
  }

  Widget _buildStatusChip(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
