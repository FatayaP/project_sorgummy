import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // Import dari dalam folder screens

void main() {
  runApp(const SorgumCareApp());
}

class SorgumCareApp extends StatelessWidget {
  const SorgumCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SorgumCareAI',
      theme: ThemeData(
        fontFamily: 'Roboto', 
      ),
      home: const SplashScreen(),
    );
  }
}