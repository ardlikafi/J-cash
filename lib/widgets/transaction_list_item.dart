// lib/widgets/transaction_list_item.dart
import 'package:flutter/material.dart';
import 'package:j_cash/constants/app_colors.dart'; // Sesuaikan package
import 'package:intl/intl.dart';

// --- BUAT HELPER BARU UNTUK FORMAT AMOUNT DI LIST ---
String formatTransactionAmount(double amount) {
  bool isIncome = amount >= 0;
  // Tentukan prefix + atau - saja, tanpa Rp
  String prefix = isIncome ? '+' : '-';
  double absAmount = amount.abs();

  // Format angka dengan K/Jt/M (tanpa Rp di sini)
  String formattedNumber;
  if (absAmount >= 1000000000) {
    formattedNumber =
        '${(absAmount / 1000000000).toStringAsFixed(1)}M'.replaceAll('.0', '');
  } else if (absAmount >= 1000000) {
    formattedNumber =
        '${(absAmount / 1000000).toStringAsFixed(1)}jt'.replaceAll('.0', '');
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
  final String notes;
  final bool isExpense;
  final VoidCallback onTap;

  const TransactionListItem({
    super.key,
    required this.category,
    required this.date,
    required this.amount,
    required this.iconPath,
    required this.iconBackgroundColor,
    required this.notes,
    required this.isExpense,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Tanda berdasarkan isExpense
    final prefix = isExpense ? '-' : '+';
    final amountColor = isExpense ? AppColors.error : AppColors.fontGreen;
    final formattedAmount = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount.abs());

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: iconBackgroundColor,
                  child: iconPath.isNotEmpty
                      ? Image.asset(iconPath, height: 22, width: 22)
                      : const Icon(Icons.category),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isExpense ? 'Pengeluaran' : 'Pemasukan',
                      style: TextStyle(
                        color:
                            isExpense ? AppColors.error : AppColors.fontGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      NumberFormat.currency(
                              locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                          .format(amount),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Tanggal:', style: TextStyle(fontWeight: FontWeight.w500)),
                Text(date, style: TextStyle(color: Colors.grey[700])),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text('Catatan:',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  Text(notes, style: TextStyle(color: Colors.black87)),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
              // TODO: Tambahkan tombol Edit/Hapus di sini jika ingin
            ],
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              radius: 24,
              backgroundColor: iconBackgroundColor,
              child: iconPath.isNotEmpty
                  ? Image.asset(
                      iconPath,
                      height: 24,
                      width: 24,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.error_outline,
                        size: 24,
                        color: Colors.grey.shade700,
                      ),
                    )
                  : Icon(
                      Icons.category,
                      size: 24,
                      color: Colors.grey.shade700,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      notes,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '$prefix $formattedAmount',
              style: TextStyle(
                fontSize: 16,
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
