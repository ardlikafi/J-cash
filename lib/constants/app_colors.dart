import 'package:flutter/material.dart';

class AppColors {
  // Warna Utama & Gradient
  static const Color primaryGreen = Color(0xFF38C574);
  static const Color secondaryGreen = Color(0xFF2D975A);
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [primaryGreen, secondaryGreen],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.45, 0.88],
  );

  // Warna Tombol
  static const Color buttonLanjut = primaryGreen; // 38C574
  static const Color buttonDaftar = Color(0xFF4ADD99);
  static const Color buttonMasuk = Color(0xFF2ECC71);
  static const Color socialButtonBackground = Color(0xFF8DCE8B);
  static const Color socialButtonForeground = Color(
    0xFFFFFFFF,
  ); // Teks putih di tombol social? Asumsi

  // Warna UI Lain
  static const Color transactionAmountBackground = Color(0xFF40C057);
  static const Color fontGreen = Color(
    0xFF40C057,
  ); // Untuk saldo & jumlah transaksi
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color greyText =
      Colors.grey; // Ganti jika ada warna abu spesifik
  static const Color textFieldBackground = Color(
    0xFFF2F2F2,
  ); // Asumsi warna field input
  static const Color textFieldBorder =
      Colors.transparent; // Asumsi border field input
  static const Color iconGrey =
      Colors.grey; // Warna ikon di text field (user, mail, lock)
  static const Color dividerLine = Colors.grey; // Warna garis pemisah "atau"
  static const Color bottomNavBackground = Color(
    0xFFF8F8F8,
  ); // Asumsi warna dasar bottom nav
  static const Color bottomNavSelected =
      primaryGreen; // Warna ikon & teks terpilih di bottom nav
  static const Color bottomNavUnselected =
      Colors.grey; // Warna ikon & teks tidak terpilih

  // Warna untuk card tabungan (contoh)
  static const Color savingsCardBg1 = Color(0xFFE0F2E8); // Hijau muda
  static const Color savingsCardBg2 = Color(0xFFDDECFA); // Biru muda
  // Tambahkan warna lain sesuai kebutuhan dari desainmu
}
