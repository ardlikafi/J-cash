// lib/widgets/transaction_list_item.dart
import 'package:flutter/material.dart';

class TransactionListItem extends StatelessWidget {
  // Terima parameter dari HomeScreen nanti
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
    // Placeholder sederhana, nanti kita buat UI list item nya
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: iconBackgroundColor,
        child: Image.asset(
          iconPath,
          height: 20,
          errorBuilder:
              (context, error, stackTrace) => const Icon(Icons.error, size: 20),
        ),
      ),
      title: Text(category),
      subtitle: Text(date),
      trailing: Text(
        'Rp ${amount.abs()}', // Tampilkan nilai absolut dulu
        style: TextStyle(
          color: amount < 0 ? Colors.red : Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
