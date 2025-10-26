import 'package:flutter/material.dart';
import 'pages/homepage.dart';
import 'add_maintenance_schedule_page.dart';
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
      // theme: ThemeData(primaryColor: Color(0xFFFF473F), fontFamily: 'WorkSan'),
      // home: homepage(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => homepage(),
        '/schedule': (context) => const AddMaintenanceSchedulePage(),
        '/addgear': (context) => addnewgearpage(),
      },
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: coral,
        scaffoldBackgroundColor: const Color(0xFFF5F6F8),
        fontFamily: 'SF Pro',
        colorScheme: ColorScheme.fromSeed(seedColor: coral, primary: coral),
      ),
    );
  }
}
