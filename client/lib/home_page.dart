import 'package:flutter/material.dart';
import 'package:gear_mate/pages/gearpage/gear_page.dart';
import 'package:gear_mate/pages/schedulepage/schedule_page.dart';

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
        children: const [GearPage(), SchedulePage()],
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
