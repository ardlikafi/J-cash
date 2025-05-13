import 'dart:async';
import 'package:flutter/material.dart';
import 'package:j_cash/constants/app_colors.dart'; // Ganti 'j_cash' dengan nama projectmu
import 'package:j_cash/screens/onboarding/onboarding_screen.dart'; // Import onboarding screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigasi setelah delay
    Timer(const Duration(seconds: 3), () {
      // Nanti di sini bisa cek status login user
      // Jika sudah login -> HomeScreen
      // Jika belum -> OnboardingScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Background Gradient
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo J-Cash
              // Ganti 'logo_jcash.png' dengan nama file logo kamu di assets/images/
              Image.asset(
                'assets/images/img_logo.png',
                height: 150,
              ), // Sesuaikan path dan size
              const SizedBox(height: 10),
              // Bisa tambahkan teks "J-Cash" jika tidak include di gambar logo
              // const Text(
              //   'J-Cash',
              //   style: TextStyle(
              //     fontSize: 32,
              //     fontWeight: FontWeight.bold,
              //     color: AppColors.white,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
