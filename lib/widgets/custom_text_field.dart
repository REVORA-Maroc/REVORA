import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/theme.dart';

/// CustomTextField is a reusable, modern text field widget for authentication screens.
/// Features: icons, validation, animations, and customizable styling.
class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixPressed;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool autofocus;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final Widget? customSuffix;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixPressed,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.autofocus = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.inputFormatters,
    this.contentPadding,
    this.style,
    this.hintStyle,
    this.customSuffix,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  FocusNode? _internalFocusNode;
  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode!;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.normalAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
    }
    _effectiveFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _effectiveFocusNode.hasFocus;
      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_onFocusChange);
    _animationController.dispose();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              boxShadow: [
                if (_isFocused)
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3 * _glowAnimation.value),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: TextFormField(
              controller: widget.controller,
              focusNode: _effectiveFocusNode,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              obscureText: widget.obscureText,
              autofocus: widget.autofocus,
              readOnly: widget.readOnly,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              maxLength: widget.maxLength,
              validator: widget.validator,
              onChanged: widget.onChanged,
              onFieldSubmitted: widget.onSubmitted,
              onTap: widget.onTap,
              inputFormatters: widget.inputFormatters,
              style: widget.style ?? AppTypography.bodyLarge,
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: widget.hint,
                helperText: widget.helperText,
                helperStyle: AppTypography.caption,
                prefixIcon: widget.prefixIcon != null
                    ? Container(
                        margin: const EdgeInsets.only(left: 8, right: 8),
                        decoration: BoxDecoration(
                          color: _isFocused
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                        ),
                        child: Icon(
                          widget.prefixIcon,
                          color: _isFocused ? AppColors.primary : AppColors.textMuted,
                          size: 20,
                        ),
                      )
                    : null,
                suffixIcon: widget.customSuffix ??
                    (widget.suffixIcon != null
                        ? Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                                onTap: widget.onSuffixPressed,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    widget.suffixIcon,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : null),
                contentPadding: widget.contentPadding ??
                    const EdgeInsets.symmetric(
                      horizontal: AppConstants.lg,
                      vertical: AppConstants.md,
                    ),
                hintStyle: widget.hintStyle ??
                    AppTypography.bodyLarge.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}
