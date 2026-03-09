import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/preferences_service.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';

/// Main entry point for Revora app
/// Shows SplashScreen immediately while initializing in background
void main() {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI style immediately for immersive experience
  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemUiOverlayStyle);
  
  // Run the app immediately with SplashScreen
  // SplashScreen will handle initialization
  runApp(const MyApp());
}

/// Root widget of the application
/// Shows SplashScreen immediately
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Revora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.futuristicTheme,
      
      // Show SplashScreen as initial route
      home: const SplashScreen(),
    );
  }
}

/// Navigation helper class
/// Provides smooth transition animations between screens
class NavigationHelper {
  
  /// Navigate to Onboarding screen with slide + fade animation
  static void navigateToOnboarding(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Combine fade and slide animations for smooth transition
          var slideAnimation = Tween<Offset>(
            begin: const Offset(1.0, 0.0), // Slide from right
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          ));
          
          var fadeAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ));
          
          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }
  
  /// Navigate to Login screen with scale + fade animation
  static void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Scale up animation for dramatic effect
          var scaleAnimation = Tween<double>(
            begin: 0.95,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));
          
          var fadeAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ));
          
          return ScaleTransition(
            scale: scaleAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
  
  /// Navigate from Onboarding to Login with slide animation
  static void navigateFromOnboardingToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var slideAnimation = Tween<Offset>(
            begin: const Offset(0.0, 1.0), // Slide from bottom
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          ));
          
          return SlideTransition(
            position: slideAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
