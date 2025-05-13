// lib/screens/transactions/transaction_history_screen.dart
import 'package:flutter/material.dart';
import 'package:j_cash/constants/app_colors.dart'; // Sesuaikan package name
import 'package:j_cash/widgets/transaction_list_item.dart'; // Gunakan widget yg sama
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:provider/provider.dart';
import 'package:j_cash/providers/transaction_provider.dart';
import 'package:j_cash/models/transaction_item.dart';
import 'package:j_cash/providers/category_provider.dart';

class TransactionHistoryScreen extends StatefulWidget {
  // Gunakan StatefulWidget jika perlu state untuk filter
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  // --- State untuk Filter (Contoh) ---
  String _selectedTimeFilter = '1 Bulan Terakhir';
  String _selectedTypeFilter = 'Semua Transaksi';
  final List<String> _timeFilters = [
    '1 Bulan Terakhir',
    '3 Bulan Terakhir',
    'Semua Waktu',
  ];
  final List<String> _typeFilters = [
    'Semua Transaksi',
    'Pengeluaran',
    'Pemasukan',
  ];

  DateTime _getStartDate() {
    switch (_selectedTimeFilter) {
      case '1 Bulan Terakhir':
        return DateTime.now().subtract(const Duration(days: 30));
      case '3 Bulan Terakhir':
        return DateTime.now().subtract(const Duration(days: 90));
      default:
        return DateTime.now();
    }
  }

  bool? _getIsExpense() {
    switch (_selectedTypeFilter) {
      case 'Pengeluaran':
        return true;
      case 'Pemasukan':
        return false;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(
            color: AppColors.fontGreen,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.fontGreen),
            onPressed: () {
              // TODO: Implement filter dialog
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedTimeFilter,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: _timeFilters.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedTimeFilter = newValue;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedTypeFilter,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: _typeFilters.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedTypeFilter = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // Transaction List
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, _) => RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(Duration(milliseconds: 500));
                },
                child: StreamBuilder<List<TransactionItem>>(
                  stream: provider.getTransactions(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryGreen),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Terjadi kesalahan: \\${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    }

                    final transactions = snapshot.data ?? [];
                    if (transactions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/empty_transaction.png',
                              width: 120,
                              height: 120,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum ada transaksi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.greyText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tap + untuk menambah transaksi baru',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.greyText,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final categoryProvider =
                        Provider.of<CategoryProvider>(context, listen: false);
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        final category = categoryProvider
                            .getCategoryById(transaction.categoryId);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TransactionListItem(
                            category:
                                category?.name ?? transaction.categoryName,
                            iconPath:
                                category?.iconPath ?? transaction.categoryIcon,
                            date: DateFormat('EEEE, dd MMM', 'id_ID')
                                .format(transaction.date),
                            amount: transaction.amount,
                            iconBackgroundColor: category?.iconBgColor ??
                                Color(transaction.categoryColor),
                            notes: transaction.notes,
                            isExpense: transaction.isExpense,
                            onTap: () {
                              // TODO: Navigate to transaction detail
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widget untuk Dropdown Filter ---
  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.grey[100], // Background dropdown
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        // Sembunyikan garis bawah default
        child: DropdownButton<String>(
          value: value,
          isExpanded: true, // Agar dropdown mengisi lebar container
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: Colors.grey.shade700,
          ),
          style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
