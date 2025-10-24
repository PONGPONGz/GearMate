import 'package:flutter/material.dart';


class homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<homepage> {
  String _sortOption = 'Name';

  List<Map<String, dynamic>> gearList = [
    {
      'type': 'Helmet',
      'status': 'OK',
      'name': 'Fire Helmet',
      'id': 'FH-001',
      'station': 'Station 1',
      'nextMaintenance': 'Sat, 1 November 2025',
      'purchase': '2023-01-10',
      'expiry': '2028-01-10',
      'image': 'assets/images/FireHelmet.jpeg',
    },
    {
      'type': 'Tank',
      'status': 'Due Soon',
      'name': 'Oxygen Tank',
      'id': 'OT-002',
      'station': 'Station 1',
      'nextMaintenance': 'Mon, 20 October 2025',
      'purchase': '2022-11-15',
      'expiry': '2027-11-15',
      'image': 'assets/images/OxygenTank.jpeg',
    },
    {
      'type': 'Nozzle',
      'status': 'Needs Service',
      'name': 'Fire Hose',
      'id': 'FH-003',
      'station': 'Station 2',
      'nextMaintenance': 'Sat, 25 October 2025',
      'purchase': '2023-06-01',
      'expiry': '2026-06-01',
      'image': 'assets/images/FireHose.webp',
    },
  ];

  void _sortGearList(String option) {
    setState(() {
      _sortOption = option;
      if (option == 'Name') {
        gearList.sort((a, b) => a['name'].compareTo(b['name']));
      } else if (option == 'Type') {
        gearList.sort((a, b) => a['type'].compareTo(b['type']));
      } else if (option == 'Maintenance Date') {
        gearList.sort(
          (a, b) => a['nextMaintenance'].compareTo(b['nextMaintenance']),
        );
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'OK':
        return Colors.green;
      case 'Due Soon':
        return Colors.orange;
      case 'Needs Service':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Color(0xFFFF473F),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/schedule');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Gear'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Color(0xFFFF473F),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/GearMate.png',
                            width: 45,
                            height: 45,
                          ),
                          const SizedBox(
                            width: 5,
                          ), // small spacing between image and text
                          const Text(
                            'GearMate',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: const [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.notifications_active_outlined,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 8), // spacing between icons
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person_outline_outlined,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // search bar and sort button
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Search by gear name, ID, or type',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Sort button
                      const SizedBox(width: 10),
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 20,
                        child: PopupMenuButton<String>(
                          onSelected: _sortGearList,
                          itemBuilder:
                              (context) => [
                                PopupMenuItem(
                                  value: 'Name',
                                  child: Text('Sort by Name'),
                                ),
                                PopupMenuItem(
                                  value: 'Type',
                                  child: Text('Sort by Type'),
                                ),
                                PopupMenuItem(
                                  value: 'Maintenance Date',
                                  child: Text('Sort by Maintenance Date'),
                                ),
                              ],
                          icon: Icon(
                            Icons.format_list_bulleted_sharp,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Sort & Add
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Gear List',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/addgear');
                        },
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text(
                          'Add new gear',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Gear List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: gearList.length,
                itemBuilder: (context, index) {
                  var gear = gearList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // type, status, and details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        gear['type'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(gear['status']),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        gear['status'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  gear['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: const Color.fromARGB(
                                      255,
                                      22,
                                      28,
                                      64,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${gear['id']} | ${gear['station']}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 35,
                                      color: const Color.fromARGB(
                                        255,
                                        22,
                                        28,
                                        64,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Next Maintenance Date',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: const Color.fromARGB(
                                                255,
                                                22,
                                                28,
                                                64,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            gear['nextMaintenance'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: const Color.fromARGB(
                                                255,
                                                90,
                                                90,
                                                90,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Divider(color: Colors.grey[400], thickness: 3),
                                const SizedBox(height: 4),
                                Text(
                                  'Purchase: ${gear['purchase']} | Expiry: ${gear['expiry']}',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: Image.asset(
                                gear['image'],
                                fit: BoxFit.cover,
                              ),
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
}
