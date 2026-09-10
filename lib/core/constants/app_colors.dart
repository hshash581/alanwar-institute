import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color navyBlue = Color(0xFF0D1B3E);
  static const Color darkBlue = Color(0xFF132B5C);
  static const Color primaryBlue = Color(0xFF2E5BFF);
  static const Color primary = primaryBlue;
  static const Color lightBlue = Color(0xFFE8EDFF);
  static const Color veryLightBlue = Color(0xFFF0F4FF);
  static const Color white = Colors.white;
  static const Color lightGray = Color(0xFFF5F7FA);
  static const Color veryLightGray = Color(0xFFFAFBFC);
  static const Color mediumGray = Color(0xFFB0B8C9);
  static const Color darkText = Color(0xFF1A1D26);
  static const Color subtitleText = Color(0xFF6B7280);

  static const Color success = Color(0xFF27AE60);
  static const Color successBg = Color(0xFFE8F8EF);
  static const Color error = Color(0xFFE74C3C);
  static const Color errorBg = Color(0xFFFDEAEA);
  static const Color warning = Color(0xFFF39C12);
  static const Color warningBg = Color(0xFFFFF8E1);
  static const Color info = Color(0xFF3498DB);
  static const Color infoBg = Color(0xFFEBF5FB);

  static const Color present = Color(0xFF27AE60);
  static const Color late = Color(0xFFF39C12);
  static const Color absent = Color(0xFFE74C3C);

  static const Color cardShadow = Color(0x0A000000);
  static const Color headerGradientStart = Color(0xFF0D1B3E);
  static const Color headerGradientEnd = Color(0xFF1E3A6E);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [navyBlue, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [headerGradientStart, headerGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightGradient = LinearGradient(
    colors: [lightBlue, veryLightBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF39C12), Color(0xFFF1C40F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFE74C3C), Color(0xFFEC7063)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF2E5BFF), Color(0xFF5B8DFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF8E44AD), Color(0xFF9B59B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
