import 'package:flutter/material.dart';

class AppColors {
  // Primary — 60%
  static const Color primary = Color(0xFF4F9DFF);
  static const Color primaryDark = Color(0xFF2E7DD4);
  static const Color primaryLight = Color(0xFF80BAFF);
  static const Color primarySurface = Color(0xFFE8F2FF);

  // Neutral — 30%
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F8FF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1D3A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFB0BAC8);
  static const Color divider = Color(0xFFE5EAF2);
  static const Color surface = Color(0xFFF0F4FF);

  // Accent — 10%
  static const Color accent = Color(0xFFFF9F43);
  static const Color accentLight = Color(0xFFFFE0B2);
  static const Color accentDark = Color(0xFFE8831A);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFFBBF24);
  static const Color warningLight = Color(0xFFFEF9C3);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  // Module Colors
  static const Color moduleCodeLab = Color(0xFF4F9DFF);
  static const Color moduleCreative = Color(0xFFB57BFF);
  static const Color moduleAnimation = Color(0xFFFF6B9D);
  static const Color moduleBiz = Color(0xFF22D3EE);
  static const Color moduleLanguage = Color(0xFF4ADE80);
  static const Color moduleAcademy = Color(0xFFFBBF24);
  static const Color moduleFunSkill = Color(0xFFFF9F43);
  static const Color moduleSports = Color(0xFF34D399);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F9DFF), Color(0xFF2E7DD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1A1D3A), Color(0xFF2E3A6E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF9F43), Color(0xFFFF6B35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
