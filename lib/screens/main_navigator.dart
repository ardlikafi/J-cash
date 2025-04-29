// lib/screens/main_navigator.dart
import 'package:flutter/material.dart';
import 'package:j_cash/constants/app_colors.dart'; // Sesuaikan package name

// Import halaman-halaman utama
import 'home/home_screen.dart';
import 'transactions/transaction_history_screen.dart'; // Halaman riwayat transaksi
import 'statistics/statistics_screen.dart'; // Halaman statistik
import 'profile/profile_screen.dart'; // Halaman profil

class MainNavigator extends StatefulWidget {
  // Constructor MainNavigator bisa tetap const karena tidak punya state/field non-final sendiri
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0; // Indeks tab yang aktif

  // Daftar widget/halaman untuk setiap tab
  // --- PERBAIKAN DI SINI ---
  // Ganti 'const' menjadi 'final' karena HomeScreen() tidak const
  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(), // Ini sekarang valid
    const TransactionHistoryScreen(), // Anggap screen lain punya constructor const
    const StatisticsScreen(), // Anggap screen lain punya constructor const
    const ProfileScreen(), // Anggap screen lain punya constructor const
  ];
  // --- AKHIR PERBAIKAN ---

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gunakan IndexedStack untuk menjaga state setiap halaman tab
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/ic_home_inactive.png',
              height: 24,
              color: AppColors.bottomNavUnselected,
            ),
            activeIcon: Image.asset(
              'assets/icons/ic_home_active.png',
              height: 24,
              color: AppColors.bottomNavSelected,
            ),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/ic_transaksi_inactive.png',
              height: 24,
              color: AppColors.bottomNavUnselected,
            ),
            activeIcon: Image.asset(
              'assets/icons/ic_transaksi_active.png',
              height: 24,
              color: AppColors.bottomNavSelected,
            ),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/ic_statistik_inactive.png',
              height: 24,
              color: AppColors.bottomNavUnselected,
            ),
            activeIcon: Image.asset(
              'assets/icons/ic_statistik_active.png',
              height: 24,
              color: AppColors.bottomNavSelected,
            ),
            label: 'Statistik',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/ic_profile_inactive.png',
              height: 24,
              color: AppColors.bottomNavUnselected,
            ),
            activeIcon: Image.asset(
              'assets/icons/ic_profile_active.png',
              height: 24,
              color: AppColors.bottomNavSelected,
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.bottomNavSelected,
        unselectedItemColor: AppColors.bottomNavUnselected,
        backgroundColor: AppColors.white,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 5,
      ),
    );
  }
}
