// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:j_cash/constants/app_colors.dart'; // Sesuaikan package name
import 'package:j_cash/widgets/savings_card.dart'; // Import widget card
import 'package:j_cash/widgets/transaction_list_item.dart'; // Import widget item
import 'package:j_cash/screens/transactions/add_transaction_screen.dart';
import 'package:j_cash/screens/savings/create_savings_screen.dart';
import 'package:j_cash/screens/transactions/transaction_history_screen.dart';
// import 'package:j_cash/screens/profile/profile_screen.dart'; // Untuk navigasi ke profile
// import 'package:j_cash/screens/notifications/notification_screen.dart'; // Untuk navigasi notifikasi

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // --- Placeholder Data ---
  // Nanti data ini akan diambil dari Firebase/Provider
  final String userName = "Kim Ji Won"; // Contoh nama
  final String userImageUrl =
      'assets/images/profile_pic_placeholder.png'; // Contoh path gambar profil
  final String currentBalance = "999.999"; // Contoh saldo
  final List<Map<String, dynamic>> savingsData = [
    // Contoh data tabungan
    {
      'title': 'Beli Rumah',
      'progress': 0.1,
      'target': 100000000,
      'color': AppColors.savingsCardBg1,
    },
    {
      'title': 'Investasi',
      'progress': null,
      'target': 100000000,
      'color': AppColors.savingsCardBg2,
    },
    {
      'title': 'Beli Mobil',
      'progress': 0.5,
      'target': 10000000,
      'color': AppColors.savingsCardBg1,
    },
    // Tambah data dummy lain jika perlu
  ];
  final List<Map<String, dynamic>> transactionData = [
    // Contoh data transaksi
    {
      'category': 'Gym & Kesehatan',
      'icon': 'assets/icons/icon_heart.png',
      'date': 'Senin, 26 Mei',
      'amount': -165000,
      'color': Colors.purple.shade100,
    },
    {
      'category': 'Belanja',
      'icon': 'assets/icons/icon_cart.png',
      'date': 'Selasa, 27 Mei',
      'amount': -55000,
      'color': Colors.teal.shade100,
    },
    {
      'category': 'Beli Seblak',
      'icon': 'assets/icons/icon_food.png',
      'date': 'Selasa, 27 Mei',
      'amount': -25000,
      'color': Colors.orange.shade100,
    },
    {
      'category': 'Affiliate',
      'icon': 'assets/icons/icon_income.png',
      'date': 'Selasa, 27 Mei',
      'amount': 100000000,
      'color': Colors.green.shade100,
    },
  ];
  // -----------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white, // Background putih untuk home
      // Gunakan CustomScrollView untuk menggabungkan AppBar fleksibel dan konten scrollable
      body: CustomScrollView(
        slivers: [
          // --- AppBar Fleksibel ---
          SliverAppBar(
            backgroundColor: AppColors.white,
            pinned: true, // Tetap terlihat saat scroll
            floating: true, // Muncul langsung saat scroll ke atas
            elevation: 0, // Tanpa shadow
            automaticallyImplyLeading: false, // Sembunyikan tombol back default
            titleSpacing: 0, // Hapus padding default title
            title: _buildHeader(context, userName, userImageUrl),
            actions: [
              // Ikon Notifikasi
              IconButton(
                icon: Image.asset(
                  'assets/icons/icon_bell.png',
                  height: 24,
                  color: AppColors.iconGrey,
                ), // Ganti dg ikonmu
                onPressed: () {
                  print("Notification icon pressed");
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationScreen()));
                },
              ),
              const SizedBox(width: 10), // Sedikit jarak
            ],
          ),

          // --- Konten Utama (dalam SliverList agar bisa scroll) ---
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 15.0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // --- Bagian Saldo ---
                _buildBalanceSection(context, currentBalance),
                const SizedBox(height: 25),

                // --- Bagian Rencana Tabungan ---
                _buildSavingsSection(context, savingsData),
                const SizedBox(height: 25),

                // --- Bagian Riwayat Transaksi ---
                _buildRecentTransactions(context, transactionData),
                const SizedBox(height: 20),

                // --- Tombol Lihat Semua Transaksi ---
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
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Builder Helper ---

  Widget _buildHeader(BuildContext context, String name, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 5), // Padding kiri & atas
      child: Row(
        children: [
          // Foto Profil
          GestureDetector(
            onTap: () {
              print("Profile pic tapped");
              // TODO: Navigasi ke Profile Screen dari MainNavigator
              // Mungkin perlu cara untuk switch tab di MainNavigator dari sini
              // Atau buka halaman profile terpisah jika desainnya begitu
              // DefaultTabController.of(context)?.animateTo(3); // Contoh jika pakai TabController
            },
            child: CircleAvatar(
              radius: 22,
              // Ganti dengan NetworkImage jika URL dari internet
              backgroundImage: AssetImage(imageUrl),
              onBackgroundImageError:
                  (exception, stackTrace) =>
                      print('Error loading profile image: $exception'),
              child:
                  imageUrl.isEmpty
                      ? const Icon(Icons.person, size: 22)
                      : null, // Fallback
            ),
          ),
          const SizedBox(width: 12),
          // Teks Salam & Nama
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Selamat Pagi,', // Nanti bisa dinamis (Pagi/Siang/Malam)
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

  Widget _buildBalanceSection(BuildContext context, String balance) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center, // Sejajarkan vertikal
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
              'Rp $balance',
              style: const TextStyle(
                fontSize: 32, // Ukuran besar
                fontWeight: FontWeight.bold,
                color: AppColors.fontGreen, // Warna hijau
              ),
            ),
          ],
        ),
        // Tombol Tambah (+)
        InkWell(
          // Gunakan InkWell agar ada efek ripple
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTransactionScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(25), // Bentuk ripple bulat
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen, // Background tombol +
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
        // List Card Horizontal
        SizedBox(
          height: 120, // Tentukan tinggi container list horizontal
          child: ListView.builder(
            scrollDirection: Axis.horizontal, // Scroll ke samping
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              // Panggil widget SavingsCard (isi implementasinya nanti)
              return Padding(
                padding: EdgeInsets.only(
                  right: index == data.length - 1 ? 0 : 10,
                ), // Beri jarak antar card
                child: SavingsCard(
                  title: item['title'],
                  progress: item['progress'],
                  targetAmount: item['target'],
                  color:
                      item['color'] ??
                      AppColors.savingsCardBg1, // Warna background card
                  onTap: () {
                    print("Savings card ${item['title']} tapped");
                    // TODO: Navigasi ke detail tabungan
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
        // List Transaksi Vertikal (ambil beberapa saja)
        ListView.builder(
          shrinkWrap: true, // Agar ListView tidak ambil semua tinggi
          physics:
              const NeverScrollableScrollPhysics(), // Matikan scroll internal ListView
          itemCount: data.length > 4 ? 4 : data.length, // Tampilkan maks 4 item
          itemBuilder: (context, index) {
            final item = data[index];
            // Panggil widget TransactionListItem (isi implementasinya nanti)
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: TransactionListItem(
                category: item['category'],
                date: item['date'],
                amount: item['amount'],
                iconPath: item['icon'],
                iconBackgroundColor: item['color'] ?? Colors.grey.shade200,
                onTap: () {
                  print("Transaction ${item['category']} tapped");
                  // TODO: Navigasi ke detail transaksi
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
