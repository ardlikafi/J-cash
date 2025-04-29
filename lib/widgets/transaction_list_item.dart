// lib/widgets/transaction_list_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:j_cash/constants/app_colors.dart'; // Sesuaikan package

// --- BUAT HELPER BARU UNTUK FORMAT AMOUNT DI LIST ---
String formatTransactionAmount(double amount) {
  bool isIncome = amount >= 0;
  // Tentukan prefix + atau - saja, tanpa Rp
  String prefix = isIncome ? '+' : '-';
  double absAmount = amount.abs();

  // Format angka dengan K/Jt/M (tanpa Rp di sini)
  String formattedNumber;
  if (absAmount >= 1000000000) {
    formattedNumber = '${(absAmount / 1000000000).toStringAsFixed(1)}M'
        .replaceAll('.0', '');
  } else if (absAmount >= 1000000) {
    formattedNumber = '${(absAmount / 1000000).toStringAsFixed(1)}jt'
        .replaceAll('.0', '');
  } else if (absAmount >= 1000) {
    formattedNumber = '${(absAmount / 1000).toStringAsFixed(0)}k';
  } else {
    formattedNumber = absAmount.toStringAsFixed(0);
  }
  // Gabungkan prefix, "Rp ", dan angka yang sudah diformat
  return '$prefix Rp $formattedNumber';
}
// ---------------------------------------------

class TransactionListItem extends StatelessWidget {
  final String category;
  final String date;
  final double amount;
  final String iconPath;
  final Color iconBackgroundColor;
  final VoidCallback onTap;

  const TransactionListItem({
    super.key,
    required this.category,
    required this.date,
    required this.amount,
    required this.iconPath,
    required this.iconBackgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isIncome = amount >= 0;
    // Gunakan AppColors.fontGreen atau AppColors.error (lowercase 'e')
    Color amountColor = isIncome ? AppColors.fontGreen : AppColors.error;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: iconBackgroundColor,
              child: Image.asset(
                iconPath, // Path akan diambil dari data dummy
                height: 22,
                width: 22,
                errorBuilder:
                    (context, error, stackTrace) => Icon(
                      Icons.error_outline,
                      size: 22,
                      color: Colors.grey.shade700,
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    date,
                    style: TextStyle(fontSize: 12, color: AppColors.greyText),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // --- GUNAKAN FORMATTER BARU DI SINI ---
            Text(
              formatTransactionAmount(amount), // Panggil helper format baru
              style: TextStyle(
                fontSize: 15, // Sesuaikan ukuran jika perlu
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
