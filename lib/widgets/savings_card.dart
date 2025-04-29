// lib/widgets/savings_card.dart
import 'package:flutter/material.dart';
import 'package:j_cash/constants/app_colors.dart';

// --- Format Kustom untuk Kartu Tabungan ---
String formatSavingsAmount(double amount) {
  if (amount >= 1000000000)
    return 'Rp${(amount / 1000000000).toStringAsFixed(1)}M'.replaceAll(
      '.0',
      '',
    );
  if (amount >= 1000000)
    return 'Rp${(amount / 1000000).toStringAsFixed(1)}jt'.replaceAll('.0', '');
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
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 150, // Lebar bisa disesuaikan lagi
        height: 110, // Tinggi eksplisit agar konsisten
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween, // Space between top icon and bottom text
          children: [
            // --- Ikon di Kiri Atas ---
            Image.asset(
              iconPath,
              height: 22,
              width: 22,
              color: AppColors.black.withOpacity(0.7),
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.wallet, size: 22, color: Colors.black54),
            ),

            // --- Teks di Bawah ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black.withOpacity(0.85),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
                  height: 4,
                ), // Jarak antara judul dan amount/progress
                // Teks Amount (Format Baru)
                Text(
                  // Tampilkan "Rp Xk / Rp Yjt" atau hanya "Rp Yjt"
                  (progress != null && currentAmount > 0)
                      ? '${formatSavingsAmount(currentAmount)} / ${formatSavingsAmount(targetAmount)}'
                      : formatSavingsAmount(targetAmount),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Progress Bar (jika ada progress)
                if (progress != null) ...[
                  const SizedBox(height: 5), // Jarak sebelum progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress!,
                      backgroundColor: Colors.black.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryGreen,
                      ),
                      minHeight: 5,
                    ),
                  ),
                ] else ...[
                  // Beri ruang jika tidak ada progress bar agar tinggi konsisten
                  const SizedBox(height: 10), // Sesuaikan tinggi ini
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
