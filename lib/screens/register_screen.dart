import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../services/api_service.dart';
import 'todo_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  void _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi.')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 6 karakter.')),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi password tidak cocok.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.register(name, email, password);

    setState(() => _isLoading = false);

    if (result['user'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', result['user']['id']);
      await prefs.setString('user_name', result['user']['name']);
      await prefs.setString('user_email', result['user']['email']);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => TodoScreen(
            username: result['user']['name'],
            userId: result['user']['id'],
            isNewUser: true,
          ),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Registrasi gagal')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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
                const AvatarCircle(icon: Icons.person_add_outlined),
                const SizedBox(height: 16),
                const Text('Buat Akun Baru', style: AppTextStyles.screenTitle),
                const SizedBox(height: 4),
                const Text(
                  'Daftar untuk mulai mengatur tugas Anda',
                  style: AppTextStyles.screenSub,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildField('Nama Lengkap', 'Nama Anda',
                    Icons.person_outline, _nameController),
                const SizedBox(height: 16),
                _buildField('Email', 'nama@gmail.com',
                    Icons.email_outlined, _emailController,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildField('Password', 'Minimal 6 karakter',
                    Icons.lock_outline, _passwordController,
                    obscure: true),
                const SizedBox(height: 16),
                _buildField('Konfirmasi Password', 'Ulangi password',
                    Icons.lock_outline, _confirmController,
                    obscure: true),
                const SizedBox(height: 24),

                // Loading indicator saat proses register
                _isLoading
                    ? const CircularProgressIndicator()
                    : PrimaryButton(label: 'Daftar', onPressed: _register),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Sudah punya akun? ',
                        style: AppTextStyles.linkText),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('Masuk di sini',
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

  Widget _buildField(
    String label,
    String placeholder,
    IconData icon,
    TextEditingController controller, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.fieldLabel),
        const SizedBox(height: 6),
        AppTextField(
          placeholder: placeholder,
          icon: icon,
          obscure: obscure,
          controller: controller,
          keyboardType: keyboardType,
        ),
      ],
    );
  }
}