import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/savings_goal.dart';
import 'package:flutter/material.dart';

class SavingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';
  CollectionReference get _savingsCollection =>
      _firestore.collection('users').doc(_userId).collection('savings');

  // Menyimpan semua tabungan
  Future<void> saveSavings(List<SavingsGoal> goals) async {
    // Hapus semua dokumen lama
    final snapshot = await _savingsCollection.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
    // Tambahkan semua goal baru
    for (var goal in goals) {
      await _savingsCollection.add({
        'title': goal.title,
        'iconPath': goal.iconPath,
        'targetAmount': goal.targetAmount,
        'currentAmount': goal.currentAmount,
        'color': goal.color?.value,
      });
    }
  }

  // Mengambil semua tabungan
  Future<List<SavingsGoal>> getSavings() async {
    final snapshot = await _savingsCollection.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return SavingsGoal(
        id: doc.id,
        title: data['title'] ?? '',
        iconPath: data['iconPath'] ?? '',
        targetAmount: (data['targetAmount'] ?? 0.0).toDouble(),
        currentAmount: (data['currentAmount'] ?? 0.0).toDouble(),
        color: data['color'] != null ? Color(data['color']) : null,
      );
    }).toList();
  }

  // Menambah tabungan baru
  Future<void> addSavings(SavingsGoal goal) async {
    await _savingsCollection.add({
      'title': goal.title,
      'iconPath': goal.iconPath,
      'targetAmount': goal.targetAmount,
      'currentAmount': goal.currentAmount,
      'color': goal.color?.value,
    });
  }

  // Update tabungan
  Future<void> updateSavings(SavingsGoal updatedGoal) async {
    await _savingsCollection.doc(updatedGoal.id).update({
      'title': updatedGoal.title,
      'iconPath': updatedGoal.iconPath,
      'targetAmount': updatedGoal.targetAmount,
      'currentAmount': updatedGoal.currentAmount,
      'color': updatedGoal.color?.value,
    });
  }

  // Hapus tabungan
  Future<void> deleteSavings(String id) async {
    await _savingsCollection.doc(id).delete();
  }

  // Update progress tabungan
  Future<void> updateProgress(String id, double amount) async {
    final doc = await _savingsCollection.doc(id).get();
    final data = doc.data() as Map<String, dynamic>;
    final currentAmount = (data['currentAmount'] ?? 0.0).toDouble();
    await _savingsCollection.doc(id).update({
      'currentAmount': currentAmount + amount,
    });
  }

  /// Menghapus semua tabungan pada user saat ini (biasanya untuk hapus data dummy sebelum produksi)
  Future<void> deleteAllSavings() async {
    final snapshot = await _savingsCollection.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Stream tabungan
  Stream<List<SavingsGoal>> getSavingsStream() {
    return _savingsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return SavingsGoal(
          id: doc.id,
          title: data['title'] ?? '',
          iconPath: data['iconPath'] ?? '',
          targetAmount: (data['targetAmount'] ?? 0.0).toDouble(),
          currentAmount: (data['currentAmount'] ?? 0.0).toDouble(),
          color: data['color'] != null ? Color(data['color']) : null,
        );
      }).toList();
    });
  }
}
