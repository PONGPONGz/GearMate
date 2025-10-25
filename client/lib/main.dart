import 'package:flutter/material.dart';
import 'pages/homepage.dart';
import 'pages/SchedulePage.dart';
import 'pages/AddNewGear.dart';

void main() {
  runApp(const GearMateApp());
}

class GearMateApp extends StatelessWidget {
  const GearMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    const coral = Color(0xFFE85A4F);
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
      },
    );
  }
}
