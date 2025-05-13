// lib/main.dart
import 'package:flutter/material.dart';
// Sesuaikan import jika perlu (firebase_core sudah ada di bawah)
// Sesuaikan import jika perlu
import 'package:intl/date_symbol_data_local.dart'; // <-- Import untuk inisialisasi locale

// Import Firebase Options (pastikan file ini ada setelah setup Firebase CLI)
import 'package:j_cash/firebase_options.dart'; // <-- Pastikan nama package sesuai

// Import package firebase_core
import 'package:firebase_core/firebase_core.dart'; // <-- Pastikan import ini ada
import 'package:provider/provider.dart';
import 'package:j_cash/providers/auth_provider.dart';
import 'package:j_cash/providers/category_provider.dart';
import 'package:j_cash/providers/transaction_provider.dart';
import 'package:j_cash/providers/savings_provider.dart';
import 'package:j_cash/providers/notification_provider.dart';
import 'package:j_cash/services/notification_service.dart';
import 'package:j_cash/screens/splash_screen.dart';
import 'package:j_cash/providers/theme_provider.dart';
import 'package:j_cash/screens/auth/auth_decision_screen.dart';
import 'package:j_cash/screens/main_navigator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:j_cash/screens/onboarding/onboarding_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- Pastikan fungsi main() ditandai async ---
Future<void> main() async {
  // --- Pastikan WidgetsFlutterBinding diinisialisasi ---
  WidgetsFlutterBinding.ensureInitialized();

  // --- Inisialisasi Firebase (jika sudah) ---
  // !! UNCOMMENT BLOK BERIKUT SETELAH KAMU BERHASIL MENJALANKAN `flutterfire configure` !!
  // !! DAN FILE firebase_options.dart SUDAH TER-GENERATE DENGAN BENAR DI `lib/` !!
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Aktifkan offline persistence Firestore
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);

  // --- Inisialisasi Formatting Lokal (DITAMBAHKAN DI SINI) ---
  // Memuat data locale untuk Bahasa Indonesia ('id_ID') dan locale default sistem (null).
  // Harus dipanggil sebelum runApp().
  await initializeDateFormatting(null, 'id_ID');
  // -------------------------------------------------------

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Jalankan aplikasi setelah semua inisialisasi selesai
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ProxyProvider<AuthProvider, TransactionProvider>(
          update: (context, authProvider, previous) {
            final provider = previous ?? TransactionProvider();
            final userId = authProvider.currentUser?.uid;
            if (userId != null && userId.isNotEmpty) {
              provider.setUserId(userId);
            } else {
              provider.clearUserId();
            }
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => SavingsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Pastikan kategori default diisi untuk user yang login
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final categoryProvider =
          Provider.of<CategoryProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        await categoryProvider.ensureDefaultCategoriesForUser();
      }
    });
    return MaterialApp(
      title: 'J-Cash',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
      home: const SplashGate(),
    );
  }
}

class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _isLoading = false;
    });
  }

  void _goToCTA() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthDecisionScreen()),
    );
  }

  void _goToMainMenu() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }

    // Check if user is logged in
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.isAuthenticated) {
      // If logged in, go directly to main menu
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _goToMainMenu();
      });
      return const SplashScreen(); // Show splash while transitioning
    } else {
      // If not logged in, show onboarding then CTA
      return OnboardingScreen(onFinish: _goToCTA);
    }
  }
}
