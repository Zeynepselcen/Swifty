import 'package:flutter/material.dart';
import 'dart:async';

class SimpleSplashScreen extends StatefulWidget {
  const SimpleSplashScreen({super.key});

  @override
  State<SimpleSplashScreen> createState() => _SimpleSplashScreenState();
}

class _SimpleSplashScreenState extends State<SimpleSplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // 3 saniye sonra ana ekrana geç
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/main');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white, // Arka plan rengi
        ),
        child: Image.asset(
          'assets/splash_screen.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Text(
                'Splash Screen',
                style: TextStyle(fontSize: 24),
              ),
            );
          },
        ),
      ),
    );
  }
} 