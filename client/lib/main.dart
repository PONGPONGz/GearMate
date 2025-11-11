import 'package:flutter/material.dart';
import 'pages/homepage.dart';
import 'pages/SchedulePage.dart';
import 'pages/AddNewGear.dart';
import 'pages/HistoryPage.dart';

void main() {
  runApp(GearMateApp());
}

class GearMateApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GearMate',
      theme: ThemeData(primaryColor: Color(0xFFFF473F), fontFamily: 'WorkSan'),
      // home: homepage(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => homepage(),
        '/schedule': (context) => schedulepage(),
        '/addgear': (context) => addnewgearpage(),
        '/servicehistory': (context) => ServiceHistoryPage(),
      },
    );
  }
}
