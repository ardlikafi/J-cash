// lib/screens/auth/login_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:j_cash/constants/app_colors.dart'; // Sesuaikan nama package
import 'package:j_cash/screens/auth/register_screen.dart';
// Import halaman home setelah login berhasil
import 'package:j_cash/screens/main_navigator.dart'; // Asumsi MainNavigator sbg halaman utama
// Import halaman lupa password (buat placeholder jika belum ada)
// import 'package:j_cash/screens/auth/forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Kunci untuk validasi form
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // State untuk show/hide password

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Fungsi Placeholder untuk Aksi Login ---
  void _loginWithEmailPassword() {
    // Validasi form dulu
    if (_formKey.currentState!.validate()) {
      // Jika valid, tampilkan loading (nanti) & panggil service auth
      String email = _emailController.text;
      String password = _passwordController.text;
      print('Attempting login with Email: $email, Password: $password');

      // TODO: Implementasi logic login Firebase Auth di sini
      // Jika berhasil:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainNavigator(),
        ), // Arahkan ke Home/Main screen
      );
      // Jika gagal, tampilkan pesan error (Snackbar/Dialog)
    }
  }

  void _loginWithGoogle() {
    print('Attempting login with Google');
    // TODO: Implementasi logic login Google Sign In + Firebase Auth
  }

  void _loginWithFacebook() {
    print('Attempting login with Facebook');
    // TODO: Implementasi logic login Facebook Auth + Firebase Auth
    // !! Ingat error Facebook SDK yg tadi, perlu setup native !!
  }

  void _loginWithApple() {
    print('Attempting login with Apple');
    // TODO: Implementasi logic login Apple Sign In + Firebase Auth
    // !! Hanya berfungsi di iOS/macOS & perlu Apple Developer Account !!
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  void _navigateToForgotPassword() {
    print('Navigating to Forgot Password');
    // TODO: Buat halaman ForgotPasswordScreen dan navigasi ke sana
    // Navigator.push(
    //    context,
    //    MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    // );
  }
  // --- Akhir Fungsi Placeholder ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gunakan SingleChildScrollView agar bisa discroll saat keyboard muncul
      body: SingleChildScrollView(
        child: Container(
          // Set tinggi minimal seukuran layar agar gradient penuh
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          // Background Gradient
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: SafeArea(
            child: Form(
              // Bungkus Column dengan Form
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Agar tombol full width
                children: [
                  const SizedBox(height: 40), // Spasi atas
                  // Logo J-Cash
                  Image.asset(
                    'assets/images/img_logo.png', // Ganti jika nama file beda
                    height: 80, // Sesuaikan ukuran
                    errorBuilder:
                        (context, error, stackTrace) => const Icon(
                          Icons.error,
                          color: AppColors.white,
                          size: 50,
                        ),
                  ),
                  const SizedBox(height: 30),

                  // Judul "Masuk"
                  const Text(
                    'Masuk',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- Email Text Field ---
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      color: AppColors.black,
                    ), // Warna teks input
                    decoration: InputDecoration(
                      hintText: 'Masukkan email kamu',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset(
                          'assets/icons/ic_email.png', // Ikon email
                          height: 20,
                          color: AppColors.iconGrey, // Warnai ikonnya
                        ),
                      ),
                      // Ganti warna background field agar kontras dengan background hijau
                      fillColor: AppColors.white.withOpacity(0.95),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ), // Atur padding vertikal
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
                    obscureText: !_isPasswordVisible, // Teks tersembunyi/tidak
                    style: const TextStyle(color: AppColors.black),
                    decoration: InputDecoration(
                      hintText: 'Masukkan password kamu',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset(
                          'assets/icons/ic_password.png', // Ikon gembok
                          height: 20,
                          color: AppColors.iconGrey,
                        ),
                      ),
                      // Tambahkan ikon mata untuk show/hide password
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
                        // Contoh validasi panjang minimal
                        return 'Password minimal 6 karakter';
                      }
                      return null; // Valid
                    },
                  ),
                  const SizedBox(height: 10),

                  // --- Lupa Password ---
                  Align(
                    alignment: Alignment.centerRight,
                    child: RichText(
                      text: TextSpan(
                        text: 'Lupa password? ',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 13,
                        ),
                        children: [
                          TextSpan(
                            text: 'Klik disini',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, // Buat lebih tebal
                              decoration:
                                  TextDecoration.underline, // Garis bawah
                              decorationColor:
                                  AppColors.white, // Warna garis bawah
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap =
                                      _navigateToForgotPassword, // Aksi saat diklik
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- Tombol Masuk ---
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonMasuk,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _loginWithEmailPassword, // Panggil fungsi login
                    child: const Text(
                      'Masuk',
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
                    text: 'Masuk dengan Facebook',
                    context: context,
                  ),
                  const SizedBox(height: 15),
                  _buildSocialLoginButton(
                    onPressed: _loginWithGoogle,
                    iconPath: 'assets/icons/ic_google.png',
                    text: 'Masuk dengan Google',
                    context: context,
                  ),
                  const SizedBox(height: 15),
                  _buildSocialLoginButton(
                    onPressed: _loginWithApple,
                    iconPath:
                        'assets/icons/ic_apple.png', // Gunakan ikon Apple grey
                    text: 'Masuk dengan Apple',
                    context: context,
                    iconColor:
                        AppColors
                            .black, // Set warna ikon Apple jika perlu (asumsi ikon aslinya grey)
                  ),
                  const SizedBox(height: 40),

                  // --- Link ke Halaman Daftar ---
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Belum memiliki akun? ',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: 'Daftar Sekarang',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.white,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap =
                                    _navigateToRegister, // Aksi navigasi ke Register
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40), // Spasi bawah
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widget untuk Pemisah ---
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

  // --- Helper Widget untuk Tombol Social Login ---
  Widget _buildSocialLoginButton({
    required VoidCallback onPressed,
    required String iconPath,
    required String text,
    required BuildContext context,
    Color? iconColor, // Optional color for icon
  }) {
    return SizedBox(
      width: double.infinity, // Make button full width
      height: 50, // Set a fixed height
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Image.asset(
          iconPath,
          height: 22, // Adjust icon size
          color: iconColor, // Apply color if provided
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
            color: AppColors.socialButtonForeground, // Teks putih
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              AppColors
                  .socialButtonBackground, // Warna background tombol sosial
          foregroundColor:
              AppColors
                  .socialButtonForeground, // Warna ripple effect & teks default
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // Center align content
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ), // Adjust padding if needed
        ),
      ),
    );
  }
}

// --- Placeholder untuk MainNavigator (Jika belum ada) ---
// Harusnya sudah ada file lib/screens/main_navigator.dart
// class MainNavigator extends StatelessWidget {
//   const MainNavigator({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Home')),
//       body: const Center(child: Text('Halaman Utama Aplikasi')),
//     );
//   }
// }
