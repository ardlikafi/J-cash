// lib/screens/savings/create_savings_screen.dart
import 'package:flutter/material.dart';

class CreateSavingsScreen extends StatelessWidget {
  const CreateSavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Tabungan Baru')),
      body: const Center(child: Text('Halaman Buat Tabungan Baru')),
    );
  }
}
