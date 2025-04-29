// lib/screens/main_navigator.dart
import 'package:flutter/material.dart';
import 'package:j_cash/constants/app_colors.dart'; // Sesuaikan package name

// Import halaman-halaman utama
import 'home/home_screen.dart';
import 'transactions/transaction_history_screen.dart'; // Halaman riwayat transaksi
import 'statistics/statistics_screen.dart'; // Halaman statistik
import 'profile/profile_screen.dart'; // Halaman profil

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0; // Indeks tab yang aktif

  // Daftar widget/halaman untuk setiap tab
  // Menggunakan screen yang sebenarnya
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    TransactionHistoryScreen(), // Ganti placeholder dengan screen sebenarnya
    StatisticsScreen(), // Ganti placeholder dengan screen sebenarnya
    ProfileScreen(), // Ganti placeholder dengan screen sebenarnya
  ];

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
              'assets/icons/ic_home_inactive.png', // Nama ikon sudah diupdate
              height: 24,
              color:
                  AppColors
                      .bottomNavUnselected, // Pastikan warna unselected benar
            ),
            activeIcon: Image.asset(
              'assets/icons/ic_home_active.png', // Nama ikon sudah diupdate
              height: 24,
              color: AppColors.bottomNavSelected, // Warna state aktif
            ),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/ic_transaksi_inactive.png', // Nama ikon sudah diupdate
              height: 24,
              color: AppColors.bottomNavUnselected,
            ),
            activeIcon: Image.asset(
              'assets/icons/ic_transaksi_active.png', // Nama ikon sudah diupdate
              height: 24,
              color: AppColors.bottomNavSelected,
            ),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/ic_statistik_inactive.png', // Nama ikon sudah diupdate
              height: 24,
              color: AppColors.bottomNavUnselected,
            ),
            activeIcon: Image.asset(
              'assets/icons/ic_statistik_active.png', // Nama ikon sudah diupdate
              height: 24,
              color: AppColors.bottomNavSelected,
            ),
            label: 'Statistik',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/ic_profile_inactive.png', // Nama ikon sudah diupdate
              height: 24,
              color: AppColors.bottomNavUnselected,
            ),
            activeIcon: Image.asset(
              'assets/icons/ic_profile_active.png', // Nama ikon sudah diupdate
              height: 24,
              color: AppColors.bottomNavSelected,
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.bottomNavSelected, // Warna label aktif
        unselectedItemColor:
            AppColors.bottomNavUnselected, // Warna label tidak aktif
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

// --- Placeholder Screen SUDAH DIHAPUS ---
// Pindahkan class StatisticsScreen dan ProfileScreen ke file masing-masing
// di lib/screens/statistics/ dan lib/screens/profile/
