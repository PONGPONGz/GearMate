import 'package:flutter/material.dart';
import 'package:gear_mate/services/gear_api.dart';

class homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<homepage> {
  String _sortOption = 'Name';
  bool _loading = false;
  String? _error;

  List<Map<String, dynamic>> gearList = [];

  @override
  void initState() {
    super.initState();
    _fetchGears(_sortOption);
  }

  Future<void> _fetchGears(String sortBy) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final gears = await GearApi.fetchGears(sortBy);
      // Map API fields to UI fields
      final mapped =
          gears.map<Map<String, dynamic>>((g) {
            return {
              'type': g['equipment_type'] ?? 'Unknown',
              'name': g['gear_name'] ?? 'Unnamed',
              'id': g['serial_number'] ?? (g['id']?.toString() ?? ''),
              'station': 'Station ${g['station_id'] ?? ''}',
              // Using expiry_date as next maintenance proxy to avoid schema change
              'nextMaintenance': g['maintenance_date'] ?? 'N/A',
              'purchase': g['purchase_date'] ?? 'N/A',
              'expiry': g['expiry_date'] ?? 'N/A',
              'image': g['photo_url'] ?? '',
            };
          }).toList();
      setState(() {
        _sortOption = sortBy;
        gearList = mapped;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _sortGearList(String option) {
    // Delegate sorting to server
    _fetchGears(option);
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
                        onPressed: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/addgear',
                          );
                          if (result == true) {
                            _fetchGears(_sortOption);
                          }
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

            if (_loading) const LinearProgressIndicator(minHeight: 2),

            // Errors / Loading
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: \'${_error}\'',
                  style: const TextStyle(color: Colors.red),
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
                          // type, and details
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
                              child:
                                  (gear['image'] != null &&
                                          (gear['image'] as String).startsWith(
                                            'http',
                                          ))
                                      ? Image.network(
                                        gear['image'],
                                        fit: BoxFit.cover,
                                      )
                                      : Image.asset(
                                        (gear['image'] as String).isNotEmpty
                                            ? gear['image']
                                            : 'assets/images/GearMate.png',
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
