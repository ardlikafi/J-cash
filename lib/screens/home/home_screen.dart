// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:j_cash/constants/app_colors.dart';
import 'package:j_cash/widgets/savings_card.dart';
import 'package:j_cash/widgets/transaction_list_item.dart';
import 'package:j_cash/screens/transactions/add_transaction_screen.dart';
import 'package:j_cash/screens/savings/add_savings_screen.dart';
import 'package:j_cash/screens/transactions/transaction_history_screen.dart';
import 'package:j_cash/services/savings_service.dart';
import 'package:j_cash/models/savings_goal.dart';
import 'package:intl/intl.dart';
import 'package:j_cash/widgets/modern_savings_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:j_cash/providers/transaction_provider.dart';
import 'package:j_cash/models/transaction_item.dart';
import 'package:j_cash/providers/category_provider.dart';
import 'package:j_cash/utils/currency_formatter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:j_cash/models/category.dart';

enum SavingsCardStyle { classic, modern }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final SavingsService _savingsService = SavingsService();
  String userName = "";
  String userImageUrl = '';
  double currentBalance = 0.0;

  SavingsCardStyle _selectedStyle = SavingsCardStyle.classic;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkInitialBalance());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Hapus: _loadSavings();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Hapus: _loadSavings();
  }

  Future<void> _showUpdateProgressDialog(SavingsGoal goal) async {
    final controller = TextEditingController(
      text: goal.currentAmount.toStringAsFixed(0),
    );
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Progress Tabungan'),
        content: TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Nominal Saat Ini',
            prefixText: 'Rp ',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value >= 0) {
                Navigator.pop(context, value);
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
    if (result != null) {
      final updated = SavingsGoal(
        id: goal.id,
        title: goal.title,
        targetAmount: goal.targetAmount,
        currentAmount: result,
        color: goal.color,
        iconPath: goal.iconPath,
      );
      await _savingsService.updateSavings(updated);
      // Tidak perlu _loadSavings(); karena pakai stream
    }
  }

  Future<void> _checkInitialBalance() async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid);
    final snapshot = await userDoc.get();
    final balance = snapshot.data()?['balance']?.toDouble() ?? 0.0;
    setState(() {
      currentBalance = balance;
    });
    if (balance == 0.0) {
      _showInitialBalanceDialog();
    }
  }

  void _showInitialBalanceDialog() {
    final controller = TextEditingController();
    bool isLoading = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Masukkan Saldo Awal'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
              decoration: const InputDecoration(
                labelText: 'Saldo Awal',
                prefixText: 'Rp ',
                hintText: '0',
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() => isLoading = true);
                        final raw = controller.text.replaceAll('.', '');
                        final value = double.tryParse(raw);
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (uid == null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('User tidak ditemukan!'),
                                  backgroundColor: Colors.red),
                            );
                          }
                          setState(() => isLoading = false);
                          return;
                        }
                        if (value != null && value > 0) {
                          final userDoc = FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid);
                          try {
                            await userDoc.set(
                                {'balance': value}, SetOptions(merge: true));
                            // Tambahkan transaksi saldo awal
                            final transaction = TransactionItem(
                              id: '',
                              categoryId: 'initial_balance',
                              categoryName: 'Saldo Awal',
                              categoryIcon: '',
                              categoryColor: 0xFF4CAF50,
                              amount: value,
                              date: DateTime.now(),
                              notes: 'Set Saldo Awal',
                              isExpense: false,
                            );
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .collection('transactions')
                                .add({
                              'categoryId': transaction.categoryId,
                              'amount': transaction.amount,
                              'date': Timestamp.fromDate(transaction.date),
                              'notes': transaction.notes,
                              'isExpense': transaction.isExpense,
                              'categoryName': transaction.categoryName,
                              'categoryIcon': transaction.categoryIcon,
                              'categoryColor': transaction.categoryColor,
                            });
                            // Ambil ulang balance setelah simpan
                            final snapshot = await userDoc.get();
                            final newBalance =
                                snapshot.data()?['balance']?.toDouble() ?? 0.0;
                            if (context.mounted) {
                              Navigator.pop(context);
                              this.setState(() {
                                currentBalance = newBalance;
                              });
                            }
                          } catch (e) {
                            print('Gagal simpan saldo: $e');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Gagal simpan saldo: $e'),
                                    backgroundColor: Colors.red),
                              );
                            }
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Masukkan nominal saldo yang valid!'),
                                  backgroundColor: Colors.red),
                            );
                          }
                        }
                        setState(() => isLoading = false);
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Simpan'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.white,
            pinned: true,
            floating: true,
            elevation: 0,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: _buildHeader(context, userName, userImageUrl),
            actions: [
              IconButton(
                icon: Image.asset(
                  'assets/icons/ic_bell.png',
                  height: 24,
                  color: AppColors.iconGrey,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.notifications_none,
                    color: AppColors.iconGrey,
                  ),
                ),
                onPressed: () {
                  print("Notification icon pressed");
                },
              ),
              const SizedBox(width: 10),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 15.0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final balance = snapshot.data?.data() != null
                        ? (snapshot.data!.data()
                                    as Map<String, dynamic>)['balance']
                                ?.toDouble() ??
                            0.0
                        : 0.0;
                    return _buildBalanceSection(context, balance);
                  },
                ),
                const SizedBox(height: 25),
                _buildSavingsSection(context),
                const SizedBox(height: 25),
                _buildRecentTransactions(context),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const TransactionHistoryScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Lihat Semua Transaksi',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, String imageUrl) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading profile');
        }

        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        final userName = userData?['name'] ?? 'User';
        final userImageUrl = userData?['photoURL'] ?? '';

        return Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 5),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey.shade300,
                child: Builder(
                  builder: (context) {
                    if (userImageUrl.isNotEmpty) {
                      if (userImageUrl.startsWith('/')) {
                        // Path lokal
                        return ClipOval(
                          child: Image.file(
                            File(userImageUrl),
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.person,
                                  size: 30, color: Colors.white);
                            },
                          ),
                        );
                      } else if (userImageUrl.startsWith('http')) {
                        // URL
                        return ClipOval(
                          child: Image.network(
                            userImageUrl,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.person,
                                  size: 30, color: Colors.white);
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const SizedBox(
                                width: 44,
                                height: 44,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        // Asset atau format lain
                        return const Icon(Icons.person,
                            size: 30, color: Colors.white);
                      }
                    } else {
                      // Tidak ada foto
                      return const Icon(Icons.person,
                          size: 30, color: Colors.white);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Selamat ${_getGreeting()}',
                    style: TextStyle(fontSize: 13, color: AppColors.greyText),
                  ),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Pagi';
    } else if (hour < 15) {
      return 'Siang';
    } else if (hour < 19) {
      return 'Sore';
    } else {
      return 'Malam';
    }
  }

  Widget _buildBalanceSection(BuildContext context, double balance) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saldo kamu bulan ini',
              style: TextStyle(fontSize: 14, color: AppColors.greyText),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(balance),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.fontGreen,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _showInitialBalanceDialog,
                  borderRadius: BorderRadius.circular(16),
                  child: const Icon(Icons.edit,
                      size: 22, color: AppColors.primaryGreen),
                ),
              ],
            ),
          ],
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTransactionScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(25),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsSection(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Rencana Tabungan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            TextButton(
              onPressed: () async {
                final result = await Navigator.push<SavingsGoal>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddSavingsScreen(),
                  ),
                );
                if (result != null) {
                  await SavingsService().addSavings(result);
                  // Tidak perlu _loadSavings(); karena pakai stream
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add, size: 18),
                  SizedBox(width: 4),
                  Text('Tambah'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: ToggleButtons(
              borderRadius: BorderRadius.circular(16),
              isSelected: [
                _selectedStyle == SavingsCardStyle.classic,
                _selectedStyle == SavingsCardStyle.modern,
              ],
              onPressed: (index) {
                setState(() {
                  _selectedStyle = index == 0
                      ? SavingsCardStyle.classic
                      : SavingsCardStyle.modern;
                });
              },
              color: Colors.grey[600],
              selectedColor: Colors.white,
              fillColor: AppColors.primaryGreen,
              constraints: const BoxConstraints(minWidth: 90, minHeight: 36),
              children: const [
                Text('Classic', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('Modern', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        StreamBuilder<List<SavingsGoal>>(
          stream: SavingsService().getSavingsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final savingsGoals = snapshot.data ?? [];
            if (savingsGoals.isEmpty) {
              return const Center(
                child: Text(
                  'Belum ada tabungan.\nTap Tambah untuk membuat tabungan baru.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              );
            }
            return SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: savingsGoals.length,
                itemBuilder: (context, index) {
                  final goal = savingsGoals[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == savingsGoals.length - 1 ? 0 : 12,
                    ),
                    child: _selectedStyle == SavingsCardStyle.classic
                        ? SavingsCard(
                            title: goal.title,
                            progress: goal.progress,
                            currentAmount: goal.currentAmount,
                            targetAmount: goal.targetAmount,
                            color: goal.color ?? Colors.blue,
                            iconPath: goal.iconPath,
                            onTap: () async {
                              // Bisa tambahkan aksi update progress jika ingin
                            },
                          )
                        : ModernSavingsCard(
                            title: goal.title,
                            currentAmount: goal.currentAmount,
                            targetAmount: goal.targetAmount,
                            iconPath: goal.iconPath,
                            onTap: () async {
                              // Bisa tambahkan aksi update progress jika ingin
                            },
                          ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transaksi Terakhir',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 15),
        Consumer<TransactionProvider>(
          builder: (context, provider, _) => RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(Duration(milliseconds: 500));
            },
            child: StreamBuilder<List<TransactionItem>>(
              stream: provider.getTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final transactions = snapshot.data ?? [];
                if (transactions.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada transaksi.\nTap + untuk menambah transaksi baru.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: transactions.length > 5 ? 5 : transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    final categoryProvider =
                        Provider.of<CategoryProvider>(context, listen: false);
                    final category = categoryProvider
                        .getCategoryById(transaction.categoryId);
                    return TransactionListItem(
                      category: category?.name ?? transaction.categoryName,
                      iconPath: category?.iconPath ?? transaction.categoryIcon,
                      date: DateFormat('EEEE, dd MMM', 'id_ID')
                          .format(transaction.date),
                      amount: transaction.amount,
                      iconBackgroundColor: category?.iconBgColor ??
                          Color(transaction.categoryColor),
                      notes: transaction.notes,
                      isExpense: transaction.isExpense,
                      onTap: () {},
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
