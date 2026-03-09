import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

/// AuthHeader displays the app logo and title for authentication screens.
/// Features: animated logo with glow effect and customizable subtitle.
class AuthHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final bool showLogo;

  const AuthHeader({
    super.key,
    this.title,
    this.subtitle,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showLogo) ...[
          _buildLogo(),
          const SizedBox(height: AppConstants.lg),
        ],
        if (title != null) ...[
          Text(
            title!,
            style: AppTypography.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.sm),
        ],
        if (subtitle != null) ...[
          Text(
            subtitle!,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1,
            ),
            color: AppColors.background.withValues(alpha: 0.8),
          ),
          child: const Icon(
            Icons.settings_input_component,
            size: 32,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
