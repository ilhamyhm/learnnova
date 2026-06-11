import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF4F9DFF);
  static const Color primaryDark = Color(0xFF2E7DD4);
  static const Color primaryLight = Color(0xFF80BAFF);
  static const Color primarySurface = Color(0xFFE8F2FF); // light-mode static fallback

  // Neutral (light-mode defaults — also used as static fallback)
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F8FF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1D3A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFB0BAC8);
  static const Color divider = Color(0xFFE5EAF2);
  static const Color surface = Color(0xFFF0F4FF);

  // Accent
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

  // Gradients
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

// ── Adaptive colour palette ──────────────────────────────────────────────────
//
// Use `context.colors.*` wherever you need a neutral color that adapts to
// dark / light mode. Brand, accent, gradient and module colors stay as
// AppColors.* static constants — they look great on both themes.
//
//   ✅  context.colors.background   → adapts
//   ✅  context.colors.cardBg       → adapts
//   ✅  AppColors.primary           → always blue
//   ✅  AppColors.success           → always green

extension AppThemeExtension on BuildContext {
  _AppAdaptiveColors get colors {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return isDark ? _darkColors : _lightColors;
  }
}

// ── Light palette ────────────────────────────────────────────────────────────
const _lightColors = _AppAdaptiveColors(
  background: Color(0xFFF5F8FF),
  cardBg: Color(0xFFFFFFFF),
  surface: Color(0xFFF0F4FF),
  primarySurface: Color(0xFFE8F2FF),
  textPrimary: Color(0xFF1A1D3A),
  textSecondary: Color(0xFF6B7280),
  textHint: Color(0xFFB0BAC8),
  divider: Color(0xFFE5EAF2),
  successLight: Color(0xFFDCFCE7),
  errorLight: Color(0xFFFEE2E2),
  accentLight: Color(0xFFFFE0B2),
  warningLight: Color(0xFFFEF9C3),
);

// ── Dark palette ─────────────────────────────────────────────────────────────
const _darkColors = _AppAdaptiveColors(
  background: Color(0xFF0D0F1A),
  cardBg: Color(0xFF161928),
  surface: Color(0xFF1E2235),
  primarySurface: Color(0xFF1A2540),
  textPrimary: Color(0xFFEEF2FF),
  textSecondary: Color(0xFF9BA3B8),
  textHint: Color(0xFF4B5268),
  divider: Color(0xFF252A40),
  successLight: Color(0xFF0D2A1A),
  errorLight: Color(0xFF2A0D0D),
  accentLight: Color(0xFF2A1E0D),
  warningLight: Color(0xFF2A240D),
);

// ── Data class ───────────────────────────────────────────────────────────────
@immutable
class _AppAdaptiveColors {
  final Color background;
  final Color cardBg;
  final Color surface;
  final Color primarySurface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color divider;
  final Color successLight;
  final Color errorLight;
  final Color accentLight;
  final Color warningLight;

  const _AppAdaptiveColors({
    required this.background,
    required this.cardBg,
    required this.surface,
    required this.primarySurface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.divider,
    required this.successLight,
    required this.errorLight,
    required this.accentLight,
    required this.warningLight,
  });
}
