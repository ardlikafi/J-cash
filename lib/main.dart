// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Sesuaikan import jika perlu
import 'package:provider/provider.dart'; // Sesuaikan import jika perlu
import 'package:intl/date_symbol_data_local.dart'; // <-- Import untuk inisialisasi locale

// Import Firebase Options (pastikan file ini ada setelah setup Firebase CLI)
// import 'firebase_options.dart';

import 'constants/app_colors.dart';
import 'screens/splash_screen.dart'; // Mulai dari Splash Screen
// Import provider yang akan dibuat nanti
// import 'providers/auth_provider.dart';

// --- Pastikan fungsi main() ditandai async ---
Future<void> main() async {
  // --- Pastikan WidgetsFlutterBinding diinisialisasi ---
  WidgetsFlutterBinding.ensureInitialized();

  // --- Inisialisasi Firebase (jika sudah) ---
  // Pastikan kamu sudah menjalankan `flutterfire configure`
  // dan file firebase_options.dart sudah ter-generate
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // -------------------------------------

  // --- Inisialisasi Formatting Lokal (DITAMBAHKAN DI SINI) ---
  // Memuat data locale untuk Bahasa Indonesia ('id_ID') dan locale default sistem (null).
  // Harus dipanggil sebelum runApp().
  await initializeDateFormatting(null, 'id_ID');
  // -------------------------------------------------------

  // Jalankan aplikasi setelah semua inisialisasi selesai
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Bungkus dengan MultiProvider jika ada > 1 provider
    // return MultiProvider( // Uncomment jika pakai Provider
    //   providers: [
    //     ChangeNotifierProvider(create: (_) => AuthProvider()),
    //     // Tambahkan provider lain di sini (SavingsProvider, TransactionProvider, etc.)
    //   ],
    //   child: MaterialApp(
    //     // ... Konfigurasi MaterialApp ...
    //   ),
    // ); // Penutup MultiProvider

    // Jika belum pakai Provider:
    return MaterialApp(
      title: 'J-Cash',
      theme: ThemeData(
        primaryColor: AppColors.primaryGreen,
        scaffoldBackgroundColor: AppColors.white,
        fontFamily: 'Poppins', // Ganti jika font sudah ditambahkan
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
        useMaterial3: true, // Direkomendasikan untuk Flutter baru
        appBarTheme: const AppBarTheme(
          backgroundColor:
              Colors.transparent, // Transparan agar menyatu dengan background
          elevation: 0,
          iconTheme: IconThemeData(
            color: AppColors.iconGrey,
          ), // Warna ikon back default
          titleTextStyle: TextStyle(
            color:
                AppColors.fontGreen, // Judul AppBar (misal: Riwayat Transaksi)
            fontSize: 18, // Ukuran Font Judul AppBar
            fontWeight: FontWeight.w600, // Bold Sedang
            fontFamily: 'Poppins', // Sesuaikan jika perlu
          ),
          centerTitle: true, // Judul di tengah
        ),
        // Definisikan tema lain jika perlu
        inputDecorationTheme: InputDecorationTheme(
          // Hapus fillColor dan filled dari tema global agar bisa diatur per field jika perlu
          // fillColor: AppColors.textFieldBackground,
          // filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ), // Border default abu-abu
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ), // Border saat tidak aktif
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primaryGreen,
              width: 1.5,
            ), // Border saat fokus
          ),
          hintStyle: const TextStyle(color: AppColors.greyText, fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            // Hapus minimumSize dari global agar tidak memengaruhi semua tombol
            // minimumSize: const Size(double.infinity, 50),
            backgroundColor:
                AppColors.buttonMasuk, // Default warna tombol masuk
            foregroundColor: AppColors.white,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 20,
            ), // Padding default tombol
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // Mulai dari Splash Screen
    );
  }
}
