// lib/providers/savings_provider.dart
import 'package:flutter/material.dart';
import 'package:j_cash/constants/app_colors.dart'; // Sesuaikan
import 'package:j_cash/models/savings_goal.dart'; // Import model
import 'dart:math'; // Untuk random ID

class SavingsProvider with ChangeNotifier {
  // Data awal (contoh, gunakan model SavingsGoal)
  final List<SavingsGoal> _savingsList = [
    SavingsGoal(
      id: 'sg1',
      title: 'Beli Rumah',
      iconPath: 'assets/icons/ic_home_card.png',
      currentAmount: 100000.0,
      targetAmount: 100000000.0,
      color: AppColors.savingsCardBg1,
    ),
    SavingsGoal(
      id: 'sg2',
      title: 'Investasi',
      iconPath: 'assets/icons/ic_investment_card.png',
      targetAmount: 100000000.0,
      color: AppColors.savingsCardBg2,
    ),
    SavingsGoal(
      id: 'sg3',
      title: 'Beli Mobil',
      iconPath: 'assets/icons/ic_car_card.png',
      currentAmount: 5000000.0,
      targetAmount: 10000000.0,
      color: AppColors.savingsCardBg1.withOpacity(0.7),
    ),
  ];

  // Getter untuk mengakses data
  List<SavingsGoal> get savingsList => _savingsList;

  // Fungsi untuk menambah tabungan baru
  void addSaving(String title, String iconPath, double targetAmount) {
    // Buat ID unik sederhana (nanti pakai UUID atau ID Firebase)
    String id =
        'sg_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(100)}';
    final newGoal = SavingsGoal(
      id: id,
      title: title,
      iconPath: iconPath,
      targetAmount: targetAmount,
      // Ambil warna secara acak/bergantian jika perlu
      color:
          [AppColors.savingsCardBg1, AppColors.savingsCardBg2][Random().nextInt(
            2,
          )],
    );
    _savingsList.add(newGoal);
    // Beri tahu listener (HomeScreen) bahwa data berubah
    notifyListeners();
  }

  // TODO: Tambahkan fungsi update & delete nanti
}
