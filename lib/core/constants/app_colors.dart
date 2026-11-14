import 'package:flutter/material.dart';

/// Centralized application color palette according to Design System
/// Dark-green and warm-cream palette for modern SaaS product feel.
class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF174D3A);
  static const Color primaryDark = Color(0xFF103B2C);
  static const Color primaryLight = Color(0xFFE5F0E9);

  // Backgrounds & Surfaces
  static const Color mainBackground = Color(0xFFF6F3EB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color secondarySurface = Color(0xFFF3F1EB);

  // Text Colors
  static const Color mainText = Color(0xFF202923);
  static const Color secondaryText = Color(0xFF6D776F);
  static const Color mutedText = Color(0xFF98A099);

  // Borders & Dividers
  static const Color border = Color(0xFFE6E8E3);
  static const Color divider = Color(0xFFEEEEEE);

  // Status & Semantic Feedback
  static const Color success = Color(0xFF218653);
  static const Color successBackground = Color(0xFFE8F5EC);

  static const Color warning = Color(0xFFB7791F);
  static const Color warningBackground = Color(0xFFFFF4DD);

  static const Color error = Color(0xFFC43D43);
  static const Color errorBackground = Color(0xFFFCEBEC);

  static const Color information = Color(0xFF2878B5);
  static const Color informationBackground = Color(0xFFEAF3FC);

  // Disabled States
  static const Color disabledBackground = Color(0xFFECEEE9);
  static const Color disabledText = Color(0xFF9AA19B);

  // Accent Tints for ATS scores
  static const Color scoreHigh = Color(0xFF1B8755);
  static const Color scoreMedium = Color(0xFFD97706);
  static const Color scoreLow = Color(0xFFDC2626);
}
