/// AppConstants contains application-wide constants for REVORA.
class AppConstants {
  AppConstants._();

  // App Information
  static const String appName = 'REVORA';
  static const String appTagline = 'Smart Vehicle Diagnostics';
  static const String appDescription = '& Driving Insights';

  // Animation Durations
  static const Duration quickAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration splashDuration = Duration(seconds: 3);

  // Spacing
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Border Radius
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 9999;

  // Layout
  static const double maxContentWidth = 400;
  static const double buttonHeight = 56;
  static const double inputHeight = 56;

  // Auth
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
}
