import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // Import Provider

// Import Firebase Options (pastikan file ini ada setelah setup Firebase CLI)
// import 'firebase_options.dart';

import 'constants/app_colors.dart';
import 'screens/splash_screen.dart'; // Mulai dari Splash Screen
// Import provider yang akan dibuat nanti
// import 'providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // --- Inisialisasi Firebase ---
  // Pastikan kamu sudah menjalankan `flutterfire configure`
  // dan file firebase_options.dart sudah ter-generate
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // ---------------------------
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Bungkus dengan MultiProvider jika ada > 1 provider
    return
    // MultiProvider( // Uncomment jika pakai Provider
    // providers: [
    //   ChangeNotifierProvider(create: (_) => AuthProvider()),
    //   // Tambahkan provider lain di sini (SavingsProvider, TransactionProvider, etc.)
    // ],
    // child:
    MaterialApp(
      title: 'J-Cash',
      theme: ThemeData(
        primaryColor: AppColors.primaryGreen,
        scaffoldBackgroundColor: AppColors.white,
        fontFamily: 'Poppins', // Ganti jika font sudah ditambahkan
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
        useMaterial3: true, // Direkomendasikan untuk Flutter baru
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: AppColors.iconGrey,
          ), // Tombol back default
          titleTextStyle: TextStyle(
            color:
                AppColors.fontGreen, // Judul AppBar (misal: Riwayat Transaksi)
            fontSize: 20,
            fontWeight: FontWeight.bold, // Sesuaikan
            fontFamily: 'Poppins', // Sesuaikan
          ),
          centerTitle: true, // Judul di tengah? Sesuaikan
        ),
        // Definisikan tema lain jika perlu
        inputDecorationTheme: InputDecorationTheme(
          fillColor: AppColors.textFieldBackground, // Warna background field
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none, // Hilangkan border default
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primaryGreen,
              width: 1.5,
            ), // Border saat fokus
          ),
          hintStyle: const TextStyle(
            color: AppColors.greyText,
            fontSize: 14,
          ), // Style teks hint
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            //   minimumSize: const Size(
            //  double.infinity,
            //  50,
            //  ), // Lebar penuh, tinggi 50
            backgroundColor:
                AppColors.buttonMasuk, // Default warna tombol masuk
            foregroundColor: AppColors.white,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins', // Sesuaikan
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2, // Sedikit shadow
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // Mulai dari Splash Screen
      // ); // Penutup MultiProvider
    );
  }
}
