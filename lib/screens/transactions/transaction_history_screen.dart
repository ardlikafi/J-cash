// lib/screens/transactions/transaction_history_screen.dart
import 'package:flutter/material.dart';
import 'package:j_cash/constants/app_colors.dart'; // Sesuaikan package name
import 'package:j_cash/widgets/transaction_list_item.dart'; // Gunakan widget yg sama
import 'package:intl/intl.dart'; // Untuk format tanggal

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

  // --- Placeholder Data Transaksi Lengkap ---
  // Nanti ini diambil dari Firebase/Provider berdasarkan filter
  final List<Map<String, dynamic>> _allTransactions = [
    // Data Mei 2025 (Contoh dari desain)
    {
      'date': DateTime(2025, 5, 27),
      'category': 'Beli Seblak',
      'icon': 'assets/icons/ic_food.png',
      'amount': -25000.0,
      'color': Colors.orange.shade100,
    },
    {
      'date': DateTime(2025, 5, 27),
      'category': 'Affiliate',
      'icon': 'assets/icons/ic_income.png',
      'amount': 100000000.0,
      'color': Colors.green.shade100,
    },
    {
      'date': DateTime(2025, 5, 27),
      'category': 'Gym',
      'icon': 'assets/icons/ic_gym.png',
      'amount': -160000.0,
      'color': Colors.purple.shade100,
    }, // Asumsi Gym pengeluaran di riwayat
    {
      'date': DateTime(2025, 5, 27),
      'category': 'Affiliate',
      'icon': 'assets/icons/ic_income.png',
      'amount': 100000000.0,
      'color': Colors.green.shade100,
    },
    {
      'date': DateTime(2025, 5, 27),
      'category': 'Affiliate',
      'icon': 'assets/icons/ic_income.png',
      'amount': 100000000.0,
      'color': Colors.green.shade100,
    },
    {
      'date': DateTime(2025, 5, 27),
      'category': 'Affiliate',
      'icon': 'assets/icons/ic_income.png',
      'amount': 100000000.0,
      'color': Colors.green.shade100,
    },
    // Data April 2025 (Contoh tambahan)
    {
      'date': DateTime(2025, 4, 15),
      'category': 'Gaji',
      'icon': 'assets/icons/ic_income.png',
      'amount': 5000000.0,
      'color': Colors.green.shade100,
    },
    {
      'date': DateTime(2025, 4, 10),
      'category': 'Belanja Bulanan',
      'icon': 'assets/icons/ic_shopping.png',
      'amount': -750000.0,
      'color': Colors.teal.shade100,
    },
    {
      'date': DateTime(2025, 4, 5),
      'category': 'Tagihan Listrik',
      'icon': 'assets/icons/ic_tagihan.png',
      'amount': -150000.0,
      'color': Colors.blue.shade100,
    },
    // Tambah data dummy lain untuk bulan/tanggal berbeda
  ];

  // --- Fungsi Helper untuk Mengelompokkan Transaksi per Bulan/Tahun ---
  Map<String, List<Map<String, dynamic>>> _groupTransactionsByMonth(
    List<Map<String, dynamic>> transactions,
  ) {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    // Urutkan transaksi dari terbaru ke terlama
    transactions.sort(
      (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
    );

    for (var transaction in transactions) {
      // Buat key berdasarkan "MMMM yyyy" (misal: "Mei 2025")
      String monthYear = DateFormat(
        'MMMM yyyy',
        'id_ID',
      ).format(transaction['date']);
      if (grouped[monthYear] == null) {
        grouped[monthYear] = [];
      }
      grouped[monthYear]!.add(transaction);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Terapkan filter ke _allTransactions sebelum dikelompokkan
    final groupedTransactions = _groupTransactionsByMonth(_allTransactions);
    final months = groupedTransactions.keys.toList();

    // Hitung summary (contoh sederhana)
    double totalIncome = _allTransactions
        .where((t) => t['amount'] >= 0)
        .fold(0, (sum, t) => sum + t['amount']);
    double totalExpense = _allTransactions
        .where((t) => t['amount'] < 0)
        .fold(0, (sum, t) => sum + t['amount'].abs());

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
        backgroundColor: AppColors.white, // Atau sedikit abu2: Colors.grey[50]
        elevation: 0.5,
        centerTitle: true,
        automaticallyImplyLeading:
            false, // Sembunyikan tombol back default krn ini halaman tab
        // Tambahkan tombol filter/search jika perlu
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey.shade700),
            onPressed: () {
              print("Search tapped"); /* TODO */
            },
          ),
        ],
      ),
      backgroundColor: AppColors.white, // Atau Colors.grey[50],
      body: Column(
        children: [
          // --- Baris Filter ---
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 10.0,
            ),
            child: Row(
              children: [
                // Filter Waktu
                Expanded(
                  child: _buildFilterDropdown(
                    value: _selectedTimeFilter,
                    items: _timeFilters,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedTimeFilter = newValue!;
                      });
                      // TODO: Terapkan filter waktu
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // Filter Tipe
                Expanded(
                  child: _buildFilterDropdown(
                    value: _selectedTypeFilter,
                    items: _typeFilters,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedTypeFilter = newValue!;
                      });
                      // TODO: Terapkan filter tipe
                    },
                  ),
                ),
              ],
            ),
          ),

          // --- List Transaksi (Scrollable) ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              itemCount: months.length, // Jumlah bulan
              itemBuilder: (context, index) {
                String monthYear = months[index];
                List<Map<String, dynamic>> transactionsInMonth =
                    groupedTransactions[monthYear]!;

                // Hitung summary per bulan (jika perlu)
                double monthIncome = transactionsInMonth
                    .where((t) => t['amount'] >= 0)
                    .fold(0, (sum, t) => sum + t['amount']);
                double monthExpense = transactionsInMonth
                    .where((t) => t['amount'] < 0)
                    .fold(0, (sum, t) => sum + t['amount'].abs());

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bulan dan Summary
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 20.0,
                        bottom: 10.0,
                        left: 5.0,
                        right: 5.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            monthYear,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Pengeluaran: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(monthExpense)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.error,
                                ),
                              ),
                              Text(
                                'Pemasukan: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(monthIncome)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.fontGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // List transaksi untuk bulan ini
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactionsInMonth.length,
                      itemBuilder: (context, itemIndex) {
                        final transaction = transactionsInMonth[itemIndex];
                        // Gunakan TransactionListItem yang sudah ada
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: TransactionListItem(
                            category: transaction['category'] ?? 'Lainnya',
                            // Format tanggal jadi "Selasa, 27 Mei"
                            date: DateFormat(
                              'EEEE, d MMM',
                              'id_ID',
                            ).format(transaction['date']),
                            amount: transaction['amount']?.toDouble() ?? 0.0,
                            iconPath:
                                transaction['icon'] ??
                                'assets/icons/ic_transaksi_active.png', // Pastikan ada default
                            iconBackgroundColor:
                                transaction['color'] ?? Colors.grey.shade200,
                            onTap: () {
                              print(
                                "Transaction tapped: ${transaction['category']}",
                              ); /* TODO: Navigasi ke detail */
                            },
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
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
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
