import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:newswatch/providers/auth_provider.dart';
import 'package:newswatch/services/api_service.dart';
import 'package:newswatch/utils/app_routes.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;

  final ApiService _apiService = ApiService();

   Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final apiService = ApiService();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Simpan referensi ScaffoldMessenger sebelum async call
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await apiService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
      );

      if (mounted) {
        await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }

      // TAMBAHKAN BLOK INI UNTUK NOTIFIKASI SUKSES
      messenger.showSnackBar(
        SnackBar(
          content: Text('Registrasi berhasil! Selamat bergabung di NewsWatch, ${authProvider.user?.name}.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      // ===============================================

      if (mounted) {
        // Navigasi setelah jeda singkat
        await Future.delayed(const Duration(seconds: 1));
        navigator.pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
      }
    } catch (error) {
      if (mounted) {
        // Kode notifikasi error Anda sudah bagus
        messenger.showSnackBar(
          SnackBar(
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join NewsWatch today!',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(LucideIcons.user),
                  ),
                  validator:
                      (value) =>
                          (value == null || value.isEmpty)
                              ? 'Please enter your name'
                              : null,
                ),
                const SizedBox(height: 16),
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
                          (value == null || value.length < 6)
                              ? 'Password must be at least 6 characters'
                              : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
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
                          : const Text('Create Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
