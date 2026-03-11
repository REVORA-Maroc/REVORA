import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../main.dart'; // Import NavigationHelper
import '../services/preferences_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart'; // App logo for consistent branding

/// Modern Onboarding Screen with 3 pages
/// Features smooth animations, page indicators, and futuristic design
/// 
/// Navigation Logic:
/// - Shows 3 onboarding pages with swipe navigation
/// - "Get Started" button marks onboarding complete and navigates to Login
/// - Skip button available on first 2 pages
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      icon: Icons.speed,
      animationPath: 'assets/animations/onboarding1.json',
      title: 'Real-Time Monitoring',
      description: 'Track your vehicle\'s speed, RPM, and engine temperature instantly with live dashboard updates.',
      gradient: const [AppTheme.neonCyan, AppTheme.neonBlue],
    ),
    OnboardingPageData(
      icon: Icons.health_and_safety,
      animationPath: 'assets/animations/onboarding2.json',
      title: 'Vehicle Health',
      description: 'Get instant diagnostic alerts and understand your vehicle\'s health before problems occur.',
      gradient: const [AppTheme.electricGreen, Color(0xFF00CC6A)],
    ),
    OnboardingPageData(
      icon: Icons.auto_fix_high,
      animationPath: 'assets/animations/onboarding3.json',
      title: 'AI-Powered Insights',
      description: 'Receive intelligent recommendations to improve your driving efficiency and safety.',
      gradient: const [AppTheme.neonPurple, Color(0xFF7B2CBF)],
    ),
  ];

  final _preferences = PreferencesService();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skipOnboarding() {
    _finishOnboarding();
  }

  /// Finish onboarding and navigate to Login
  /// Marks onboarding as completed in SharedPreferences
  void _finishOnboarding() async {
    // Mark that user has seen onboarding
    await _preferences.setHasSeenOnboarding(true);
    debugPrint('✅ Onboarding marked as complete');
    
    // Navigate to login screen
    if (mounted) {
      NavigationHelper.navigateFromOnboardingToLogin(context);
    }
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
          child: SafeArea(
            child: Column(
              children: [
                // Header with logo and skip button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // App Logo - consistent branding across all screens
                      AppLogo.small(),
                      if (_currentPage < _pages.length - 1)
                        TextButton(
                          onPressed: _skipOnboarding,
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.textMuted,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            'Skip',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return OnboardingPage(
                        data: _pages[index],
                      );
                    },
                  ),
                ),

                // Bottom controls
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Page indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOutCubic,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: _currentPage == index ? 32 : 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: _currentPage == index
                                  ? AppTheme.neonCyan
                                  : AppTheme.graphite,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Next/Get Started button
                      GestureDetector(
                        onTap: _nextPage,
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: _currentPage == _pages.length - 1
                                ? AppTheme.neonGradient
                                : LinearGradient(
                                    colors: [
                                      AppTheme.charcoal,
                                      AppTheme.graphite,
                                    ],
                                  ),
                            boxShadow: _currentPage == _pages.length - 1
                                ? [
                                    BoxShadow(
                                      color: AppTheme.neonCyan.withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage == _pages.length - 1
                                    ? 'Get Started'
                                    : 'Next',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _currentPage == _pages.length - 1
                                      ? Colors.black
                                      : AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: _currentPage == _pages.length - 1
                                    ? Colors.black
                                    : AppTheme.textPrimary,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual onboarding page with animated illustration
class OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Lottie animation
            SizedBox(
              width: 260,
              height: 260,
              child: Lottie.asset(
                data.animationPath,
                fit: BoxFit.contain,
                repeat: true,
                animate: true,
              ),
            )
                .animate()
                .scale(duration: const Duration(milliseconds: 500))
                .then()
                .shimmer(duration: const Duration(seconds: 2)),

            const SizedBox(height: 40),

            // Title
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                height: 1.2,
              ),
            )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 200))
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 12),

            // Description
            Text(
              data.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppTheme.textSecondary,
                height: 1.6,
              ),
            )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 400))
                .slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Data model for onboarding pages
class OnboardingPageData {
  final IconData icon;
  final String animationPath;
  final String title;
  final String description;
  final List<Color> gradient;

  OnboardingPageData({
    required this.icon,
    required this.animationPath,
    required this.title,
    required this.description,
    required this.gradient,
  });
}
