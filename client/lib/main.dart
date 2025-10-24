import 'package:flutter/material.dart';

import 'home_page.dart';

void main() {
  runApp(const GearMateApp());
}

class GearMateApp extends StatelessWidget {
  const GearMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    const coral = Color(0xFFE85A4F);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GearMate',
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: coral,
        scaffoldBackgroundColor: const Color(0xFFF5F6F8),
        fontFamily: 'SF Pro',
        colorScheme: ColorScheme.fromSeed(seedColor: coral, primary: coral),
      ),
      home: const HomePage(),
    );
  }
}
