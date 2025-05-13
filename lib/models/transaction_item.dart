// lib/models/transaction_item.dart
import 'package:j_cash/screens/transactions/add_transaction_screen.dart'; // Import Category model
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionItem {
  final String id;
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final int categoryColor;
  final double amount;
  final DateTime date;
  final String notes;
  final bool isExpense;

  TransactionItem({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.amount,
    required this.date,
    required this.notes,
    required this.isExpense,
  });

  factory TransactionItem.fromMap(String id, Map<String, dynamic> map) {
    return TransactionItem(
      id: id,
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      categoryIcon: map['categoryIcon'] ?? '',
      categoryColor: map['categoryColor'] ?? 0xFF000000,
      amount: (map['amount'] ?? 0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      notes: map['notes'] ?? '',
      isExpense: map['isExpense'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'categoryColor': categoryColor,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'isExpense': isExpense,
    };
  }
}
