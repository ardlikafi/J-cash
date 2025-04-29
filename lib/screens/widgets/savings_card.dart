// lib/widgets/savings_card.dart
import 'package:flutter/material.dart';

class SavingsCard extends StatelessWidget {
  // Terima parameter dari HomeScreen nanti
  final String title;
  final double? progress; // Bisa null jika tidak ada progress bar
  final double targetAmount;
  final Color color;
  final VoidCallback onTap;

  const SavingsCard({
    super.key,
    required this.title,
    this.progress,
    required this.targetAmount,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Placeholder sederhana, nanti kita buat UI card nya
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150, // Contoh lebar card
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(title, style: const TextStyle(color: Colors.black54)),
        ),
      ),
    );
  }
}
