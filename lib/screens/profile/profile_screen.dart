// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:j_cash/constants/app_colors.dart'; // Sesuaikan package name
// Import halaman login/auth decision untuk logout
import 'package:j_cash/screens/auth/auth_decision_screen.dart';
// Import halaman edit profil (buat placeholder jika perlu)
// import 'package:j_cash/screens/profile/edit_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:j_cash/providers/theme_provider.dart';
import 'package:j_cash/providers/auth_provider.dart' as app_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userName;
  String? userEmail;
  String? userImageUrl;
  String? userId;
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User belum login';
      userId = user.uid;
      userEmail = user.email;
      userName = user.displayName;
      userImageUrl = user.photoURL;
      // Cek Firestore untuk data tambahan (nama, photoURL custom)
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 10));
      if (doc.exists) {
        final data = doc.data()!;
        userName = data['name'] ?? userName;
        userImageUrl = data['photoURL'] ?? userImageUrl;
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMsg = 'Gagal memuat data profil: $e';
      });
    }
  }

  void _openEditProfile() async {
    final updated = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditProfileModal(
        initialName: userName ?? '',
        initialPhotoUrl: userImageUrl,
      ),
    );
    if (updated == true) {
      _loadUserData();
    }
  }

  void _logout(BuildContext context) async {
    await Provider.of<app_auth.AuthProvider>(context, listen: false).signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthDecisionScreen(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (errorMsg != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profil'),
          backgroundColor: AppColors.white,
          elevation: 0.5,
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(errorMsg!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserData,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }
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
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.grey[100],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 18),
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage:
                      (userImageUrl != null && userImageUrl!.isNotEmpty)
                          ? (userImageUrl!.startsWith('/')
                              ? FileImage(File(userImageUrl!))
                              : (userImageUrl!.startsWith('http')
                                  ? NetworkImage(userImageUrl!)
                                  : AssetImage(userImageUrl!) as ImageProvider))
                          : const AssetImage('assets/icons/ic_profile.png'),
                  child: userImageUrl == null || userImageUrl!.isEmpty
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 15),
                Text(
                  userName ?? '-',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  userEmail ?? '-',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: _openEditProfile,
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
          const SizedBox(height: 18),
          // --- Card Theme (sendiri) ---
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Theme',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.light,
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.system,
                        label: Text('System'),
                        icon: Icon(Icons.brightness_auto),
                      ),
                    ],
                    selected: {themeProvider.themeMode},
                    onSelectionChanged: (Set<ThemeMode> modes) {
                      print('Selected theme mode: \\${modes.first}');
                      themeProvider.setThemeMode(modes.first);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color?>((
                        Set<MaterialState> states,
                      ) {
                        if (states.contains(MaterialState.selected)) {
                          return Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1);
                        }
                        return null;
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
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
            separatorBuilder: (context, index) => Divider(
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

// Ganti EditProfileModal menjadi form edit profil yang sesungguhnya
enum _EditProfileState { idle, loading, success, error }

class EditProfileModal extends StatefulWidget {
  final String initialName;
  final String? initialPhotoUrl;
  const EditProfileModal(
      {super.key, required this.initialName, this.initialPhotoUrl});
  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  File? _pickedImage;
  String? _photoUrl;
  _EditProfileState _state = _EditProfileState.idle;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _photoUrl = widget.initialPhotoUrl;
  }

  Future<void> _pickImage() async {
    // Pakai image_picker, pastikan sudah di pubspec.yaml
    // import 'package:image_picker/image_picker.dart';
    final picker = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picker != null) {
      setState(() {
        _pickedImage = File(picker.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _state = _EditProfileState.loading;
      _errorMsg = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User tidak ditemukan';
      String? photoUrl = _photoUrl;
      // Simpan path lokal jika ada gambar dipilih
      if (_pickedImage != null) {
        photoUrl = _pickedImage!.path; // Simpan path lokal
      }
      // Update Auth (nama saja)
      await user.updateDisplayName(_nameController.text.trim());
      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': _nameController.text.trim(),
        if (photoUrl != null) 'photoURL': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        _state = _EditProfileState.success;
      });
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _state = _EditProfileState.error;
        _errorMsg = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit Profil',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: _pickedImage != null
                      ? FileImage(_pickedImage!)
                      : (_photoUrl != null && _photoUrl!.isNotEmpty)
                          ? (_photoUrl!.startsWith('/')
                              ? FileImage(File(_photoUrl!))
                              : (_photoUrl!.startsWith('http')
                                  ? NetworkImage(_photoUrl!)
                                  : AssetImage(_photoUrl!) as ImageProvider))
                          : const AssetImage('assets/icons/ic_profile.png'),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 2)
                        ],
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.camera_alt,
                          size: 20, color: Colors.black54),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Nama tidak boleh kosong'
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              if (_state == _EditProfileState.error && _errorMsg != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_errorMsg!, style: TextStyle(color: Colors.red)),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _state == _EditProfileState.loading ? null : _saveProfile,
                  child: _state == _EditProfileState.loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Simpan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
