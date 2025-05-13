import 'package:flutter/material.dart';
import 'dart:math' as math; // Import math untuk clamp
import 'package:j_cash/constants/app_colors.dart'; // Sesuaikan nama package
import 'package:j_cash/models/onboarding_item.dart'; // Import model
import 'package:j_cash/screens/auth/auth_decision_screen.dart'; // Import screen selanjutnya

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onFinish;
  const OnboardingScreen({super.key, this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Daftar konten onboarding (tetap sama)
  final List<OnboardingItem> _onboardingData = [
    OnboardingItem(
      imagePath: 'assets/images/img_onboarding1.png',
      title: 'Selamat Datang di J-Cash!',
      description:
          'Lacak setiap pemasukan dan pengeluaran harianmu dengan mudah untuk finansial yang lebih teratur.',
    ),
    OnboardingItem(
      imagePath: 'assets/images/img_onboarding2.png',
      title: 'Catat Transaksi Sekejap Mata',
      description:
          'Tambahkan pemasukan atau pengeluaran baru hanya dengan beberapa tap. Cepat, praktis, dan anti ribet!',
    ),
    OnboardingItem(
      imagePath: 'assets/images/img_onboarding3.png',
      title: 'Pahami Arus Keuanganmu',
      description:
          'Lihat ringkasan pengeluaran berdasarkan kategori. Kenali kebiasaan finansialmu jadi lebih baik.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToAuth() {
    if (widget.onFinish != null) {
      widget.onFinish!();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthDecisionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Tombol Lewati (tetap sama)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0, right: 20.0),
                  child: TextButton(
                    onPressed: _navigateToAuth,
                    child: const Text(
                      'Lewati',
                      style: TextStyle(color: AppColors.white, fontSize: 14),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),

              // --- MODIFIKASI BAGIAN PageView.builder ---
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _onboardingData.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    // Tambahkan listener untuk mendapatkan posisi scroll
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double pageValue = 0.0;
                        if (_pageController.position.haveDimensions) {
                          // Dapatkan nilai halaman saat ini (bisa berupa double, misal 0.5)
                          pageValue = _pageController.page ?? 0.0;
                        }

                        // Hitung perbedaan antara nilai halaman saat ini dan index item
                        // pageOffset = 0 -> halaman ini sedang aktif/di tengah
                        // pageOffset = 1 -> halaman ini satu langkah ke kanan (sudah lewat)
                        // pageOffset = -1 -> halaman ini satu langkah ke kiri (akan muncul)
                        double pageOffset = pageValue - index;

                        // --- Terapkan Transformasi ---
                        // 1. Scale: Sedikit mengecil saat menjauh dari tengah
                        // Nilai 0.8 bisa disesuaikan (semakin kecil, semakin drastis mengecilnya)
                        // clamp memastikan scale tidak kurang dari 0.8 atau lebih dari 1.0
                        final double scale =
                            (1 - (pageOffset.abs() * 0.2)).clamp(0.8, 1.0);

                        // 2. Opacity: Memudar saat menjauh dari tengah
                        final double opacity = (1 - pageOffset.abs() * 0.5)
                            .clamp(0.0, 1.0); // Fade lebih cepat

                        // 3. (Opsional) Sedikit pergeseran Vertikal saat transisi
                        final double verticalOffset = pageOffset.abs() *
                            50; // Bergerak ke bawah saat menjauh

                        return Transform.translate(
                          offset: Offset(
                            0,
                            verticalOffset,
                          ), // Terapkan pergeseran vertikal
                          child: Transform.scale(
                            scale: scale,
                            child: Opacity(
                              opacity: opacity,
                              // Konten halaman (child dari AnimatedBuilder)
                              child: child,
                            ),
                          ),
                        );
                      },
                      // Ini adalah konten halaman yang sebenarnya,
                      // dibangun sekali dan dioper ke builder di atas
                      child: _buildPageContent(
                        _onboardingData[index],
                        screenSize,
                      ),
                    );
                  },
                ),
              ),
              // --- AKHIR MODIFIKASI PageView.builder ---

              // Indikator Halaman (Titik-titik) (tetap sama)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingData.length,
                  (index) => _buildPageIndicator(index == _currentPage),
                ),
              ),
              const SizedBox(height: 20),

              // Tombol Bawah (Kembali & Lanjut/Mulai) (tetap sama)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30.0,
                  vertical: 25.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Opacity(
                      opacity: _currentPage > 0 ? 1.0 : 0.0,
                      child: OutlinedButton(
                        onPressed: _currentPage > 0
                            ? () {
                                _pageController.previousPage(
                                  duration: const Duration(
                                    milliseconds: 400,
                                  ), // Sedikit lebih lambat
                                  curve: Curves.easeInOut, // Ganti curve
                                );
                              }
                            : null,
                        child: const Text(
                          'Kembali',
                          style: TextStyle(color: AppColors.white),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.white,
                          side: const BorderSide(
                            color: AppColors.white,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _currentPage < _onboardingData.length - 1
                          ? () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            }
                          : _navigateToAuth,
                      child: Text(
                        _currentPage < _onboardingData.length - 1
                            ? 'Lanjut'
                            : 'Mulai',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonLanjut,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildPageContent (TIDAK PERLU DIUBAH)
  Widget _buildPageContent(OnboardingItem item, Size screenSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            item.imagePath,
            height: screenSize.height * 0.35,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.image_not_supported_outlined,
              size: 100,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.white,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Widget _buildPageIndicator (TIDAK PERLU DIUBAH)
  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      height: 8.0,
      width: isActive ? 20.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? AppColors.white : AppColors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
