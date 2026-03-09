import 'package:flutter/material.dart';

/// AppColors defines the color palette for the REVORA application.
/// The design follows a dark futuristic theme with electric blue accents.
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF259df4);
  static const Color primaryDark = Color(0xFF1a7bc8);
  static const Color primaryLight = Color(0xFF5cb8f7);

  // Background Colors
  static const Color background = Color(0xFF101a22);
  static const Color backgroundLight = Color(0xFF1e293b);
  static const Color backgroundLighter = Color(0xFF2d3d4f);
  static const Color surface = Color(0xFF1e293b);
  static const Color surfaceLight = Color(0xFF334155);

  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94a3b8);
  static const Color textMuted = Color(0xFF64748b);

  // Status Colors
  static const Color success = Color(0xFF22c55e);
  static const Color error = Color(0xFFef4444);
  static const Color warning = Color(0xFFf59e0b);
  static const Color info = Color(0xFF3b82f6);

  // Utility Colors
  static const Color border = Color(0xFF334155);
  static const Color divider = Color(0xFF334155);
  static const Color overlay = Color(0xFF000000);

  // Gradient Colors
  static List<Color> get primaryGradient => [
        const Color(0xFF259df4),
        const Color(0xFF1a7bc8),
      ];

  static List<Color> get backgroundGradient => [
        const Color(0xFF101a22),
        const Color(0xFF0f172a),
      ];

  // Opacity Helpers
  static Color primaryWithOpacity(double opacity) =>
      primary.withValues(alpha: opacity);
  static Color backgroundWithOpacity(double opacity) =>
      background.withValues(alpha: opacity);
  static Color textSecondaryWithOpacity(double opacity) =>
      textSecondary.withValues(alpha: opacity);
}
