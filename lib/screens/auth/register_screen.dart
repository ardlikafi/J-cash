// lib/screens/auth/register_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:j_cash/constants/app_colors.dart'; // Sesuaikan nama package
import 'package:j_cash/screens/auth/login_screen.dart';
// Import halaman home setelah register berhasil
import 'package:j_cash/screens/main_navigator.dart'; // Asumsi MainNavigator sbg halaman utama
import 'package:provider/provider.dart';
import 'package:j_cash/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerWithEmailPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.registerWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigator()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal daftar: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _loginWithGoogle() {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    Provider.of<AuthProvider>(context, listen: false)
        .signInWithGoogle()
        .then((_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigator()),
        );
      }
    }).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal login dengan Google: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }).whenComplete(() {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
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
                        'assets/images/img_logo.png',
                        height: 80,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
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
                        textCapitalization: TextCapitalization
                            .words, // Otomatis kapital di awal kata
                        style: const TextStyle(color: AppColors.black),
                        decoration: InputDecoration(
                          hintText: 'Nama lengkap',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child:
                                Icon(Icons.person, color: AppColors.iconGrey),
                          ),
                          fillColor: AppColors.white.withOpacity(0.95),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // --- Email Text Field ---
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AppColors.black),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Icon(Icons.email, color: AppColors.iconGrey),
                          ),
                          fillColor: AppColors.white.withOpacity(0.95),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Masukkan format email yang valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // --- Password Text Field ---
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        style: const TextStyle(color: AppColors.black),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Icon(Icons.lock, color: AppColors.iconGrey),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
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
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          if (value.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      // Tidak ada lupa password di register
                      const SizedBox(height: 30),

                      // --- Tombol Daftar ---
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
                        onPressed:
                            _isLoading ? null : _registerWithEmailPassword,
                        child: Text(
                          _isLoading ? 'Memproses...' : 'Daftar',
                          style: const TextStyle(
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
                        onPressed: _isLoading ? () {} : _loginWithGoogle,
                        iconPath: 'assets/icons/ic_google.png',
                        text: 'Daftar dengan Google',
                        context: context,
                      ),
                      const SizedBox(height: 15),
                      _buildSocialLoginButton(
                        onPressed: _loginWithFacebook,
                        iconPath: 'assets/icons/ic_facebook.png',
                        text:
                            'Masuk dengan Facebook', // Teks tetap 'Masuk dengan'
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
                          text: 'Sudah punya akun? ',
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
                              recognizer: TapGestureRecognizer()
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
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
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
          errorBuilder: (context, error, stackTrace) => const Icon(
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
