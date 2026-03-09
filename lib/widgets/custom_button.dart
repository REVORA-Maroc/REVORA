import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

/// CustomButton is a reusable, animated button widget with multiple variants.
/// Features: primary, secondary, outline, and ghost variants with press animations.
class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonVariant variant;
  final CustomButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = CustomButtonVariant.primary,
    this.size = CustomButtonSize.large,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.width,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

enum CustomButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
}

enum CustomButtonSize {
  small,
  medium,
  large,
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.quickAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isLoading && widget.onPressed != null) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(
              width: widget.isFullWidth ? double.infinity : widget.width,
              height: _getHeight(),
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : widget.onPressed,
                style: _getButtonStyle(),
                child: _buildChild(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChild() {
    if (widget.isLoading) {
      return SizedBox(
        height: _getLoadingSize(),
        width: _getLoadingSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.variant == CustomButtonVariant.primary
                ? Colors.white
                : AppColors.primary,
          ),
        ),
      );
    }

    final textWidget = Text(
      widget.text,
      style: _getTextStyle(),
    );

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.icon,
            size: _getIconSize(),
            color: _getContentColor(),
          ),
          const SizedBox(width: AppConstants.sm),
          textWidget,
        ],
      );
    }

    return textWidget;
  }

  double _getHeight() {
    switch (widget.size) {
      case CustomButtonSize.small:
        return 40;
      case CustomButtonSize.medium:
        return 48;
      case CustomButtonSize.large:
        return AppConstants.buttonHeight;
    }
  }

  double _getLoadingSize() {
    switch (widget.size) {
      case CustomButtonSize.small:
        return 16;
      case CustomButtonSize.medium:
        return 20;
      case CustomButtonSize.large:
        return 24;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case CustomButtonSize.small:
        return 16;
      case CustomButtonSize.medium:
        return 20;
      case CustomButtonSize.large:
        return 24;
    }
  }

  TextStyle _getTextStyle() {
    final baseStyle = switch (widget.size) {
      CustomButtonSize.small => AppTypography.buttonMedium.copyWith(fontSize: 13),
      CustomButtonSize.medium => AppTypography.buttonMedium,
      CustomButtonSize.large => AppTypography.buttonLarge,
    };

    return baseStyle.copyWith(
      color: _getContentColor(),
    );
  }

  Color _getContentColor() {
    switch (widget.variant) {
      case CustomButtonVariant.primary:
        return Colors.white;
      case CustomButtonVariant.secondary:
        return AppColors.textPrimary;
      case CustomButtonVariant.outline:
        return AppColors.primary;
      case CustomButtonVariant.ghost:
        return AppColors.textSecondary;
    }
  }

  ButtonStyle _getButtonStyle() {
    final baseStyle = ElevatedButton.styleFrom(
      backgroundColor: _getBackgroundColor(),
      foregroundColor: _getContentColor(),
      disabledBackgroundColor: AppColors.surfaceLight,
      disabledForegroundColor: AppColors.textMuted,
      elevation: _getElevation(),
      shadowColor: _getShadowColor(),
      padding: _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        side: _getBorderSide(),
      ),
    );

    return baseStyle;
  }

  Color _getBackgroundColor() {
    switch (widget.variant) {
      case CustomButtonVariant.primary:
        return AppColors.primary;
      case CustomButtonVariant.secondary:
        return AppColors.surface;
      case CustomButtonVariant.outline:
      case CustomButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  double _getElevation() {
    if (widget.variant == CustomButtonVariant.ghost) return 0;
    return _isPressed ? 2 : 4;
  }

  Color? _getShadowColor() {
    if (widget.variant == CustomButtonVariant.primary) {
      return AppColors.primary.withValues(alpha: 0.4);
    }
    return null;
  }

  BorderSide _getBorderSide() {
    switch (widget.variant) {
      case CustomButtonVariant.primary:
      case CustomButtonVariant.secondary:
        return BorderSide.none;
      case CustomButtonVariant.outline:
        return BorderSide(
          color: AppColors.primary.withValues(alpha: 0.5),
          width: 1.5,
        );
      case CustomButtonVariant.ghost:
        return BorderSide.none;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (widget.size) {
      case CustomButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case CustomButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case CustomButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppConstants.xl,
          vertical: AppConstants.md,
        );
    }
  }
}
