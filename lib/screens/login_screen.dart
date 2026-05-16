import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../services/api_service.dart';
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
  bool _isLoading = false;

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi email dan password terlebih dahulu.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.login(email, password);

    setState(() => _isLoading = false);

    if (result['user'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', result['user']['id']);
      await prefs.setString('user_name', result['user']['name']);
      await prefs.setString('user_email', result['user']['email']);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TodoScreen(
            username: result['user']['name'],
            userId: result['user']['id'],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Login gagal')),
      );
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
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen())),
                    child: const Text('Lupa Password?',
                        style: AppTextStyles.linkHighlight),
                  ),
                ),
                const SizedBox(height: 24),

                // Loading indicator saat proses login
                _isLoading
                    ? const CircularProgressIndicator()
                    : PrimaryButton(label: 'Masuk', onPressed: _login),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Belum punya akun? ',
                        style: AppTextStyles.linkText),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      ),
                      child: const Text('Daftar sekarang',
                          style: AppTextStyles.linkHighlight),
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