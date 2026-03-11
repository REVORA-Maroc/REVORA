import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import '../main.dart';
import '../services/preferences_service.dart';
import '../theme/app_theme.dart';

/// Improved Splash Screen - Instant appearance with smooth animations
/// 
/// Features:
/// - Immediate display (no white screen)
/// - Centered, larger animated logo
/// - Smooth transitions to next screen
/// - 3 second display time
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;
  
  final _preferences = PreferencesService();
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeAndNavigate();
  }
  
  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Logo scale animation with bounce
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Fade in animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Glow pulse animation
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Start animation immediately
    _animationController.forward();
  }

  /// Initialize services and navigate after 3 seconds
  void _initializeAndNavigate() async {
    // Start initialization in parallel
    final initFuture = _initializeServices();
    
    // Wait exactly 3 seconds to show splash
    await Future.delayed(const Duration(milliseconds: 3000));
    
    // Wait for initialization to complete if not done
    await initFuture;
    
    if (_isNavigating || !mounted) return;
    _isNavigating = true;
    
    final hasSeenOnboarding = _preferences.hasSeenOnboarding;
    
    if (hasSeenOnboarding) {
      NavigationHelper.navigateToLogin(context);
    } else {
      NavigationHelper.navigateToOnboarding(context);
    }
  }
  
  /// Initialize Firebase and SharedPreferences
  Future<void> _initializeServices() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();
      debugPrint('✅ Firebase initialized successfully');
    } catch (e) {
      debugPrint('⚠️ Firebase initialization error: $e');
    }
    
    // Initialize SharedPreferences
    try {
      await _preferences.init();
    } catch (e) {
      debugPrint('⚠️ SharedPreferences initialization error: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.systemUiOverlayStyle,
      child: Scaffold(
        backgroundColor: AppTheme.deepSpace,
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.darkBackgroundGradient,
          ),
          child: Stack(
            children: [
              // Animated background particles
              Positioned.fill(
                child: CustomPaint(
                  painter: ParticleBackgroundPainter(),
                ),
              ),

              // Central content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo - Bigger and centered
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(48),
                                boxShadow: [
                                BoxShadow(
                                  color: AppTheme.neonCyan.withValues(
                                    alpha: 0.3 * _glowAnimation.value,
                                  ),
                                  blurRadius: 50 * _glowAnimation.value,
                                  spreadRadius: 15 * _glowAnimation.value,
                                ),
                              ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(48),
                                child: Image.asset(
                                  'assets/images/revora_logo.png',
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(48),
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [AppTheme.neonCyan, AppTheme.neonBlue],
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.electric_car,
                                        size: 100,
                                        color: Colors.black,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 48),

                    // App name with shimmer
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            'REVORA',
                            style: GoogleFonts.inter(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                              letterSpacing: 12,
                              shadows: [
                                Shadow(
                                  color: AppTheme.neonCyan.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                          )
                              .animate(onPlay: (controller) => controller.repeat())
                              .shimmer(
                                duration: const Duration(seconds: 2),
                                color: AppTheme.neonCyan.withValues(alpha: 0.3),
                              ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Tagline
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: CurvedAnimation(
                            parent: _animationController,
                            curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
                          ),
                          child: Text(
                            'AI-Powered Vehicle Diagnostics',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                              letterSpacing: 2,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 80),

                    // Loading indicator
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: CurvedAnimation(
                            parent: _animationController,
                            curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
                          ),
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.neonCyan,
                              ),
                              backgroundColor: AppTheme.glassBorder,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated particle background painter
class ParticleBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.neonCyan.withValues(alpha: 0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw floating particles
    final particlePaint = Paint()
      ..color = AppTheme.neonCyan.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Random particle positions (static for consistency)
    final particles = [
      Offset(size.width * 0.1, size.height * 0.2),
      Offset(size.width * 0.3, size.height * 0.15),
      Offset(size.width * 0.7, size.height * 0.25),
      Offset(size.width * 0.85, size.height * 0.4),
      Offset(size.width * 0.2, size.height * 0.6),
      Offset(size.width * 0.5, size.height * 0.7),
      Offset(size.width * 0.8, size.height * 0.65),
      Offset(size.width * 0.15, size.height * 0.8),
      Offset(size.width * 0.6, size.height * 0.85),
      Offset(size.width * 0.9, size.height * 0.9),
    ];

    for (var particle in particles) {
      canvas.drawCircle(particle, 2, particlePaint);
    }

    // Draw subtle connecting lines
    for (int i = 0; i < particles.length - 1; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final distance = (particles[i] - particles[j]).distance;
        if (distance < 150) {
          canvas.drawLine(
            particles[i],
            particles[j],
            paint..color = AppTheme.neonCyan.withValues(alpha: 0.03),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
