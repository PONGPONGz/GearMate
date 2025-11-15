import 'package:flutter/material.dart';
// Fixed imports: use existing homepage (gear list) and schedule page widgets
import 'package:gear_mate/pages/homepage.dart';
import 'package:gear_mate/pages/SchedulePage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeSwitcherState();
}

class _HomeSwitcherState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const coral = Color(0xFFE85A4F);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        // Use the actual widget classes present in the project.
        children: [homepage(), schedulepage()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: coral,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.build_rounded),
            label: 'Gear',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Schedule',
          ),
        ],
      ),
    );
  }
}
