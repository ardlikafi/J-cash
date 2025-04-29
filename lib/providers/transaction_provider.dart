// lib/providers/transaction_provider.dart
import 'package:flutter/material.dart';
import 'package:j_cash/models/transaction_item.dart'; // Import model
import 'package:j_cash/models/category.dart'; // Import model Category (pastikan sudah dipindah)
import 'dart:math';

class TransactionProvider with ChangeNotifier {
  // Data awal (contoh, gunakan model TransactionItem)
  final List<TransactionItem> _transactions = [
    TransactionItem(
      id: 'tx1',
      category: Category(
        name: 'Gym & Kesehatan',
        iconPath: 'assets/icons/ic_gym.png',
        iconBgColor: const Color(0xFFE8DCFF),
      ),
      amount: -165000.0,
      date: DateTime(2025, 5, 26),
    ),
    TransactionItem(
      id: 'tx2',
      category: Category(
        name: 'Belanja',
        iconPath: 'assets/icons/ic_shopping.png',
        iconBgColor: const Color(0xFFD7FFF0),
      ),
      amount: -55000.0,
      date: DateTime(2025, 5, 27),
    ),
    TransactionItem(
      id: 'tx3',
      category: Category(
        name: 'Beli Seblak',
        iconPath: 'assets/icons/ic_food.png',
        iconBgColor: Colors.orange.shade100,
      ),
      amount: -25000.0,
      date: DateTime(2025, 5, 27),
    ),
    TransactionItem(
      id: 'tx4',
      category: Category(
        name: 'Gaji',
        iconPath: 'assets/icons/ic_income.png',
        isExpense: false,
        iconBgColor: Colors.green.shade100,
      ),
      amount: 5000000.0,
      date: DateTime(2025, 4, 15),
    ),
  ];

  // Saldo awal (bisa dihitung dari transaksi awal atau hardcode)
  double _currentBalance = 999999.0;

  // Getter
  List<TransactionItem> get transactions => _transactions;
  double get currentBalance => _currentBalance;

  // Ambil transaksi terbaru untuk ditampilkan di Home (misal 5 terakhir)
  List<TransactionItem> get recentTransactions {
    // Urutkan dari terbaru
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    // Ambil 5 pertama (atau kurang jika data < 5)
    return _transactions.take(5).toList();
  }

  // Fungsi untuk menambah transaksi
  void addTransaction(
    Category category,
    double amount,
    DateTime date,
    String? notes,
  ) {
    String id =
        'tx_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(100)}';
    final newTransaction = TransactionItem(
      id: id,
      category: category,
      amount: amount, // amount sudah positif/negatif dari AddTransactionScreen
      date: date,
      notes: notes,
    );
    _transactions.add(newTransaction);

    // Update saldo
    _currentBalance += amount; // Langsung tambah/kurang

    // Beri tahu listener
    notifyListeners();
  }

  // TODO: Tambahkan fungsi update & delete nanti
}
