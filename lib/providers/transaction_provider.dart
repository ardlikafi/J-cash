// lib/providers/transaction_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:j_cash/models/transaction_item.dart'; // Import model
import 'package:j_cash/models/category.dart'; // Import model Category (pastikan sudah dipindah)
import 'dart:math';
import 'package:j_cash/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class TransactionProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentUserId;

  TransactionProvider() {
    // Initialize user ID when provider is created
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _currentUserId = user?.uid;
      notifyListeners();
    });
  }

  void setUserId(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  void clearUserId() {
    _currentUserId = null;
    notifyListeners();
  }

  Stream<List<TransactionItem>> getTransactions() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TransactionItem.fromMap(
            doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Stream<List<TransactionItem>> getFilteredTransactions({
    required DateTime startDate,
    bool? isExpense,
  }) {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    Query query = _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .orderBy('date', descending: true);

    if (isExpense != null) {
      query = query.where('isExpense', isEqualTo: isExpense);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TransactionItem.fromMap(
            doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> addTransaction(TransactionItem transaction) async {
    if (_currentUserId == null) {
      throw 'User tidak terautentikasi';
    }

    try {
      final batch = _firestore.batch();
      final transactionRef = _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('transactions')
          .doc();

      final userRef = _firestore.collection('users').doc(_currentUserId);
      final userDoc = await userRef.get();
      final currentBalance = (userDoc.data()?['balance'] ?? 0).toDouble();

      final newBalance = transaction.isExpense
          ? currentBalance - transaction.amount
          : currentBalance + transaction.amount;

      batch.set(transactionRef, transaction.toMap());
      batch.update(userRef, {'balance': newBalance});

      await batch.commit();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(TransactionItem transaction) async {
    if (_currentUserId == null) {
      throw 'User tidak terautentikasi';
    }

    try {
      final batch = _firestore.batch();
      final transactionRef = _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('transactions')
          .doc(transaction.id);

      final userRef = _firestore.collection('users').doc(_currentUserId);
      final userDoc = await userRef.get();
      final currentBalance = (userDoc.data()?['balance'] ?? 0).toDouble();

      // Get old transaction data
      final oldTransactionDoc = await transactionRef.get();
      final oldTransaction = oldTransactionDoc.data() as Map<String, dynamic>;
      final oldAmount = (oldTransaction['amount'] ?? 0).toDouble();
      final oldIsExpense = oldTransaction['isExpense'] ?? true;

      // Calculate balance adjustment
      double balanceAdjustment = 0;
      if (oldIsExpense) {
        balanceAdjustment += oldAmount; // Add back old expense
      } else {
        balanceAdjustment -= oldAmount; // Subtract old income
      }
      if (transaction.isExpense) {
        balanceAdjustment -= transaction.amount; // Subtract new expense
      } else {
        balanceAdjustment += transaction.amount; // Add new income
      }

      final newBalance = currentBalance + balanceAdjustment;

      batch.update(transactionRef, transaction.toMap());
      batch.update(userRef, {'balance': newBalance});

      await batch.commit();
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(TransactionItem transaction) async {
    if (_currentUserId == null) {
      throw 'User tidak terautentikasi';
    }

    try {
      final batch = _firestore.batch();
      final transactionRef = _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('transactions')
          .doc(transaction.id);

      final userRef = _firestore.collection('users').doc(_currentUserId);
      final userDoc = await userRef.get();
      final currentBalance = (userDoc.data()?['balance'] ?? 0).toDouble();

      // Adjust balance based on transaction type
      final newBalance = transaction.isExpense
          ? currentBalance + transaction.amount // Add back expense
          : currentBalance - transaction.amount; // Subtract income

      batch.delete(transactionRef);
      batch.update(userRef, {'balance': newBalance});

      await batch.commit();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      rethrow;
    }
  }

  // Get total amount for a period
  Future<double> getTotalAmount({
    required DateTime startDate,
    required DateTime endDate,
    required bool isExpense,
  }) async {
    if (_currentUserId == null || _currentUserId!.isEmpty) return 0.0;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('transactions')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .where('isExpense', isEqualTo: isExpense)
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['amount'] as num?)?.toDouble() ?? 0.0;
      }
      return total;
    } catch (e) {
      debugPrint('Error getting total amount: $e');
      rethrow;
    }
  }
}
