import 'package:flutter/material.dart';
import 'app_colors.dart';

/// AppTypography defines the text styles for the REVORA application.
/// Uses Inter-inspired design with clean, modern hierarchy.
class AppTypography {
  // Font Weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Display Styles
  static const TextStyle displayLarge = TextStyle(
    fontSize: 44,
    fontWeight: bold,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
    height: 1.1,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 36,
    fontWeight: bold,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
    height: 1.2,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 28,
    fontWeight: semibold,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
    height: 1.3,
  );

  // Heading Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: bold,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
    height: 1.3,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: semibold,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: semibold,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: regular,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: regular,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: regular,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Label Styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    color: AppColors.textSecondary,
    letterSpacing: 0.3,
    height: 1.5,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: medium,
    color: AppColors.textSecondary,
    letterSpacing: 0.3,
    height: 1.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: medium,
    color: AppColors.textMuted,
    letterSpacing: 0.5,
    height: 1.5,
  );

  // Button Styles
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: semibold,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: semibold,
    color: Colors.white,
    letterSpacing: 0.3,
  );

  // Special Styles
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: regular,
    color: AppColors.textMuted,
    height: 1.4,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: medium,
    color: AppColors.primary,
    letterSpacing: 2,
    height: 1.5,
  );
}
