import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:j_cash/models/transaction_item.dart';
import 'package:j_cash/models/category.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user ID
  String get _userId => _auth.currentUser?.uid ?? '';

  // Collection references
  CollectionReference get _transactionsCollection =>
      _firestore.collection('users').doc(_userId).collection('transactions');
  DocumentReference get _userDoc => _firestore.collection('users').doc(_userId);

  // Stream transaksi
  Stream<List<TransactionItem>> getTransactions() {
    return _transactionsCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TransactionItem(
          id: doc.id,
          category: Category(
            name: data['categoryName'] ?? '',
            iconPath: data['categoryIcon'] ?? '',
            iconBgColor: Color(data['categoryColor'] ?? 0xFF000000),
            isExpense: data['isExpense'] ?? true,
          ),
          amount: data['amount']?.toDouble() ?? 0.0,
          date: (data['date'] as Timestamp).toDate(),
          notes: data['notes'],
        );
      }).toList();
    });
  }

  // Tambah transaksi baru
  Future<void> addTransaction(TransactionItem transaction) async {
    try {
      // Tambah transaksi
      await _transactionsCollection.add({
        'categoryName': transaction.category.name,
        'categoryIcon': transaction.category.iconPath,
        'categoryColor': transaction.category.iconBgColor.value,
        'isExpense': transaction.category.isExpense,
        'amount': transaction.amount,
        'date': Timestamp.fromDate(transaction.date),
        'notes': transaction.notes,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update saldo user
      await _userDoc.update({
        'balance': FieldValue.increment(transaction.amount),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Update transaksi
  Future<void> updateTransaction(TransactionItem transaction) async {
    try {
      // Get transaksi lama untuk menghitung selisih saldo
      final oldTransactionDoc =
          await _transactionsCollection.doc(transaction.id).get();
      final oldData = oldTransactionDoc.data() as Map<String, dynamic>;
      final oldAmount = oldData['amount']?.toDouble() ?? 0.0;

      // Update transaksi
      await _transactionsCollection.doc(transaction.id).update({
        'categoryName': transaction.category.name,
        'categoryIcon': transaction.category.iconPath,
        'categoryColor': transaction.category.iconBgColor.value,
        'isExpense': transaction.category.isExpense,
        'amount': transaction.amount,
        'date': Timestamp.fromDate(transaction.date),
        'notes': transaction.notes,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update saldo user (kurangi saldo lama, tambah saldo baru)
      await _userDoc.update({
        'balance': FieldValue.increment(transaction.amount - oldAmount),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Hapus transaksi
  Future<void> deleteTransaction(String transactionId) async {
    try {
      // Get transaksi untuk menghitung pengurangan saldo
      final transactionDoc =
          await _transactionsCollection.doc(transactionId).get();
      final data = transactionDoc.data() as Map<String, dynamic>;
      final amount = data['amount']?.toDouble() ?? 0.0;

      // Hapus transaksi
      await _transactionsCollection.doc(transactionId).delete();

      // Update saldo user
      await _userDoc.update({'balance': FieldValue.increment(-amount)});
    } catch (e) {
      rethrow;
    }
  }

  // Get transaksi berdasarkan filter
  Future<List<TransactionItem>> getFilteredTransactions({
    DateTime? startDate,
    DateTime? endDate,
    bool? isExpense,
    String? categoryName,
  }) async {
    try {
      Query query = _transactionsCollection.orderBy('date', descending: true);

      if (startDate != null) {
        query = query.where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }
      if (endDate != null) {
        query = query.where(
          'date',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }
      if (isExpense != null) {
        query = query.where('isExpense', isEqualTo: isExpense);
      }
      if (categoryName != null) {
        query = query.where('categoryName', isEqualTo: categoryName);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TransactionItem(
          id: doc.id,
          category: Category(
            name: data['categoryName'] ?? '',
            iconPath: data['categoryIcon'] ?? '',
            iconBgColor: Color(data['categoryColor'] ?? 0xFF000000),
            isExpense: data['isExpense'] ?? true,
          ),
          amount: data['amount']?.toDouble() ?? 0.0,
          date: (data['date'] as Timestamp).toDate(),
          notes: data['notes'],
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get total pemasukan/pengeluaran dalam periode tertentu
  Future<double> getTotalAmount(DateTime startDate, DateTime endDate) async {
    try {
      final transactions = await getTransactions().first;
      double total = 0.0;

      for (var transaction in transactions) {
        if (transaction.date.isAfter(startDate) &&
            transaction.date.isBefore(endDate)) {
          total += transaction.amount;
        }
      }

      return total;
    } catch (e) {
      debugPrint('Error getting total amount: $e');
      return 0.0;
    }
  }

  /// Menghapus semua transaksi pada user saat ini (biasanya untuk hapus data dummy sebelum produksi)
  Future<void> deleteAllTransactions() async {
    final snapshot = await _transactionsCollection.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
