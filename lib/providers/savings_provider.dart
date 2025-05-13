// lib/providers/savings_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:j_cash/constants/app_colors.dart'; // Sesuaikan
import 'package:j_cash/models/savings_goal.dart'; // Import model
import 'dart:math'; // Untuk random ID

class SavingsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';
  set userId(String id) {
    // Setter dummy agar bisa di-set dari luar, walau _userId tetap ambil dari FirebaseAuth
    // (opsional: bisa reload data di sini jika ingin)
  }

  CollectionReference get _savingsCollection =>
      _firestore.collection('users').doc(_userId).collection('savings');

  // Getter untuk mengakses data
  // Semua tabungan diambil dari Firestore
  Stream<List<Map<String, dynamic>>> getSavingsGoals() {
    return _savingsCollection.orderBy('targetDate').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'targetAmount': data['targetAmount']?.toDouble() ?? 0.0,
          'currentAmount': data['currentAmount']?.toDouble() ?? 0.0,
          'targetDate': (data['targetDate'] as Timestamp).toDate(),
          'createdAt': (data['createdAt'] as Timestamp).toDate(),
          'updatedAt': (data['updatedAt'] as Timestamp).toDate(),
        };
      }).toList();
    });
  }

  // Add savings goal
  Future<void> addSavingsGoal({
    required String name,
    required double targetAmount,
    required DateTime targetDate,
  }) async {
    try {
      await _savingsCollection.add({
        'name': name,
        'targetAmount': targetAmount,
        'currentAmount': 0.0,
        'targetDate': Timestamp.fromDate(targetDate),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Update savings goal
  Future<void> updateSavingsGoal({
    required String id,
    String? name,
    double? targetAmount,
    DateTime? targetDate,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updates['name'] = name;
      if (targetAmount != null) updates['targetAmount'] = targetAmount;
      if (targetDate != null)
        updates['targetDate'] = Timestamp.fromDate(targetDate);

      await _savingsCollection.doc(id).update(updates);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Delete savings goal
  Future<void> deleteSavingsGoal(String id) async {
    try {
      await _savingsCollection.doc(id).delete();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Update current amount
  Future<void> updateCurrentAmount({
    required String id,
    required double amount,
  }) async {
    try {
      final doc = await _savingsCollection.doc(id).get();
      final data = doc.data() as Map<String, dynamic>;
      final currentAmount = double.parse(
        (data['currentAmount'] ?? 0.0).toString(),
      );

      await _savingsCollection.doc(id).update({
        'currentAmount': currentAmount + amount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Get total savings
  Future<double> getTotalSavings() async {
    try {
      final snapshot = await _savingsCollection.get();
      double total = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['currentAmount'] as num?)?.toDouble() ?? 0.0;
      }
      return total;
    } catch (e) {
      rethrow;
    }
  }

  // Get savings by progress
  Stream<List<Map<String, dynamic>>> getSavingsByProgress({
    required bool isCompleted,
  }) {
    return _savingsCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final targetAmount = data['targetAmount']?.toDouble() ?? 0.0;
            final currentAmount = data['currentAmount']?.toDouble() ?? 0.0;
            final isGoalCompleted = currentAmount >= targetAmount;

            if (isGoalCompleted == isCompleted) {
              return {
                'id': doc.id,
                'name': data['name'] ?? '',
                'targetAmount': targetAmount,
                'currentAmount': currentAmount,
                'targetDate': (data['targetDate'] as Timestamp).toDate(),
                'progress': currentAmount / targetAmount,
                'createdAt': (data['createdAt'] as Timestamp).toDate(),
                'updatedAt': (data['updatedAt'] as Timestamp).toDate(),
              };
            }
            return null;
          })
          .where((item) => item != null)
          .cast<Map<String, dynamic>>()
          .toList();
    });
  }

  // Initialize default savings goals
  Future<void> initializeDefaultSavings() async {
    try {
      // Check if savings goals already exist
      final snapshot = await _savingsCollection.get();
      if (snapshot.docs.isNotEmpty) return;

      // Default savings goals
      final defaultGoals = [
        {
          'name': 'Tabungan Darurat',
          'targetAmount': 10000000.0,
          'currentAmount': 0.0,
          'targetDate': Timestamp.fromDate(
            DateTime.now().add(const Duration(days: 365)),
          ),
        },
        {
          'name': 'Tabungan Liburan',
          'targetAmount': 5000000.0,
          'currentAmount': 0.0,
          'targetDate': Timestamp.fromDate(
            DateTime.now().add(const Duration(days: 180)),
          ),
        },
        {
          'name': 'Tabungan Investasi',
          'targetAmount': 20000000.0,
          'currentAmount': 0.0,
          'targetDate': Timestamp.fromDate(
            DateTime.now().add(const Duration(days: 730)),
          ),
        },
      ];

      // Add all savings goals
      final batch = _firestore.batch();
      for (var goal in defaultGoals) {
        final docRef = _savingsCollection.doc();
        batch.set(docRef, {
          ...goal,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
