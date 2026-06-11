import 'package:flutter/material.dart';

/// Global theme mode notifier. Wrap [MaterialApp] in a [ValueListenableBuilder]
/// on this notifier to get live theme switching without a state-management package.
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

class AppDarkColors {
  static const Color background = Color(0xFF0F1117);
  static const Color cardBg = Color(0xFF1A1D2E);
  static const Color surface = Color(0xFF252840);
  static const Color textPrimary = Color(0xFFF0F4FF);
  static const Color textSecondary = Color(0xFFB0BAC8);
  static const Color textHint = Color(0xFF6B7280);
  static const Color divider = Color(0xFF2E3254);
  static const Color primarySurface = Color(0xFF1E2B4A);
}
