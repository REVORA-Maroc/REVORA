import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart'; // Import NavigationHelper
import '../services/preferences_service.dart';
import '../theme/app_theme.dart';

/// Futuristic Splash Screen with animated gradient and neon effects
/// 
/// Navigation Logic:
/// - Shows for 3 seconds with animation
/// - First-time users → Navigates to OnboardingScreen
/// - Returning users → Navigates directly to LoginScreen
/// - Uses SharedPreferences to track if user has seen onboarding
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  
  final _preferences = PreferencesService();
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _initAnimations();
    
    // Start navigation sequence after splash display
    _startNavigationSequence();
  }
  
  /// Initialize all animation controllers
  void _initAnimations() {
    // Logo scale animation with bounce effect
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_logoController);

    // Glow pulse animation for neon effect
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  /// Main navigation sequence
  /// 1. Show splash animations (3 seconds)
  /// 2. Check if user has seen onboarding
  /// 3. Navigate to appropriate screen
  void _startNavigationSequence() async {
    // Start logo animation immediately
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _logoController.forward();
    
    // Wait for full splash display (3 seconds total)
    await Future.delayed(const Duration(milliseconds: 3000));
    
    // Prevent multiple navigations
    if (_isNavigating || !mounted) return;
    _isNavigating = true;
    
    // Check if user has seen onboarding
    final hasSeenOnboarding = _preferences.hasSeenOnboarding;
    
    debugPrint('🔍 Checking onboarding status: $hasSeenOnboarding');
    
    if (hasSeenOnboarding) {
      // Returning user - go directly to Login
      debugPrint('👤 Returning user → LoginScreen');
      NavigationHelper.navigateToLogin(context);
    } else {
      // First-time user - show Onboarding
      debugPrint('🆕 First-time user → OnboardingScreen');
      NavigationHelper.navigateToOnboarding(context);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepSpace,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.darkBackgroundGradient,
        ),
        child: Stack(
          children: [
            // Animated background grid
            Positioned.fill(
              child: CustomPaint(
                painter: NeonGridPainter(),
              ),
            ),

            // Central glow effect with pulse animation
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Center(
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.neonCyan.withOpacity(0.15 * _glowAnimation.value),
                          AppTheme.neonBlue.withOpacity(0.05 * _glowAnimation.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo with scale effect
                  // Uses the actual Revora logo from assets with pulsing glow animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(36),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.neonCyan
                                    .withOpacity(0.5 * _glowAnimation.value),
                                blurRadius: 60 * _glowAnimation.value,
                                spreadRadius: 20 * _glowAnimation.value,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(36),
                            child: Image.asset(
                              'assets/images/revora_logo.png',
                              width: 150,
                              height: 150,
                              fit: BoxFit.contain,
                              // Fallback icon if logo fails to load
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(36),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [AppTheme.neonCyan, AppTheme.neonBlue],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.electric_car,
                                    size: 75,
                                    color: Colors.black,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 40),

                  // App name with shimmer effect
                  Text(
                    'REVORA',
                    style: GoogleFonts.inter(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                      letterSpacing: 8,
                    ),
                  )
                      .animate()
                      .shimmer(
                        duration: const Duration(seconds: 2),
                        color: AppTheme.neonCyan.withOpacity(0.3),
                      ),

                  const SizedBox(height: 12),

                  // Tagline
                  Text(
                    'AI-Powered Vehicle Diagnostics',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                      letterSpacing: 1,
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 600)),

                  const SizedBox(height: 60),

                  // Loading indicator
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.neonCyan,
                      ),
                      backgroundColor: AppTheme.glassBorder,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: const Duration(milliseconds: 800)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated neon grid background painter
/// Creates a futuristic grid effect with glowing points
class NeonGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.neonCyan.withOpacity(0.03)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw intersection points
    final pointPaint = Paint()
      ..color = AppTheme.neonCyan.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += 50) {
      for (double y = 0; y < size.height; y += 50) {
        canvas.drawCircle(Offset(x, y), 1.5, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
