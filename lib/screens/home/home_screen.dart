// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:j_cash/constants/app_colors.dart';
import 'package:j_cash/widgets/savings_card.dart'; // Pastikan file ini ada
import 'package:j_cash/widgets/transaction_list_item.dart'; // Pastikan file ini ada
import 'package:j_cash/screens/transactions/add_transaction_screen.dart';
import 'package:j_cash/screens/savings/create_savings_screen.dart';
import 'package:j_cash/screens/transactions/transaction_history_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  String userName = "Kim Ji Won";
  String userImageUrl =
      'assets/icons/ic_profile.png'; // Pastikan gambar ini ada
  double currentBalance = 999999.0;

  List<Map<String, dynamic>> savingsData = [
    {
      'title': 'Beli Rumah',
      'iconPath': 'assets/icons/ic_home_card.png', // Pastikan ikon ini ada
      'progress': 0.1, 'currentAmount': 10000000.0, 'target': 100000000.0,
      'color': AppColors.savingsCardBg1,
    },
    {
      'title': 'Investasi',
      'iconPath':
          'assets/icons/ic_investment_card.png', // Pastikan ikon ini ada
      'progress': null, 'currentAmount': 0.0, 'target': 100000000.0,
      'color': AppColors.savingsCardBg2,
    },
    {
      'title': 'Beli Mobil',
      'iconPath': 'assets/icons/ic_car_card.png', // Pastikan ikon ini ada
      'progress': 0.5, 'currentAmount': 5000000.0, 'target': 10000000.0,
      'color': AppColors.savingsCardBg1,
    },
  ];

  List<Map<String, dynamic>> transactionData = [
    {
      'category': 'Gym & Kesehatan',
      'icon': 'assets/icons/ic_gym.png', // Pastikan ikon ini ada
      'date': 'Senin, 26 Mei',
      'amount': -165000.0,
      'color': Colors.purple.shade100,
    },
    {
      'category': 'Belanja',
      'icon': 'assets/icons/ic_shopping.png', // Pastikan ikon ini ada
      'date': 'Selasa, 27 Mei',
      'amount': -55000.0,
      'color': Colors.teal.shade100,
    },
    {
      'category': 'Beli Seblak',
      'icon': 'assets/icons/ic_food.png', // Pastikan ikon ini ada
      'date': 'Selasa, 27 Mei',
      'amount': -25000.0,
      'color': Colors.orange.shade100,
    },
    {
      'category': 'Affiliate',
      'icon': 'assets/icons/ic_income.png', // Pastikan ikon ini ada
      'date': 'Selasa, 27 Mei',
      'amount': 100000000.0,
      'color': Colors.green.shade100,
    },
  ];

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- DEBUGGING PRINTS ---
    print('[HomeScreen Build] Starting build...');
    print('[HomeScreen Build] savingsData count: ${savingsData.length}');
    print(
      '[HomeScreen Build] transactionData count: ${transactionData.length}',
    );
    // --- END DEBUGGING PRINTS ---

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
            // --- Panggil Helper Functions ---
            title: _buildHeader(context, userName, userImageUrl),
            actions: [
              IconButton(
                icon: Image.asset(
                  'assets/icons/ic_bell.png', // Pastikan ikon ini ada
                  height: 24,
                  color: AppColors.iconGrey,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(
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
                // --- Panggil Helper Functions ---
                _buildBalanceSection(context, currentBalance),
                const SizedBox(height: 25),
                _buildSavingsSection(context, savingsData),
                const SizedBox(height: 25),
                _buildRecentTransactions(context, transactionData),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const TransactionHistoryScreen(),
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

  // --- Implementasi Lengkap Helper Widgets ---

  Widget _buildHeader(BuildContext context, String name, String imageUrl) {
    print('[HomeScreen Build] Building Header...'); // DEBUG
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 5),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey.shade300,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage(imageUrl),
              onBackgroundImageError: (exception, stackTrace) {
                print('Error loading profile image: $exception');
              },
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Selamat Pagi,',
                style: TextStyle(fontSize: 13, color: AppColors.greyText),
              ),
              Text(
                name,
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
  }

  Widget _buildBalanceSection(BuildContext context, double balance) {
    print('[HomeScreen Build] Building Balance Section...'); // DEBUG
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
            child: const Icon(Icons.add, color: AppColors.white, size: 30),
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsSection(
    BuildContext context,
    List<Map<String, dynamic>> data,
  ) {
    print(
      '[HomeScreen Build] Building Savings Section (Data count: ${data.length})...',
    ); // DEBUG
    if (data.isEmpty) {
      print(
        '[HomeScreen Build] Savings data is empty, returning SizedBox.shrink()',
      ); // DEBUG
      return const SizedBox.shrink();
    }
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
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateSavingsScreen(),
                  ),
                );
              },
              child: const Text(
                'Buat baru +',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        SizedBox(
          height:
              125, // Sesuaikan tinggi jika perlu untuk mengakomodasi isi card
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              print(
                '[HomeScreen Build] Building SavingsCard index $index: ${item['title']}',
              ); // DEBUG
              return Padding(
                padding: EdgeInsets.only(
                  right: index == data.length - 1 ? 0 : 10,
                ),
                child: SavingsCard(
                  // Pastikan SavingsCard menerima semua parameter ini
                  title: item['title'] ?? 'Tanpa Judul',
                  iconPath:
                      item['iconPath'] ??
                      'assets/icons/ic_default_saving.png', // Pastikan ada default icon
                  progress: item['progress'],
                  currentAmount: item['currentAmount']?.toDouble() ?? 0.0,
                  targetAmount: item['target']?.toDouble() ?? 0.0,
                  color: item['color'] ?? AppColors.savingsCardBg1,
                  onTap: () {
                    print("Savings card ${item['title']} tapped");
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    List<Map<String, dynamic>> data,
  ) {
    print(
      '[HomeScreen Build] Building Recent Transactions (Data count: ${data.length})...',
    ); // DEBUG
    if (data.isEmpty) {
      print(
        '[HomeScreen Build] Transaction data is empty, returning Center text',
      ); // DEBUG
      return const Center(
        child: Text(
          "Belum ada transaksi",
          style: TextStyle(color: AppColors.greyText),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riwayat Transaksi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.length > 4 ? 4 : data.length, // Batasi jumlah item
          itemBuilder: (context, index) {
            final item = data[index];
            print(
              '[HomeScreen Build] Building TransactionListItem index $index: ${item['category']}',
            ); // DEBUG
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: TransactionListItem(
                // Pastikan TransactionListItem menerima semua parameter ini
                category: item['category'] ?? 'Lainnya',
                date: item['date'] ?? '',
                amount: item['amount']?.toDouble() ?? 0.0,
                iconPath:
                    item['icon'] ??
                    'assets/icons/ic_default_transaction.png', // Pastikan ada default icon
                iconBackgroundColor: item['color'] ?? Colors.grey.shade200,
                onTap: () {
                  print("Transaction ${item['category']} tapped");
                },
              ),
            );
          },
        ),
      ],
    );
  }
} // Akhir Class HomeScreen
