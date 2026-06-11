import 'package:flutter/material.dart';

/// Konfigurasi warna sistem aplikasi Coolira
class AppColors {
  AppColors._(); // Private constructor untuk prevent instantiation

  // Base Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color mint = Color(0xFF65EEDE);
  static const Color skyBlue = Color(0xFF78CFED);
  static const Color lightGrey = Color(0xFFE5E7EB);
  static const Color darkGrey = Color(0xFFA1A1AA);

  // Alert Colors
  static const Color yellow = Color(0xFFFFBC00);
  static const Color red = Color(0xFFFF383C);
  static const Color green = Color(0xFF1ECF36);
  static const Color deepBlue = Color(0xFF468CD0);

  // Gradients
  static const LinearGradient primaryGrad = LinearGradient(
    colors: [mint, skyBlue],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient accentGrad = LinearGradient(
    colors: [skyBlue, deepBlue],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
