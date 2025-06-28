import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:newswatch/providers/auth_provider.dart';
import 'package:newswatch/utils/app_routes.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Simpan referensi ScaffoldMessenger sebelum async call
    final messenger = ScaffoldMessenger.of(context); 
    final navigator = Navigator.of(context);

    try {
      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // TAMBAHKAN BLOK INI UNTUK NOTIFIKASI SUKSES
      messenger.showSnackBar(
        SnackBar(
          content: Text('Login berhasil! Selamat datang kembali, ${authProvider.user?.name}.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      // ===============================================

      // Navigasi setelah jeda singkat agar user bisa melihat notifikasi
      await Future.delayed(const Duration(seconds: 1));
      navigator.pushReplacementNamed(AppRoutes.home);

    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            // Kode notifikasi error Anda sudah bagus, tidak perlu diubah
            content: Text(error.toString().replaceFirst("Exception: ", "")),
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/images/login.png', // Ganti path ini sesuai lokasi gambar kamu
                  height: 170,
                ),

                Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to your account',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(LucideIcons.mail),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator:
                      (value) =>
                          (value == null || !value.contains('@'))
                              ? 'Please enter a valid email'
                              : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(LucideIcons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                      ),
                      onPressed:
                          () => setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                  validator:
                      (value) =>
                          (value == null || value.isEmpty)
                              ? 'Please enter your password'
                              : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : _handleLogin, // Nonaktifkan tombol saat loading
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                          : const Text('Sign In'),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed:
                          () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.register),
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
