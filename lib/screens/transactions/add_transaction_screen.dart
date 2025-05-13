// lib/screens/transactions/add_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:j_cash/constants/app_colors.dart'; // Sesuaikan package name
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:intl/intl.dart';
import 'package:j_cash/models/category.dart';
import 'package:provider/provider.dart';
import 'package:j_cash/providers/transaction_provider.dart';
import 'package:j_cash/models/transaction_item.dart';
import 'package:j_cash/providers/category_provider.dart';
import 'package:j_cash/widgets/category_selector.dart';
import 'package:j_cash/utils/date_formatter.dart';
import 'package:j_cash/utils/currency_formatter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isExpense = true;
  bool _isLoading = false;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<TransactionProvider>(context, listen: false)
            .setUserId(user.uid);
        Provider.of<CategoryProvider>(context, listen: false).loadCategories();
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String cleanAmount = _amountController.text.replaceAll('.', '');
      final amount = double.parse(cleanAmount);

      if (amount <= 0) {
        throw 'Jumlah transaksi harus lebih dari 0';
      }

      final categoryProvider = context.read<CategoryProvider>();
      Category? category =
          categoryProvider.getCategoryById(_selectedCategoryId!);

      if (category == null) {
        throw 'Kategori tidak ditemukan';
      }

      final transaction = TransactionItem(
        id: '',
        categoryId: category.id,
        categoryName: category.name,
        categoryIcon: category.iconPath,
        categoryColor: category.iconBgColor.value,
        amount: amount,
        date: _selectedDate,
        notes: _notesController.text.trim(),
        isExpense: _isExpense,
      );

      await context.read<TransactionProvider>().addTransaction(transaction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil disimpan')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan transaksi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isKeyboardOpen = mediaQuery.viewInsets.bottom > 0;
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Tambah Transaksi',
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding:
                  EdgeInsets.fromLTRB(20, 0, 20, isKeyboardOpen ? 100 : 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 85,
                      child: _HorizontalDatePicker(
                        selectedDate: _selectedDate,
                        onDateSelected: (date) {
                          setState(() => _selectedDate = date);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jumlah Transaksi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '0',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                              prefixText: 'Rp ',
                              prefixStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            inputFormatters: [CurrencyInputFormatter()],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Masukkan jumlah transaksi';
                              }
                              final amount =
                                  double.tryParse(value.replaceAll('.', ''));
                              if (amount == null || amount <= 0) {
                                return 'Jumlah harus lebih dari 0';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // --- Kategori ---
                    const Text(
                      'Kategori',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final selected = await showModalBottomSheet<String>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          builder: (context) => _CategoryBottomSheet(
                            isExpense: _isExpense,
                            selectedCategoryId: _selectedCategoryId,
                            categories: categoryProvider.categories,
                          ),
                        );
                        if (selected != null) {
                          setState(() {
                            _selectedCategoryId = selected;
                            final cat =
                                categoryProvider.getCategoryById(selected);
                            if (cat != null) {
                              _isExpense = cat.isExpense;
                            }
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.category, color: Colors.grey.shade400),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  final category =
                                      categoryProvider.getCategoryById(
                                          _selectedCategoryId ?? '');
                                  if (_selectedCategoryId == null) {
                                    return Text(
                                      'Pilih Kategori',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15,
                                      ),
                                    );
                                  } else if (category != null) {
                                    return Text(
                                      category.name,
                                      style: const TextStyle(
                                        color: AppColors.black,
                                        fontSize: 15,
                                      ),
                                    );
                                  } else {
                                    return Text(
                                      _selectedCategoryId ??
                                          'Kategori Tidak Ditemukan',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 15,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded,
                                color: AppColors.primaryGreen),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // --- Catatan ---
                    const Text(
                      'Tambah Catatan',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan catatan (opsional)',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // --- Placeholder Rincian Lainnya ---
                    ExpansionTile(
                      title: Text(
                        'Tambahkan rincian lainnya',
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Fitur ini akan segera hadir!',
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (!isKeyboardOpen)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Simpan Transaksi'),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- Modal BottomSheet Kategori ---
class _CategoryBottomSheet extends StatefulWidget {
  final bool isExpense;
  final String? selectedCategoryId;
  final List<Category> categories;
  const _CategoryBottomSheet(
      {required this.isExpense,
      this.selectedCategoryId,
      required this.categories});

  @override
  State<_CategoryBottomSheet> createState() => _CategoryBottomSheetState();
}

class _CategoryBottomSheetState extends State<_CategoryBottomSheet> {
  late bool _isExpenseTab;

  @override
  void initState() {
    super.initState();
    _isExpenseTab = widget.isExpense;
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        widget.categories.where((c) => c.isExpense == _isExpenseTab).toList();
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding:
              const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Pilih Kategori',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isExpenseTab = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isExpenseTab
                                ? AppColors.primaryGreen
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'Pengeluaran',
                              style: TextStyle(
                                color: _isExpenseTab
                                    ? Colors.white
                                    : AppColors.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isExpenseTab = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isExpenseTab
                                ? AppColors.primaryGreen
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'Pemasukan',
                              style: TextStyle(
                                color: !_isExpenseTab
                                    ? Colors.white
                                    : AppColors.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: categories.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada kategori',
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 16),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final cat = categories[i];
                          return ListTile(
                            onTap: () => Navigator.pop(context, cat.id),
                            leading: CircleAvatar(
                              backgroundColor: cat.iconBgColor,
                              child: cat.iconPath.isNotEmpty
                                  ? Image.asset(
                                      cat.iconPath,
                                      height: 22,
                                      width: 22,
                                      errorBuilder: (c, e, s) =>
                                          const Icon(Icons.category),
                                    )
                                  : const Icon(Icons.category),
                            ),
                            title: Text(cat.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            trailing: widget.selectedCategoryId == cat.id
                                ? const Icon(Icons.check_circle,
                                    color: AppColors.primaryGreen)
                                : null,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Tambahkan widget custom horizontal date picker di bawah kelas utama
class _HorizontalDatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  const _HorizontalDatePicker(
      {required this.selectedDate, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 3));
    final dates = List.generate(
        7, (i) => DateTime(start.year, start.month, start.day + i));
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: dates.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (context, i) {
        final date = dates[i];
        final isSelected = date.year == selectedDate.year &&
            date.month == selectedDate.month &&
            date.day == selectedDate.day;
        return GestureDetector(
          onTap: () => onDateSelected(date),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 60,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryGreen : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : Colors.grey.shade300,
                  width: 2),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ]
                  : [],
            ),
            padding: const EdgeInsets.symmetric(
                vertical: 6, horizontal: 0), // Perkecil padding vertikal
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getShortMonth(date),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date.day.toString().padLeft(2, '0'),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getShortDay(date),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      clipBehavior: Clip.hardEdge, // Tambahkan clip agar tidak overflow
    );
  }

  String _getShortMonth(DateTime date) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MEI',
      'JUN',
      'JUL',
      'AGU',
      'SEP',
      'OKT',
      'NOV',
      'DES'
    ];
    return months[date.month - 1];
  }

  String _getShortDay(DateTime date) {
    const days = ['MIN', 'SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB'];
    return days[date.weekday % 7];
  }
}
