import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

/// Reusable App Logo Widget
///
/// This widget displays the Revora logo from assets/images/revora_logo.png
/// and is used consistently across all screens (Splash, Onboarding, Login, Register, AppBar).
///
/// Features:
/// - Responsive sizing based on screen dimensions
/// - Optional animations (glow, scale, shimmer)
/// - Maintains aspect ratio for proper logo display
///
/// Usage:
/// ```dart
/// // Simple logo
/// AppLogo(size: 100)
///
/// // Logo with animation
/// AppLogo(size: 120, animate: true)
///
/// // Logo with custom glow intensity
/// AppLogo(size: 150, animate: true, glowIntensity: 0.6)
/// ```
class AppLogo extends StatelessWidget {
  /// Logo size in logical pixels (width and height)
  final double size;

  /// Whether to apply entrance animations
  final bool animate;

  /// Glow intensity (0.0 to 1.0)
  final double glowIntensity;

  /// Border radius for the logo container
  final double borderRadius;

  /// Optional box fit for the image
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.size = 100,
    this.animate = false,
    this.glowIntensity = 0.5,
    this.borderRadius = 24,
    this.fit = BoxFit.contain,
  });

  /// Creates a large logo variant for splash screens
  /// Uses 25% of screen width with max size of 180
  factory AppLogo.large(BuildContext context, {bool animate = true}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = (screenWidth * 0.25).clamp(120.0, 180.0);
    return AppLogo(size: size, animate: animate, glowIntensity: 0.6);
  }

  /// Creates a medium logo variant for auth screens (Login/Register)
  /// Uses 22% of screen width with max size of 100
  factory AppLogo.medium(BuildContext context, {bool animate = true}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = (screenWidth * 0.22).clamp(80.0, 100.0);
    return AppLogo(size: size, animate: animate, glowIntensity: 0.5);
  }

  /// Creates a small logo variant for headers and AppBars
  /// Fixed size of 40 for consistent app bar branding
  factory AppLogo.small() {
    return const AppLogo(
      size: 40,
      animate: false,
      glowIntensity: 0.3,
      borderRadius: 12,
    );
  }

  @override
  Widget build(BuildContext context) {
    final logoWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        // Subtle gradient background that complements the logo
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.neonCyan.withValues(alpha: 0.1 * glowIntensity),
            AppTheme.neonBlue.withValues(alpha: 0.1 * glowIntensity),
          ],
        ),
        // Neon glow effect
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonCyan.withValues(alpha: 0.3 * glowIntensity),
            blurRadius: size * 0.3,
            spreadRadius: size * 0.05,
          ),
          BoxShadow(
            color: AppTheme.neonBlue.withValues(alpha: 0.2 * glowIntensity),
            blurRadius: size * 0.5,
            spreadRadius: size * 0.1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          'assets/images/revora_logo.png',
          width: size,
          height: size,
          fit: fit,
          // Error builder shows a fallback if logo fails to load
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                gradient: AppTheme.neonGradient,
              ),
              child: Icon(
                Icons.electric_car,
                size: size * 0.5,
                color: Colors.black,
              ),
            );
          },
        ),
      ),
    );

    // Apply animations if enabled
    if (animate) {
      return logoWidget
          .animate()
          // Scale in animation
          .scale(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
          )
          // Shimmer effect
          .shimmer(
            duration: const Duration(seconds: 2),
            color: AppTheme.neonCyan.withValues(alpha: 0.2),
          );
    }

    return logoWidget;
  }
}

/// Animated App Logo for Splash Screen
///
/// A specialized version with continuous pulse animation
/// designed specifically for the splash screen experience.
class AnimatedSplashLogo extends StatefulWidget {
  final double size;

  const AnimatedSplashLogo({super.key, this.size = 150});

  @override
  State<AnimatedSplashLogo> createState() => _AnimatedSplashLogoState();
}

class _AnimatedSplashLogoState extends State<AnimatedSplashLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Pulse glow intensity
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Scale bounce animation
    _scaleAnimation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(
              begin: 0.0,
              end: 1.2,
            ).chain(CurveTween(curve: Curves.easeOutBack)),
            weight: 60,
          ),
          TweenSequenceItem(
            tween: Tween(
              begin: 1.2,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: 40,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _pulseController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              // Pulsing glow effect
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonCyan.withValues(
                    alpha: 0.5 * _pulseAnimation.value,
                  ),
                  blurRadius: widget.size * 0.4 * _pulseAnimation.value,
                  spreadRadius: widget.size * 0.1 * _pulseAnimation.value,
                ),
                BoxShadow(
                  color: AppTheme.neonBlue.withValues(
                    alpha: 0.3 * _pulseAnimation.value,
                  ),
                  blurRadius: widget.size * 0.6 * _pulseAnimation.value,
                  spreadRadius: widget.size * 0.15 * _pulseAnimation.value,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: Image.asset(
                'assets/images/revora_logo.png',
                width: widget.size,
                height: widget.size,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      gradient: AppTheme.neonGradient,
                    ),
                    child: Icon(
                      Icons.electric_car,
                      size: widget.size * 0.5,
                      color: Colors.black,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
