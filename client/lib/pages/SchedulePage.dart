import 'package:flutter/material.dart';

class schedulepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule'),
      ),
      body: Center(
        child: Text('Schedule content goes here'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
        selectedItemColor: Color(0xFFFF473F),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 1) {
            Navigator.pushNamed(context, '/damage');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/servicehistory');
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
    );
  }
}
