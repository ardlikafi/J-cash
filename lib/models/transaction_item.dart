// lib/models/transaction_item.dart
import 'package:flutter/material.dart';
import 'package:j_cash/screens/transactions/add_transaction_screen.dart'; // Import Category model

class TransactionItem {
  final String id; // Tambah ID unik
  final Category category; // Gunakan model Category
  final double amount; // Positif untuk pemasukan, negatif untuk pengeluaran
  final DateTime date;
  final String? notes;
  // Tambahkan field lain jika perlu (lokasi, lampiran?)

  TransactionItem({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.notes,
  });

  bool get isExpense => amount < 0;
}
