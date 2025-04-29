// lib/screens/savings/create_savings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk input formatter
import 'package:j_cash/constants/app_colors.dart'; // Sesuaikan package name
import 'package:intl/intl.dart'; // Untuk parsing currency

class CreateSavingsScreen extends StatefulWidget {
  const CreateSavingsScreen({super.key});

  @override
  State<CreateSavingsScreen> createState() => _CreateSavingsScreenState();
}

class _CreateSavingsScreenState extends State<CreateSavingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  String? _selectedIconPath; // Menyimpan path ikon yang dipilih

  // Daftar ikon yang bisa dipilih untuk tabungan
  final List<String> _availableIcons = [
    'assets/icons/ic_home_card.png',
    'assets/icons/ic_car_card.png',
    'assets/icons/ic_investment_card.png',
    // Tambahkan ikon relevan lainnya jika ada
    'assets/icons/ic_shopping.png', // Contoh: untuk belanja
    'assets/icons/ic_default_saving.png', // Ikon default
  ];

  @override
  void initState() {
    super.initState();
    // Set ikon default terpilih
    _selectedIconPath = _availableIcons.last;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  void _saveSavingsGoal() {
    if (_formKey.currentState!.validate() && _selectedIconPath != null) {
      String name = _nameController.text;
      // Parse input amount (menghilangkan 'Rp' dan '.')
      double? targetAmount = double.tryParse(
        _targetAmountController.text.replaceAll(RegExp(r'[Rp.]'), ''),
      );

      if (targetAmount == null) {
        // Tampilkan error jika parsing gagal (opsional)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Format target jumlah tidak valid')),
        );
        return;
      }

      String iconPath = _selectedIconPath!;

      print('--- Saving New Goal ---');
      print('Name: $name');
      print('Target Amount: $targetAmount');
      print('Icon Path: $iconPath');
      print('-----------------------');

      // TODO: Implementasi logic untuk menyimpan data ke Firebase/Provider
      // 1. Buat objek SavingsGoal baru
      // 2. Tambahkan ke list savingsData di state management
      // 3. Mungkin simpan ke Firestore

      // Kembali ke halaman sebelumnya (HomeScreen)
      Navigator.pop(context);

      // Tampilkan pesan sukses (opsional)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tabungan "$name" berhasil dibuat!')),
      );
    } else if (_selectedIconPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih ikon untuk tabungan')),
      );
    }
  }

  // Formatter untuk input Rupiah
  final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Gunakan AppBar standar dengan tombol back otomatis
        title: const Text(
          'Buat Tabungan Baru',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.white, // Background AppBar putih
        foregroundColor: AppColors.black, // Warna tombol back & title
        elevation: 1.0, // Sedikit shadow
        centerTitle: true,
      ),
      backgroundColor: AppColors.white, // Background halaman putih
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Input Nama Tabungan ---
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Tabungan',
                  hintText: 'Contoh: Dana Darurat, Liburan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.label_outline),
                  // Hapus fillColor agar default putih
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tabungan tidak boleh kosong';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 20),

              // --- Input Target Jumlah ---
              TextFormField(
                controller: _targetAmountController,
                decoration: InputDecoration(
                  labelText: 'Target Jumlah',
                  hintText: 'Contoh: Rp 10.000.000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.track_changes_outlined),
                  // Hapus fillColor
                ),
                keyboardType: TextInputType.number,
                // Input formatter untuk angka dan titik/koma (sesuaikan)
                // Menggunakan FilteringTextInputFormatter untuk hanya angka
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  // Custom formatter untuk menambahkan 'Rp' dan '.' (jika diperlukan saat input)
                  // Atau biarkan input angka saja, format saat display/parsing
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Target jumlah tidak boleh kosong';
                  }
                  if (double.tryParse(value.replaceAll(RegExp(r'[Rp.]'), '')) ==
                      null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
                // Format saat input (opsional, bisa membingungkan user)
                /*
                 onChanged: (value) {
                   if (value.isNotEmpty) {
                     value = value.replaceAll(RegExp(r'[Rp.]'), '');
                     double amount = double.tryParse(value) ?? 0;
                     final formattedValue = _currencyFormatter.format(amount);
                     // Hati-hati infinite loop jika langsung set controller
                     // Mungkin perlu logic cursor position
                     // _targetAmountController.value = TextEditingValue(
                     //   text: formattedValue,
                     //   selection: TextSelection.collapsed(offset: formattedValue.length),
                     // );
                   }
                 },
                 */
              ),
              const SizedBox(height: 30),

              // --- Pilihan Ikon ---
              const Text(
                'Pilih Ikon',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 60, // Tinggi area ikon
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableIcons.length,
                  itemBuilder: (context, index) {
                    final iconPath = _availableIcons[index];
                    bool isSelected = iconPath == _selectedIconPath;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIconPath = iconPath;
                        });
                      },
                      child: Container(
                        width: 60,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.primaryGreen.withOpacity(0.2)
                                  : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                isSelected
                                    ? AppColors.primaryGreen
                                    : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Image.asset(
                            iconPath,
                            height: 30,
                            width: 30,
                            color: AppColors.black.withOpacity(0.7),
                            errorBuilder:
                                (c, e, s) => const Icon(Icons.error, size: 30),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              // --- Tombol Simpan ---
              ElevatedButton(
                onPressed: _saveSavingsGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primaryGreen, // Warna tombol simpan
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Simpan Tabungan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
