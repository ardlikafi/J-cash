// lib/models/savings_goal.dart
import 'package:flutter/material.dart';

class SavingsGoal {
  final String id; // Tambah ID unik nanti untuk update/delete
  final String title;
  final String iconPath;
  final double targetAmount;
  final double currentAmount;
  final Color? color; // Warna background card

  SavingsGoal({
    required this.id,
    required this.title,
    required this.iconPath,
    required this.targetAmount,
    this.currentAmount = 0.0, // Default 0
    this.color,
  });

  // Hitung progress (0.0 - 1.0)
  double? get progress {
    if (targetAmount <= 0) return 0.0; // Hindari pembagian nol
    if (currentAmount <= 0) return 0.0;
    double calculatedProgress = currentAmount / targetAmount;
    return calculatedProgress > 1.0 ? 1.0 : calculatedProgress; // Maksimal 1.0
  }
}
