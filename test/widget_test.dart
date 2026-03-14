import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revora/theme/app_theme.dart';

void main() {
  testWidgets('AppTheme is properly configured', (WidgetTester tester) async {
    // Test that the theme can be created without errors
    final theme = AppTheme.futuristicTheme;
    
    expect(theme, isNotNull);
    expect(theme.primaryColor, AppTheme.neonCyan);
    expect(theme.scaffoldBackgroundColor, AppTheme.deepSpace);
  });

  test('AppTheme colors are defined correctly', () {
    // Verify primary colors
    expect(AppTheme.neonCyan, const Color(0xFF00F0FF));
    expect(AppTheme.neonBlue, const Color(0xFF00A8E8));
    expect(AppTheme.deepSpace, const Color(0xFF05070A));
    
    // Verify text colors
    expect(AppTheme.textPrimary, const Color(0xFFFFFFFF));
    expect(AppTheme.textSecondary, const Color(0xFFB0B8C9));
  });
}
