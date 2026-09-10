import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color navyBlue = Color(0xFF1B2A4A);
  static const Color primaryBlue = Color(0xFF2E5BFF);
  static const Color lightBlue = Color(0xFFE8EDFF);
  static const Color white = Colors.white;
  static const Color lightGray = Color(0xFFF5F7FA);
  static const Color mediumGray = Color(0xFFB0B8C9);
  static const Color darkText = Color(0xFF1A1D26);

  static const Color success = Color(0xFF27AE60);
  static const Color successBg = Color(0xFFE8F8EF);
  static const Color error = Color(0xFFE74C3C);
  static const Color errorBg = Color(0xFFFDEAEA);
  static const Color warning = Color(0xFFF39C12);
  static const Color warningBg = Color(0xFFFFF8E1);

  static const Color present = Color(0xFF27AE60);
  static const Color late = Color(0xFFF39C12);
  static const Color absent = Color(0xFFE74C3C);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [navyBlue, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
