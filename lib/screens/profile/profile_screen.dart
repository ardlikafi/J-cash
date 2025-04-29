// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:j_cash/constants/app_colors.dart'; // Sesuaikan package name
// Import halaman login/auth decision untuk logout
import 'package:j_cash/screens/auth/auth_decision_screen.dart';
// Import halaman edit profil (buat placeholder jika perlu)
// import 'package:j_cash/screens/profile/edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // --- Placeholder Data User ---
  // Nanti diambil dari state/provider/Firebase Auth
  final String userName = "Kim Ji Won"; // Ganti dengan namamu :)
  final String userEmail = "kim.ji.won@example.com"; // Ganti dengan emailmu
  final String userImageUrl =
      'assets/icons/ic_profile.png'; // Gunakan path gambar profilmu

  // --- Helper Fungsi untuk Logout ---
  void _logout(BuildContext context) {
    // TODO: Implementasi logic logout Firebase Auth di sini
    // FirebaseAuth.instance.signOut();

    // Navigasi kembali ke halaman awal (setelah logout)
    // Hapus semua halaman sebelumnya agar tidak bisa kembali ke home setelah logout
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthDecisionScreen(),
      ), // atau LoginScreen
      (Route<dynamic> route) => false, // Hapus semua route
    );
    print("Logout tapped");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(
            color: AppColors.fontGreen,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0.5,
        centerTitle: true,
        automaticallyImplyLeading:
            false, // Tidak perlu tombol back di halaman tab
      ),
      backgroundColor:
          Colors.grey[100], // Background abu-abu muda untuk profile
      body: ListView(
        // Gunakan ListView agar bisa scroll jika menu banyak
        children: [
          // --- Bagian Info User ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            color: AppColors.white, // Background putih untuk header info
            child: Column(
              children: [
                // Foto Profil Besar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.transparent,
                    backgroundImage: AssetImage(
                      userImageUrl,
                    ), // Pastikan path gambar benar
                    onBackgroundImageError:
                        (e, s) => print('Error loading profile image: $e'),
                  ),
                ),
                const SizedBox(height: 15),
                // Nama User
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 5),
                // Email User
                Text(
                  userEmail,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                // Tombol Edit Profil
                OutlinedButton.icon(
                  onPressed: () {
                    print("Edit Profile tapped");
                    // TODO: Navigasi ke EditProfileScreen
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen()));
                  },
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppColors.primaryGreen,
                  ),
                  label: const Text(
                    'Edit Profil',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.primaryGreen,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15), // Spasi antar section
          // --- Grup Menu Akun ---
          _buildMenuGroup(
            context: context,
            title: 'Akun',
            items: [
              _buildProfileMenuItem(
                icon: Icons.person_outline,
                text: 'Informasi Akun',
                onTap: () {
                  print("Informasi Akun tapped"); /* TODO */
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.lock_outline,
                text: 'Keamanan',
                onTap: () {
                  print("Keamanan tapped"); /* TODO */
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.notifications_none_outlined,
                text: 'Notifikasi',
                onTap: () {
                  print("Notifikasi tapped"); /* TODO */
                },
              ),
            ],
          ),
          const SizedBox(height: 15),

          // --- Grup Menu Bantuan & Lainnya ---
          _buildMenuGroup(
            context: context,
            title: 'Lainnya',
            items: [
              _buildProfileMenuItem(
                icon: Icons.help_outline,
                text: 'Pusat Bantuan',
                onTap: () {
                  print("Bantuan tapped"); /* TODO */
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.info_outline,
                text: 'Tentang Aplikasi',
                onTap: () {
                  print("Tentang tapped"); /* TODO */
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.star_border_outlined,
                text: 'Beri Rating',
                onTap: () {
                  print("Rating tapped"); /* TODO */
                },
              ),
            ],
          ),
          const SizedBox(height: 25),

          // --- Tombol Logout ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ElevatedButton.icon(
              onPressed: () => _logout(context), // Panggil fungsi logout
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text(
                'Keluar',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error.withOpacity(
                  0.1,
                ), // Background merah transparan
                foregroundColor: AppColors.error, // Warna ripple merah
                elevation: 0, // Tanpa shadow
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30), // Padding bawah
        ],
      ),
    );
  }

  // --- Helper Widget untuk Grup Menu ---
  Widget _buildMenuGroup({
    required BuildContext context,
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15.0),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0, top: 5, bottom: 5),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Gunakan ListView.separated untuk memberi garis pemisah
          ListView.separated(
            shrinkWrap: true, // Penting di dalam ListView utama
            physics:
                const NeverScrollableScrollPhysics(), // Tidak perlu scroll internal
            itemCount: items.length,
            itemBuilder: (context, index) => items[index],
            separatorBuilder:
                (context, index) => Divider(
                  height: 1, // Tinggi garis
                  thickness: 0.5, // Ketebalan garis
                  color: Colors.grey.shade200, // Warna garis
                  indent: 15, // Jarak dari kiri
                  endIndent: 15, // Jarak dari kanan
                ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widget untuk Item Menu ---
  Widget _buildProfileMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color iconColor = Colors.black54,
    Color textColor = Colors.black87,
  }) {
    return Material(
      // Bungkus dengan Material agar InkWell bekerja di atas Container
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 14.0),
          child: Row(
            children: [
              Icon(icon, size: 22, color: iconColor),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(fontSize: 15, color: textColor),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
