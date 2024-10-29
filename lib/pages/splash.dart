import 'dart:async';
import 'package:flutter/material.dart';
import 'package:screensage/pages/dashboard.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // Delay for 3 seconds before navigating to the main screen
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardPage()), // Navigate to main screen
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set the background color
      body: Center(
        child: Image.asset('assets/images/splash-logo.png'), // Your logo
      ),
    );
  }
}
