import 'package:flutter/material.dart';
import 'package:gear_mate/pages/damage_report_page.dart';

class ServiceHistoryPage extends StatelessWidget {
  const ServiceHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceList = [
      {
        'status1': 'Passed',
        'status2': 'Routine',
        'title': 'Fire Helmet',
        'id': 'FH-001 | Inspector 2',
        'date': 'Fri, 10 October 2025',
        'notes': 'Helmet clean and secure',
        'image': 'assets/images/FireHelmet.jpeg',
      },
      {
        'status1': 'Needs Repair',
        'status2': 'Repair',
        'title': 'Oxygen Tank',
        'id': 'OT-002 | Inspector 2',
        'date': 'Sun, 12 October 2025',
        'notes': 'Oxygen value leaking',
        'image': 'assets/images/OxygenTank.jpeg',
      },
    ];

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
                  onPressed: () {},
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

            // List of service cards
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: serviceList.length,
                itemBuilder: (context, index) {
                  final item = serviceList[index];
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
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _buildStatusChip(
                                      item['status1']!,
                                      item['status1'] == 'Passed'
                                          ? Colors.green[100]!
                                          : Colors.red[100]!,
                                      item['status1'] == 'Passed'
                                          ? Colors.green
                                          : Colors.redAccent,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildStatusChip(
                                      item['status2']!,
                                      Colors.blue[100]!,
                                      Colors.blue,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item['title']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  item['id']!,
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
                                          item['date']!,
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
                                            item['notes']!,
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
                          const SizedBox(width: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              item['image']!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
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
