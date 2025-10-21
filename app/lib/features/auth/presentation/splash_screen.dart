import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chamawise_app/features/auth/presentation/onboarding_screen.dart';
import 'package:chamawise_app/features/home/presentation/home_screen.dart';
import 'package:chamawise_app/features/auth/presentation/login_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(const Duration(seconds: 2)); // small splash delay

    User? user = _auth.currentUser;

    if (user != null) {
      // ✅ User is logged in — go to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // 🧭 User not logged in — show onboarding first
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 80),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.green),
          ],
        ),
      ),
    );
  }
}

