// lib/screens/transactions/add_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:j_cash/constants/app_colors.dart'; // Sesuaikan package name
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:intl/intl.dart';

// Model sederhana untuk kategori
class Category {
  final String name;
  final String iconPath;
  final bool isExpense;
  final Color? iconBgColor;

  Category({
    required this.name,
    required this.iconPath,
    this.isExpense = true,
    this.iconBgColor,
  });
}

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  Category? _selectedCategory;
  bool _showOtherDetails = false;

  // Daftar Kategori Lengkap
  final List<Category> _allCategories = [
    // Pengeluaran (Pastikan path ikon benar)
    Category(
      name: 'Gym & Kesehatan',
      iconPath: 'assets/icons/ic_gym.png',
      iconBgColor: const Color(0xFFE8DCFF),
    ),
    Category(
      name: 'Asuransi',
      iconPath: 'assets/icons/ic_insurance.png',
      iconBgColor: const Color(0xFFFFF3CD),
    ),
    Category(
      name: 'Tagihan',
      iconPath: 'assets/icons/ic_tagihan.png',
      iconBgColor: const Color(0xFFE1EFFF),
    ),
    Category(
      name: 'Belanja',
      iconPath: 'assets/icons/ic_shopping.png',
      iconBgColor: const Color(0xFFD7FFF0),
    ),
    Category(
      name: 'Makanan & Minuman',
      iconPath: 'assets/icons/ic_makanan.png',
      iconBgColor: const Color(0xFFD9F2FF),
    ),
    Category(
      name: 'Internet',
      iconPath: 'assets/icons/ic_internet.png',
      iconBgColor: const Color(0xFFEDEDED),
    ),
    Category(
      name: 'Transportasi',
      iconPath: 'assets/icons/ic_car_card.png',
      iconBgColor: Colors.orange.shade100,
    ), // Contoh
    // Pemasukan (Pastikan path ikon benar)
    Category(
      name: 'Gaji',
      iconPath: 'assets/icons/ic_income.png',
      isExpense: false,
      iconBgColor: Colors.green.shade100,
    ),
    Category(
      name: 'Bonus',
      iconPath: 'assets/icons/ic_income.png',
      isExpense: false,
      iconBgColor: Colors.green.shade100,
    ),
    Category(
      name: 'Affiliate',
      iconPath: 'assets/icons/ic_income.png',
      isExpense: false,
      iconBgColor: Colors.green.shade100,
    ),
    Category(
      name: 'Lainnya',
      iconPath: 'assets/icons/ic_default_transaction.png',
      iconBgColor: Colors.grey.shade200,
    ), // Default
  ];

  // Filter kategori berdasarkan tipe
  List<Category> get _expenseCategories =>
      _allCategories.where((cat) => cat.isExpense).toList();
  List<Category> get _incomeCategories =>
      _allCategories.where((cat) => !cat.isExpense).toList();

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Fungsi untuk menyimpan transaksi
  void _saveTransaction() {
    bool isExpense =
        _selectedCategory?.isExpense ?? true; // Default pengeluaran

    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      double? amount = double.tryParse(
        _amountController.text.replaceAll(RegExp(r'[Rp.]'), ''),
      );

      if (amount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Format jumlah tidak valid')),
        );
        return;
      }

      double finalAmount = isExpense ? -amount : amount;
      String notes = _notesController.text;
      DateTime date = _selectedDate;
      String categoryName = _selectedCategory!.name;
      String categoryIcon = _selectedCategory!.iconPath;

      // --- Print data untuk debugging ---
      print('--- Saving Transaction ---');
      print('Amount: $finalAmount');
      print('Category Name: $categoryName');
      print('Category Icon: $categoryIcon');
      print('Category Type: ${isExpense ? 'Expense' : 'Income'}');
      print('Date: ${DateFormat('yyyy-MM-dd').format(date)}');
      print('Notes: $notes');
      print('-------------------------');
      // -----------------------------

      // TODO: Implementasi simpan ke Firebase/Provider

      Navigator.pop(context); // Kembali setelah simpan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaksi "$categoryName" berhasil disimpan!')),
      );
    } else if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih kategori transaksi')),
      );
    }
  }

  // --- Fungsi untuk menampilkan modal pilih kategori ---
  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        bool modalIsExpense = _selectedCategory?.isExpense ?? true;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            List<Category> categoriesToShow =
                modalIsExpense ? _expenseCategories : _incomeCategories;

            return Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Modal
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.grey.shade700,
                              size: 22,
                            ),
                          ),
                        ),
                        const Text(
                          'Pilih Kategori',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            print("Filter in modal tapped");
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              'assets/icons/ic_filter.png',
                              height: 22,
                              color: Colors.grey.shade700,
                            ), // Pastikan ikon filter ada
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Toggle P/P
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ToggleButtons(
                      isSelected: [modalIsExpense, !modalIsExpense],
                      onPressed: (int index) {
                        setModalState(() {
                          modalIsExpense = index == 0;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      selectedColor: AppColors.white,
                      color: Colors.grey.shade700,
                      fillColor: AppColors.primaryGreen,
                      renderBorder: false,
                      constraints: BoxConstraints(
                        minWidth:
                            (MediaQuery.of(context).size.width - 40 - 8 - 40) /
                            2,
                        minHeight: 40,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Pengeluaran',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Pemasukan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // List Kategori
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      itemCount: categoriesToShow.length,
                      itemBuilder: (context, index) {
                        final category = categoriesToShow[index];
                        bool isCurrentlySelected =
                            _selectedCategory?.name == category.name;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isCurrentlySelected
                                        ? AppColors.primaryGreen
                                        : Colors.grey.shade200,
                                width: isCurrentlySelected ? 1.8 : 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      isCurrentlySelected
                                          ? AppColors.primaryGreen.withOpacity(
                                            0.1,
                                          )
                                          : Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor:
                                      category.iconBgColor ??
                                      Colors.grey.shade100,
                                  child: Image.asset(
                                    category.iconPath,
                                    height: 22,
                                    width: 22,
                                    color: AppColors.black.withOpacity(0.8),
                                    errorBuilder:
                                        (c, e, s) => const Icon(
                                          Icons.error_outline,
                                          size: 22,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    category.name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height:
                        MediaQuery.of(context).padding.bottom > 0
                            ? MediaQuery.of(context).padding.bottom
                            : 15,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- Implementasi AppBar ---
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            splashRadius: 25,
            icon: Image.asset(
              'assets/icons/ic_btn_back.png',
              height: 30,
              width: 30,
            ), // Pastikan ikon ini ada
            onPressed: () => Navigator.pop(context),
          ),
        ),
        leadingWidth: 60,
        title: const Text(
          'Tambah Transaksi',
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
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              splashRadius: 25,
              icon: Image.asset(
                'assets/icons/ic_filter.png',
                height: 30,
                width: 30,
                color: Colors.grey.shade700,
              ), // Pastikan ikon ini ada
              onPressed: () {
                print("Filter button on AppBar pressed"); /* TODO */
              },
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.white,
      // --- Implementasi Body ---
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          children: [
            // --- Date Picker Timeline ---
            DatePicker(
              DateTime.now().subtract(const Duration(days: 30)),
              initialSelectedDate: _selectedDate,
              selectionColor: AppColors.primaryGreen,
              selectedTextColor: Colors.white,
              dayTextStyle: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
              dateTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
              monthTextStyle: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
              height: 90,
              daysCount: 60,
              locale: 'id_ID',
              onDateChange: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
              deactivatedColor: Colors.grey.shade100,
            ),
            const SizedBox(height: 25),

            // --- Input Jumlah Transaksi ---
            _buildInputAmountContainer(),
            const SizedBox(height: 25),

            // --- Pilih Kategori ---
            const Text(
              'Kategori',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildCategorySelector(),
            const SizedBox(height: 20),

            // --- Tambah Catatan ---
            const Text(
              'Tambah Catatan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildNotesField(),
            const SizedBox(height: 20),

            // --- Tambahkan Rincian Lainnya ---
            _buildExpandableDetails(),
            // const SizedBox(height: 30), // Jarak diatur dalam expandable

            // --- Tombol Simpan ---
            _buildSaveButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Implementasi Helper Widgets ---

  Widget _buildInputAmountContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF31A664), // Warna hijau gelap
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jumlah Transaksi',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: _amountController,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.95),
            ),
            textAlign: TextAlign.start,
            decoration: InputDecoration(
              prefixText: 'Rp ',
              prefixStyle: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.95),
              ),
              hintText: '0',
              hintStyle: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.5),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  double.tryParse(value) == 0) {
                return 'Jumlah tidak boleh kosong';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return InkWell(
      onTap: _showCategoryPicker,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            if (_selectedCategory != null)
              Image.asset(
                _selectedCategory!.iconPath,
                height: 24,
                width: 24,
                color: AppColors.black.withOpacity(0.7),
                errorBuilder:
                    (c, e, s) => const Icon(Icons.category_outlined, size: 24),
              )
            else
              Icon(
                Icons.category_outlined,
                size: 24,
                color: Colors.grey.shade600,
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedCategory?.name ?? 'Pilih Kategori',
                style: TextStyle(
                  fontSize: 15,
                  color:
                      _selectedCategory == null
                          ? Colors.grey.shade600
                          : Colors.black,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: InputDecoration(
        hintText: 'Tambahkan catatan (opsional)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
      ),
      textCapitalization: TextCapitalization.sentences,
      maxLines: 3,
    );
  }

  Widget _buildExpandableDetails() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _showOtherDetails = !_showOtherDetails;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tambahkan rincian lainnya',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  _showOtherDetails
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300), // Duration sudah ada
          curve: Curves.easeInOut,
          child: Visibility(
            visible: _showOtherDetails,
            child: Column(
              children: [
                const SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Lokasi (Opsional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                OutlinedButton.icon(
                  onPressed: () {
                    /* TODO: Logic upload lampiran */
                  },
                  icon: const Icon(Icons.attach_file),
                  label: const Text("Lampirkan Bukti"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: const BorderSide(color: AppColors.primaryGreen),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveTransaction, // onPressed sudah ada
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('Simpan Transaksi'),
    );
  }
} // Akhir class _AddTransactionScreenState
