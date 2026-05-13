import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../widgets/app_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  void _resetPassword() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan email Anda terlebih dahulu.')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Link reset password telah dikirim ke $email')));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: const Color(0xFF7C5CFC).withOpacity(0.07), blurRadius: 24, offset: const Offset(0, 4))],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AvatarCircle(icon: Icons.lock_reset),
                const SizedBox(height: 16),
                const Text('Lupa Password?', style: AppTextStyles.screenTitle),
                const SizedBox(height: 8),
                const Text(
                  'Masukkan email yang terdaftar. Kami akan mengirimkan link untuk mereset password Anda.',
                  style: AppTextStyles.screenSub,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Align(alignment: Alignment.centerLeft, child: Text('Email', style: AppTextStyles.fieldLabel)),
                const SizedBox(height: 6),
                AppTextField(
                  placeholder: 'nama@email.com',
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                PrimaryButton(label: 'Kirim Link Reset', onPressed: _resetPassword),
              ],
            ),
          ),
        ),
      ),
    );
  }
}