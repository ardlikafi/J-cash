// lib/screens/auth/register_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:j_cash/constants/app_colors.dart'; // Sesuaikan nama package
import 'package:j_cash/screens/auth/login_screen.dart';
// Import halaman home setelah register berhasil
import 'package:j_cash/screens/main_navigator.dart'; // Asumsi MainNavigator sbg halaman utama

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Fungsi Placeholder untuk Aksi Register ---
  void _registerWithEmailPassword() {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;
      print(
        'Attempting registration with Name: $name, Email: $email, Password: $password',
      );

      // TODO: Implementasi logic register Firebase Auth di sini
      // 1. Buat user baru (createUserWithEmailAndPassword)
      // 2. Simpan data tambahan (nama) ke Firestore (jika perlu)
      // 3. Update profile user (updateDisplayName)

      // Jika berhasil:
      Navigator.pushAndRemoveUntil(
        // Hapus stack navigasi auth
        context,
        MaterialPageRoute(builder: (context) => const MainNavigator()),
        (Route<dynamic> route) => false, // Hapus semua rute sebelumnya
      );
      // Jika gagal, tampilkan pesan error
    }
  }

  void _loginWithGoogle() {
    print('Attempting registration/login with Google');
    // TODO: Implementasi logic Google Sign In + Cek user exist/create di Firebase
  }

  void _loginWithFacebook() {
    print('Attempting registration/login with Facebook');
    // TODO: Implementasi logic Facebook Auth + Cek user exist/create di Firebase
  }

  void _loginWithApple() {
    print('Attempting registration/login with Apple');
    // TODO: Implementasi logic Apple Sign In + Cek user exist/create di Firebase
  }

  void _navigateToLogin() {
    // Cek apakah bisa pop, jika iya pop (kembali ke decision/login), jika tidak push
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      // Fallback jika tidak bisa pop (misal user langsung buka register)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }
  // --- Akhir Fungsi Placeholder ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Logo J-Cash
                  Image.asset(
                    'assets/images/logo_jcash_white.png',
                    height: 80,
                    errorBuilder:
                        (context, error, stackTrace) => const Icon(
                          Icons.error,
                          color: AppColors.white,
                          size: 50,
                        ),
                  ),
                  const SizedBox(height: 30),

                  // Judul "Daftar"
                  const Text(
                    'Daftar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- Name Text Field ---
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    textCapitalization:
                        TextCapitalization
                            .words, // Otomatis kapital di awal kata
                    style: const TextStyle(color: AppColors.black),
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama kamu',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset(
                          'assets/icons/ic_username.png', // Ganti jika nama ikon beda
                          height: 20,
                          color: AppColors.iconGrey,
                        ),
                      ),
                      fillColor: AppColors.white.withOpacity(0.95),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null; // Valid
                    },
                  ),
                  const SizedBox(height: 15),

                  // --- Email Text Field ---
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppColors.black),
                    decoration: InputDecoration(
                      hintText: 'Masukkan email kamu',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset(
                          'assets/icons/ic_email.png',
                          height: 20,
                          color: AppColors.iconGrey,
                        ),
                      ),
                      fillColor: AppColors.white.withOpacity(0.95),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Masukkan format email yang valid';
                      }
                      return null; // Valid
                    },
                  ),
                  const SizedBox(height: 15),

                  // --- Password Text Field ---
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    style: const TextStyle(color: AppColors.black),
                    decoration: InputDecoration(
                      hintText: 'Buat Password', // Teks hint beda
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset(
                          'assets/icons/ic_password.png',
                          height: 20,
                          color: AppColors.iconGrey,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.iconGrey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      fillColor: AppColors.white.withOpacity(0.95),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null; // Valid
                    },
                  ),
                  // Tidak ada lupa password di register
                  const SizedBox(height: 30),

                  // --- Tombol Daftar ---
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.buttonDaftar, // Warna tombol daftar
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed:
                        _registerWithEmailPassword, // Panggil fungsi register
                    child: const Text(
                      'Daftar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- Pemisah "atau lanjut menggunakan" ---
                  _buildDivider(),
                  const SizedBox(height: 20),

                  // --- Tombol Social Login ---
                  _buildSocialLoginButton(
                    onPressed: _loginWithFacebook,
                    iconPath: 'assets/icons/ic_facebook.png',
                    text: 'Masuk dengan Facebook', // Teks tetap 'Masuk dengan'
                    context: context,
                  ),
                  const SizedBox(height: 15),
                  _buildSocialLoginButton(
                    onPressed: _loginWithGoogle,
                    iconPath: 'assets/icons/ic_google.png',
                    text: 'Masuk dengan Google', // Teks tetap 'Masuk dengan'
                    context: context,
                  ),
                  const SizedBox(height: 15),
                  _buildSocialLoginButton(
                    onPressed: _loginWithApple,
                    iconPath: 'assets/icons/ic_apple.png',
                    text: 'Masuk dengan Apple', // Teks tetap 'Masuk dengan'
                    context: context,
                    iconColor: AppColors.black,
                  ),
                  const SizedBox(height: 40),

                  // --- Link ke Halaman Login ---
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Sudah memiliki akun? ',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: 'Masuk', // Teks beda
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.white,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = _navigateToLogin, // Navigasi ke Login
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widget untuk Pemisah (Copy dari LoginScreen) ---
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(color: AppColors.white.withOpacity(0.5), thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            'atau lanjut menggunakan',
            style: TextStyle(
              color: AppColors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: AppColors.white.withOpacity(0.5), thickness: 1),
        ),
      ],
    );
  }

  // --- Helper Widget untuk Tombol Social Login (Copy dari LoginScreen) ---
  Widget _buildSocialLoginButton({
    required VoidCallback onPressed,
    required String iconPath,
    required String text,
    required BuildContext context,
    Color? iconColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Image.asset(
          iconPath,
          height: 22,
          color: iconColor,
          errorBuilder:
              (context, error, stackTrace) => const Icon(
                Icons.error_outline,
                color: AppColors.greyText,
                size: 20,
              ),
        ),
        label: Text(
          text,
          style: const TextStyle(
            color: AppColors.socialButtonForeground,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.socialButtonBackground,
          foregroundColor: AppColors.socialButtonForeground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
