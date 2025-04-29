// lib/screens/statistics/statistics_screen.dart
import 'package:flutter/material.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: const Center(child: Text('Halaman Statistik')),
    );
  }
}
