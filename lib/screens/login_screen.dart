import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'register_screen.dart';
import 'todo_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi email dan password terlebih dahulu.')),
      );
      return;
    }

    final username = email.contains('@') ? email.split('@')[0] : email;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TodoScreen(username: username),
      ),
    );
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
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C5CFC).withOpacity(0.07),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AvatarCircle(icon: Icons.person_outline),
                const SizedBox(height: 16),
                const Text('Selamat Datang', style: AppTextStyles.screenTitle),
                const SizedBox(height: 4),
                const Text('Masuk ke akun Anda', style: AppTextStyles.screenSub),
                const SizedBox(height: 24),

                // Email field
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Email', style: AppTextStyles.fieldLabel),
                ),
                const SizedBox(height: 6),
                AppTextField(
                  placeholder: 'nama@gmail.com',
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Password field
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Password', style: AppTextStyles.fieldLabel),
                ),
                const SizedBox(height: 6),
                AppTextField(
                  placeholder: 'Masukkan password',
                  icon: Icons.lock_outline,
                  obscure: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 8),

                // --- TOMBOL LUPA PASSWORD ---
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                    child: const Text('Lupa Password?', style: AppTextStyles.linkHighlight),
                  ),
                ),
                const SizedBox(height: 24),

                PrimaryButton(label: 'Masuk', onPressed: _login),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Belum punya akun? ', style: AppTextStyles.linkText),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      ),
                      child: const Text('Daftar sekarang', style: AppTextStyles.linkHighlight),
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
