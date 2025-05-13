import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:j_cash/models/category.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user ID
  String get _userId => _auth.currentUser?.uid ?? '';

  // Collection references
  CollectionReference get _categoriesCollection =>
      _firestore.collection('users').doc(_userId).collection('categories');

  // Stream kategori
  Stream<List<Category>> getCategories() {
    return _categoriesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Category(
          id: doc.id,
          name: data['name'] ?? '',
          iconPath: data['iconPath'] ?? '',
          iconBgColor: Color(data['iconBgColor'] ?? 0xFF000000),
          isExpense: data['isExpense'] ?? true,
        );
      }).toList();
    });
  }

  // Get kategori berdasarkan ID
  Future<Category?> getCategoryById(String categoryId) async {
    try {
      final doc = await _categoriesCollection.doc(categoryId).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      return Category(
        id: doc.id,
        name: data['name'] ?? '',
        iconPath: data['iconPath'] ?? '',
        iconBgColor: Color(data['iconBgColor'] ?? 0xFF000000),
        isExpense: data['isExpense'] ?? true,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get kategori berdasarkan nama
  Future<Category?> getCategoryByName(String name) async {
    try {
      final snapshot = await _categoriesCollection
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      return Category(
        id: doc.id,
        name: data['name'] ?? '',
        iconPath: data['iconPath'] ?? '',
        iconBgColor: Color(data['iconBgColor'] ?? 0xFF000000),
        isExpense: data['isExpense'] ?? true,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Tambah kategori baru
  Future<void> addCategory(Category category) async {
    try {
      await _categoriesCollection.add({
        'name': category.name,
        'iconPath': category.iconPath,
        'iconBgColor': category.iconBgColor.value,
        'isExpense': category.isExpense,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Update kategori
  Future<void> updateCategory(Category category) async {
    try {
      await _categoriesCollection.doc(category.id).update({
        'name': category.name,
        'iconPath': category.iconPath,
        'iconBgColor': category.iconBgColor.value,
        'isExpense': category.isExpense,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Hapus kategori
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _categoriesCollection.doc(categoryId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Get kategori berdasarkan tipe (pemasukan/pengeluaran)
  Future<List<Category>> getCategoriesByType(bool isExpense) async {
    try {
      final snapshot = await _categoriesCollection
          .where('isExpense', isEqualTo: isExpense)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Category(
          id: doc.id,
          name: data['name'] ?? '',
          iconPath: data['iconPath'] ?? '',
          iconBgColor: Color(data['iconBgColor'] ?? 0xFF000000),
          isExpense: data['isExpense'] ?? true,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Inisialisasi kategori default
  Future<void> initializeDefaultCategories() async {
    try {
      // Kategori pengeluaran default
      final expenseCategories = [
        Category(
          name: 'Makanan & Minuman',
          iconPath: 'assets/icons/food.png',
          iconBgColor: Colors.orange,
          isExpense: true,
        ),
        Category(
          name: 'Transportasi',
          iconPath: 'assets/icons/transport.png',
          iconBgColor: Colors.blue,
          isExpense: true,
        ),
        Category(
          name: 'Belanja',
          iconPath: 'assets/icons/shopping.png',
          iconBgColor: Colors.pink,
          isExpense: true,
        ),
        Category(
          name: 'Tagihan',
          iconPath: 'assets/icons/bill.png',
          iconBgColor: Colors.red,
          isExpense: true,
        ),
        Category(
          name: 'Hiburan',
          iconPath: 'assets/icons/entertainment.png',
          iconBgColor: Colors.purple,
          isExpense: true,
        ),
      ];

      // Kategori pemasukan default
      final incomeCategories = [
        Category(
          name: 'Gaji',
          iconPath: 'assets/icons/salary.png',
          iconBgColor: Colors.green,
          isExpense: false,
        ),
        Category(
          name: 'Bonus',
          iconPath: 'assets/icons/bonus.png',
          iconBgColor: Colors.teal,
          isExpense: false,
        ),
        Category(
          name: 'Investasi',
          iconPath: 'assets/icons/investment.png',
          iconBgColor: Colors.indigo,
          isExpense: false,
        ),
      ];

      // Tambahkan semua kategori default
      for (var category in [...expenseCategories, ...incomeCategories]) {
        await addCategory(category);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Menghapus semua kategori pada user saat ini (biasanya untuk hapus data dummy sebelum produksi)
  Future<void> deleteAllCategories() async {
    final snapshot = await _categoriesCollection.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
