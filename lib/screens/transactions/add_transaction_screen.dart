// lib/screens/transactions/add_transaction_screen.dart
import 'package:flutter/material.dart';

class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Transaksi')),
      body: const Center(child: Text('Halaman Tambah Transaksi')),
    );
  }
}
