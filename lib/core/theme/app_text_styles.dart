import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Centralized Typography Hierarchy utilizing Inter font.
class AppTextStyles {
  AppTextStyles._();

  // Screen Title / Large Display (24 - 28px)
  static TextStyle screenHeading = GoogleFonts.inter(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.mainText,
    letterSpacing: -0.5,
  );

  // Section Heading (18 - 20px)
  static TextStyle sectionHeading = GoogleFonts.inter(
    fontSize: 19,
    fontWeight: FontWeight.w600,
    color: AppColors.mainText,
    letterSpacing: -0.3,
  );

  // Card Heading (15 - 17px)
  static TextStyle cardHeading = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.mainText,
  );

  // Body Regular (14 - 16px)
  static TextStyle body = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.mainText,
    height: 1.5,
  );

  // Body Medium (14px)
  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.mainText,
  );

  // Secondary Supporting Text (12 - 14px)
  static TextStyle supporting = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
    height: 1.4,
  );

  // Button Label (14 - 16px)
  static TextStyle button = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );

  // Small Metadata / Badge (11 - 12px)
  static TextStyle metadata = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.mutedText,
    letterSpacing: 0.2,
  );

  static TextStyle get buttonText => button;
}
