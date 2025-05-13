// lib/widgets/savings_card.dart
import 'package:flutter/material.dart';
import 'package:j_cash/constants/app_colors.dart';
import 'package:intl/intl.dart';

// --- Format Kustom untuk Kartu Tabungan ---
String formatSavingsAmount(double amount) {
  if (amount >= 1000000000) {
    return 'Rp${(amount / 1000000000).toStringAsFixed(1)}M'.replaceAll(
      '.0',
      '',
    );
  }
  if (amount >= 1000000) {
    return 'Rp${(amount / 1000000).toStringAsFixed(1)}jt'.replaceAll('.0', '');
  }
  if (amount >= 1000) return 'Rp${(amount / 1000).toStringAsFixed(0)}k';
  return 'Rp${amount.toStringAsFixed(0)}';
}
// --------------------------------------

class SavingsCard extends StatelessWidget {
  final String title;
  final double? progress;
  final double currentAmount;
  final double targetAmount;
  final Color color;
  final String iconPath;
  final VoidCallback onTap;

  const SavingsCard({
    super.key,
    required this.title,
    this.progress,
    this.currentAmount = 0,
    required this.targetAmount,
    required this.color,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 170,
        height: 100,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.18),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon besar di kiri atas
            Image.asset(
              iconPath,
              width: 28,
              height: 28,
              color: color,
              errorBuilder:
                  (context, error, stackTrace) =>
                      Icon(Icons.wallet, size: 28, color: color),
            ),
            const SizedBox(height: 2),
            // Judul bold rata kiri
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Progress bar
            if (progress != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress!,
                  backgroundColor: color.withOpacity(0.13),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
            ],
            // Nominal di bawah progress bar
            Text(
              (progress != null && currentAmount > 0)
                  ? '${formatSavingsAmount(currentAmount)} / ${formatSavingsAmount(targetAmount)}'
                  : formatSavingsAmount(targetAmount),
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
