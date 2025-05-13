// lib/screens/main_navigator.dart
import 'package:flutter/material.dart';
import 'package:j_cash/constants/app_colors.dart'; // Sesuaikan package name

// Import halaman-halaman utama
import 'home/home_screen.dart';
import 'transactions/transaction_history_screen.dart'; // Halaman riwayat transaksi
import 'statistics/statistics_screen.dart'; // Halaman statistik
import 'profile/profile_screen.dart'; // Halaman profil
import 'savings/savings_list_screen.dart'; // Halaman tabungan

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0; // Indeks tab yang aktif

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gunakan IndexedStack untuk menjaga state setiap halaman tab
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(),
          const TransactionHistoryScreen(),
          SavingsListScreen(
            onBackToHome: () => setState(() => _selectedIndex = 0),
          ),
          const StatisticsScreen(),
          ProfileScreen(),
        ],
      ),
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
              'assets/icons/ic_investment_card.png',
              height: 24,
              color: AppColors.bottomNavUnselected,
            ),
            activeIcon: Image.asset(
              'assets/icons/ic_investment_card.png',
              height: 24,
              color: AppColors.bottomNavSelected,
            ),
            label: 'Tabungan',
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
