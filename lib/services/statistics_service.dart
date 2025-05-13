import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatisticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user ID
  String get _userId => _auth.currentUser?.uid ?? '';

  // Collection references
  CollectionReference get _transactionsCollection =>
      _firestore.collection('users').doc(_userId).collection('transactions');

  // Get total amount for a period
  Future<double> getTotalAmount({
    required DateTime startDate,
    required DateTime endDate,
    required bool isExpense,
  }) async {
    try {
      final snapshot =
          await _transactionsCollection
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
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
      rethrow;
    }
  }

  // Get amount by category
  Future<Map<String, double>> getAmountByCategory({
    required DateTime startDate,
    required DateTime endDate,
    required bool isExpense,
  }) async {
    try {
      final snapshot =
          await _transactionsCollection
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
              .where('isExpense', isEqualTo: isExpense)
              .get();

      final Map<String, double> categoryAmounts = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final categoryName = data['categoryName'] as String? ?? '';
        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
        categoryAmounts[categoryName] =
            (categoryAmounts[categoryName] ?? 0.0) + amount;
      }
      return categoryAmounts;
    } catch (e) {
      rethrow;
    }
  }

  // Get amount by day
  Future<Map<DateTime, double>> getAmountByDay({
    required DateTime startDate,
    required DateTime endDate,
    required bool isExpense,
  }) async {
    try {
      final snapshot =
          await _transactionsCollection
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
              .where('isExpense', isEqualTo: isExpense)
              .get();

      final Map<DateTime, double> dailyAmounts = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final date = (data['date'] as Timestamp).toDate();
        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
        dailyAmounts[date] = (dailyAmounts[date] ?? 0.0) + amount;
      }
      return dailyAmounts;
    } catch (e) {
      rethrow;
    }
  }

  // Get amount by month
  Future<Map<DateTime, double>> getAmountByMonth({
    required DateTime startDate,
    required DateTime endDate,
    required bool isExpense,
  }) async {
    try {
      final snapshot =
          await _transactionsCollection
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
              .where('isExpense', isEqualTo: isExpense)
              .get();

      final Map<DateTime, double> monthlyAmounts = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final date = (data['date'] as Timestamp).toDate();
        final monthStart = DateTime(date.year, date.month, 1);
        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
        monthlyAmounts[monthStart] =
            (monthlyAmounts[monthStart] ?? 0.0) + amount;
      }
      return monthlyAmounts;
    } catch (e) {
      rethrow;
    }
  }

  // Get top categories
  Future<List<Map<String, dynamic>>> getTopCategories({
    required DateTime startDate,
    required DateTime endDate,
    required bool isExpense,
    int limit = 5,
  }) async {
    try {
      final categoryAmounts = await getAmountByCategory(
        startDate: startDate,
        endDate: endDate,
        isExpense: isExpense,
      );

      final sortedCategories =
          categoryAmounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      return sortedCategories
          .take(limit)
          .map((e) => {'categoryName': e.key, 'amount': e.value})
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get trend percentage
  Future<double> getTrendPercentage({
    required DateTime currentStartDate,
    required DateTime currentEndDate,
    required DateTime previousStartDate,
    required DateTime previousEndDate,
    required bool isExpense,
  }) async {
    try {
      final currentAmount = await getTotalAmount(
        startDate: currentStartDate,
        endDate: currentEndDate,
        isExpense: isExpense,
      );

      final previousAmount = await getTotalAmount(
        startDate: previousStartDate,
        endDate: previousEndDate,
        isExpense: isExpense,
      );

      if (previousAmount == 0) return 0.0;
      return ((currentAmount - previousAmount) / previousAmount) * 100;
    } catch (e) {
      rethrow;
    }
  }
}
