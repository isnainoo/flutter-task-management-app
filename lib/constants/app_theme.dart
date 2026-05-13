import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF7C5CFC);
  static const Color primaryDark = Color(0xFF5A3DDB);
  static const Color background = Color(0xFFF0F2F8);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF1A1035);
  static const Color textSecondary = Color(0xFF888888);
  static const Color inputBorder = Color(0xFFE8E4F8);
  static const Color inputBackground = Color(0xFFFAFAFE);

  static const Color tagRed = Color(0xFFD04030);
  static const Color tagRedBg = Color(0xFFFFE8E4);
  static const Color tagAmber = Color(0xFFC07820);
  static const Color tagAmberBg = Color(0xFFFFF3E0);
  static const Color tagGreen = Color(0xFF2A8C5E);
  static const Color tagGreenBg = Color(0xFFE6F9F0);
  static const Color tagGray = Color(0xFF666666);
  static const Color tagGrayBg = Color(0xFFF0F0F0);

  static const Color deadlineBg = Color(0xFFFFF5F0);
  static const Color deadlineAccent = Color(0xFFF07050);
  static const Color deadlineText = Color(0xFFD45030);
}

class AppTextStyles {
  static const TextStyle screenTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle screenSub = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  static const TextStyle fieldLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF444444),
  );

  static const TextStyle inputText = TextStyle(
    fontSize: 13,
    color: AppColors.textPrimary,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle linkText = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle linkHighlight = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static const TextStyle taskName = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle taskNameDone = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    decoration: TextDecoration.lineThrough,
  );

  static const TextStyle taskDate = TextStyle(
    fontSize: 11,
    color: AppColors.textSecondary,
  );
}
