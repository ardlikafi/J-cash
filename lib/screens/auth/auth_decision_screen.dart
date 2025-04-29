// lib/screens/auth/auth_decision_screen.dart
import 'package:flutter/material.dart';
import 'package:j_cash/constants/app_colors.dart'; // Sesuaikan nama package
import 'package:j_cash/screens/auth/login_screen.dart';
import 'package:j_cash/screens/auth/register_screen.dart';
// Import widget kustom jika ada (misal tombol)
// import 'package:j_cash/widgets/custom_button.dart';

class AuthDecisionScreen extends StatelessWidget {
  const AuthDecisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        // Background Gradient sama seperti Onboarding
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0,
              vertical: 20.0,
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Pusatkan konten utama
              children: [
                // Spacer untuk mendorong konten ke tengah jika perlu, atau atur alignment
                const Spacer(flex: 2),

                // Ilustrasi (dari onboarding terakhir)
                Image.asset(
                  'assets/images/img_cta.png', // Pastikan path benar
                  height: screenSize.height * 0.30, // Sesuaikan ukuran
                  fit: BoxFit.contain,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported_outlined,
                        size: 100,
                        color: AppColors.white,
                      ),
                ),
                const SizedBox(height: 40),

                // Judul
                const Text(
                  'Siap Memulai?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28, // Sedikit lebih besar?
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 15),

                // Deskripsi
                const Text(
                  'Buat akun atau masuk untuk menyimpan datamu dan nikmati semua fitur J-Cash.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15, // Sedikit lebih besar?
                    color: AppColors.white,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 50), // Spasi sebelum tombol
                // Tombol Daftar
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.buttonDaftar, // Warna tombol Daftar
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(double.infinity, 50), // Lebar penuh
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      // Pakai push biasa agar bisa kembali
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Daftar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 15), // Spasi antar tombol
                // Tombol Masuk
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.buttonMasuk, // Warna tombol Masuk
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(double.infinity, 50), // Lebar penuh
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      // Pakai push biasa agar bisa kembali
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Masuk',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),

                const Spacer(flex: 1), // Spacer di bawah tombol
              ],
            ),
          ),
        ),
      ),
    );
  }
}
