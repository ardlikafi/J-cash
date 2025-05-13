import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:j_cash/models/category.dart';

class CategoryProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Category> _categories = [];

  String get _userId => _auth.currentUser?.uid ?? '';
  set userId(String id) {
    // Setter dummy agar bisa di-set dari luar, walau _userId tetap ambil dari FirebaseAuth
    // (opsional: bisa reload data di sini jika ingin)
  }

  CollectionReference get _categoriesCollection =>
      _firestore.collection('users').doc(_userId).collection('categories');

  List<Category> get categories => _categories;
  List<Category> get expenseCategories =>
      _categories.where((cat) => cat.isExpense).toList();
  List<Category> get incomeCategories =>
      _categories.where((cat) => !cat.isExpense).toList();

  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> loadCategories() async {
    try {
      final snapshot = await _categoriesCollection.get();
      _categories = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Category(
          id: doc.id,
          name: data['name'] ?? '',
          iconPath: data['iconPath'] ?? '',
          iconBgColor: Color(data['iconBgColor'] ?? 0xFF000000),
          isExpense: data['isExpense'] ?? true,
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading categories: $e');
      // Load default categories if Firestore fails
      _loadDefaultCategories();
    }
  }

  void _loadDefaultCategories() {
    _categories = [
      // Expense Categories
      Category(
        id: 'expense_food',
        name: 'Makanan & Minuman',
        iconPath: 'assets/icons/food.png',
        iconBgColor: Colors.orange,
        isExpense: true,
      ),
      Category(
        id: 'expense_transport',
        name: 'Transportasi',
        iconPath: 'assets/icons/transport.png',
        iconBgColor: Colors.blue,
        isExpense: true,
      ),
      Category(
        id: 'expense_shopping',
        name: 'Belanja',
        iconPath: 'assets/icons/shopping.png',
        iconBgColor: Colors.pink,
        isExpense: true,
      ),
      Category(
        id: 'expense_bills',
        name: 'Tagihan',
        iconPath: 'assets/icons/bill.png',
        iconBgColor: Colors.red,
        isExpense: true,
      ),
      Category(
        id: 'expense_entertainment',
        name: 'Hiburan',
        iconPath: 'assets/icons/entertainment.png',
        iconBgColor: Colors.purple,
        isExpense: true,
      ),
      Category(
        id: 'expense_health',
        name: 'Kesehatan',
        iconPath: 'assets/icons/health.png',
        iconBgColor: Colors.green,
        isExpense: true,
      ),
      Category(
        id: 'expense_education',
        name: 'Pendidikan',
        iconPath: 'assets/icons/education.png',
        iconBgColor: Colors.indigo,
        isExpense: true,
      ),
      Category(
        id: 'expense_other',
        name: 'Lainnya',
        iconPath: 'assets/icons/other.png',
        iconBgColor: Colors.grey,
        isExpense: true,
      ),

      // Income Categories
      Category(
        id: 'income_salary',
        name: 'Gaji',
        iconPath: 'assets/icons/salary.png',
        iconBgColor: Colors.teal,
        isExpense: false,
      ),
      Category(
        id: 'income_bonus',
        name: 'Bonus',
        iconPath: 'assets/icons/bonus.png',
        iconBgColor: Colors.amber,
        isExpense: false,
      ),
      Category(
        id: 'income_investment',
        name: 'Investasi',
        iconPath: 'assets/icons/investment.png',
        iconBgColor: Colors.lightGreen,
        isExpense: false,
      ),
      Category(
        id: 'income_other',
        name: 'Lainnya',
        iconPath: 'assets/icons/other.png',
        iconBgColor: Colors.grey,
        isExpense: false,
      ),
    ];
    notifyListeners();
  }

  // Get all categories
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

  // Get categories by type (expense/income)
  Stream<List<Category>> getCategoriesByType(bool isExpense) {
    return _categoriesCollection
        .where('isExpense', isEqualTo: isExpense)
        .snapshots()
        .map((snapshot) {
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

  // Add category
  Future<void> addCategory(Category category) async {
    try {
      await _categoriesCollection.add({
        'name': category.name,
        'iconPath': category.iconPath,
        'iconBgColor': category.iconBgColor.value,
        'isExpense': category.isExpense,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Update category
  Future<void> updateCategory(Category category) async {
    try {
      await _categoriesCollection.doc(category.id).update({
        'name': category.name,
        'iconPath': category.iconPath,
        'iconBgColor': category.iconBgColor.value,
        'isExpense': category.isExpense,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Delete category
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _categoriesCollection.doc(categoryId).delete();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Initialize default categories
  Future<void> initializeDefaultCategories() async {
    try {
      // Check if categories already exist
      final snapshot = await _categoriesCollection.get();
      if (snapshot.docs.isNotEmpty) return;

      // Default expense categories
      final expenseCategories = [
        {
          'name': 'Makanan & Minuman',
          'iconPath': 'assets/icons/food.png',
          'iconBgColor': Colors.orange.value,
          'isExpense': true,
        },
        {
          'name': 'Transportasi',
          'iconPath': 'assets/icons/transport.png',
          'iconBgColor': Colors.blue.value,
          'isExpense': true,
        },
        {
          'name': 'Belanja',
          'iconPath': 'assets/icons/shopping.png',
          'iconBgColor': Colors.pink.value,
          'isExpense': true,
        },
        {
          'name': 'Tagihan',
          'iconPath': 'assets/icons/bill.png',
          'iconBgColor': Colors.red.value,
          'isExpense': true,
        },
        {
          'name': 'Hiburan',
          'iconPath': 'assets/icons/entertainment.png',
          'iconBgColor': Colors.purple.value,
          'isExpense': true,
        },
      ];

      // Default income categories
      final incomeCategories = [
        {
          'name': 'Gaji',
          'iconPath': 'assets/icons/salary.png',
          'iconBgColor': Colors.green.value,
          'isExpense': false,
        },
        {
          'name': 'Bonus',
          'iconPath': 'assets/icons/bonus.png',
          'iconBgColor': Colors.teal.value,
          'isExpense': false,
        },
        {
          'name': 'Investasi',
          'iconPath': 'assets/icons/investment.png',
          'iconBgColor': Colors.indigo.value,
          'isExpense': false,
        },
        {
          'name': 'Hadiah',
          'iconPath': 'assets/icons/gift.png',
          'iconBgColor': Colors.amber.value,
          'isExpense': false,
        },
      ];

      // Add all categories
      final batch = _firestore.batch();
      for (var category in [...expenseCategories, ...incomeCategories]) {
        final docRef = _categoriesCollection.doc();
        batch.set(docRef, {
          ...category,
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

  Future<void> ensureDefaultCategoriesForUser() async {
    final userCatSnapshot = await _categoriesCollection.get();
    if (userCatSnapshot.docs.isEmpty) {
      // Tambahkan kategori default ke koleksi user
      final batch = _firestore.batch();
      final defaultCategories = [
        // Expense
        Category(
          id: 'expense_food',
          name: 'Makanan & Minuman',
          iconPath: 'assets/icons/food.png',
          iconBgColor: Colors.orange,
          isExpense: true,
        ),
        Category(
          id: 'expense_transport',
          name: 'Transportasi',
          iconPath: 'assets/icons/transport.png',
          iconBgColor: Colors.blue,
          isExpense: true,
        ),
        Category(
          id: 'expense_shopping',
          name: 'Belanja',
          iconPath: 'assets/icons/shopping.png',
          iconBgColor: Colors.pink,
          isExpense: true,
        ),
        Category(
          id: 'expense_bills',
          name: 'Tagihan',
          iconPath: 'assets/icons/bill.png',
          iconBgColor: Colors.red,
          isExpense: true,
        ),
        Category(
          id: 'expense_entertainment',
          name: 'Hiburan',
          iconPath: 'assets/icons/entertainment.png',
          iconBgColor: Colors.purple,
          isExpense: true,
        ),
        Category(
          id: 'expense_health',
          name: 'Kesehatan',
          iconPath: 'assets/icons/health.png',
          iconBgColor: Colors.green,
          isExpense: true,
        ),
        Category(
          id: 'expense_education',
          name: 'Pendidikan',
          iconPath: 'assets/icons/education.png',
          iconBgColor: Colors.indigo,
          isExpense: true,
        ),
        Category(
          id: 'expense_other',
          name: 'Lainnya',
          iconPath: 'assets/icons/other.png',
          iconBgColor: Colors.grey,
          isExpense: true,
        ),
        // Income
        Category(
          id: 'income_salary',
          name: 'Gaji',
          iconPath: 'assets/icons/salary.png',
          iconBgColor: Colors.teal,
          isExpense: false,
        ),
        Category(
          id: 'income_bonus',
          name: 'Bonus',
          iconPath: 'assets/icons/bonus.png',
          iconBgColor: Colors.amber,
          isExpense: false,
        ),
        Category(
          id: 'income_investment',
          name: 'Investasi',
          iconPath: 'assets/icons/investment.png',
          iconBgColor: Colors.lightGreen,
          isExpense: false,
        ),
        Category(
          id: 'income_other',
          name: 'Lainnya',
          iconPath: 'assets/icons/other.png',
          iconBgColor: Colors.grey,
          isExpense: false,
        ),
      ];
      for (final cat in defaultCategories) {
        final docRef = _categoriesCollection.doc(cat.id);
        batch.set(docRef, {
          'name': cat.name,
          'iconPath': cat.iconPath,
          'iconBgColor': cat.iconBgColor.value,
          'isExpense': cat.isExpense,
        });
      }
      await batch.commit();
      await loadCategories();
    }
  }
}
