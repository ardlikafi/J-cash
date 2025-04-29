// lib/screens/transactions/transaction_history_screen.dart
import 'package:flutter/material.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi Lengkap')),
      body: const Center(child: Text('Halaman Riwayat Transaksi Lengkap')),
    );
  }
}
