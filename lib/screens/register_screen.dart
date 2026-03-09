import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/firebase_auth_service.dart';
import '../widgets/futuristic_widgets.dart';
import '../widgets/app_logo.dart'; // App logo for consistent branding
import 'main_app_screen.dart';

/// Futuristic Register Screen with Firebase OAuth
/// Features glassmorphism, password strength, and Google Sign-Up
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = FirebaseAuthService();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Handle registration with email/password
  Future<void> _register() async {
    if (!_agreedToTerms) {
      _showErrorSnackBar('Please agree to the Terms of Service and Privacy Policy');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final credential = await _authService.signUpWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );

      if (credential != null && mounted) {
        _showSuccessSnackBar('Account created successfully!');
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          _navigateToHome();
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Handle Google Sign-Up
  Future<void> _signUpWithGoogle() async {
    setState(() => _isGoogleLoading = true);

    try {
      final credential = await _authService.signInWithGoogle();

      if (credential != null && mounted) {
        _showSuccessSnackBar('Welcome to Revora!');
        _navigateToHome();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainAppScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.electricGreen.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pop(context);
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Back Button & Header
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _navigateToLogin,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.glassDark,
                                border: Border.all(
                                  color: AppTheme.glassBorder,
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: AppTheme.textPrimary,
                                size: 20,
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn()
                              .scale(delay: const Duration(milliseconds: 100)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Create Account',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            )
                                .animate()
                                .fadeIn()
                                .slideX(begin: 0.2, end: 0),
                          ),
                          const SizedBox(width: 44),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // App Logo - displays the Revora logo from assets with animation
                      Center(child: AppLogo.medium(context, animate: true)),

                      const SizedBox(height: 24),

                      // Header Text
                      Text(
                        'Join Revora AI',
                        style: GoogleFonts.inter(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 100))
                          .slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 8),

                      Text(
                        'Monitor your vehicle\'s health with professional OBD-II diagnostics.',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 200)),

                      const SizedBox(height: 32),

                      // Full Name Field
                      FuturisticTextField(
                        label: 'Full Name',
                        hint: 'John Doe',
                        prefixIcon: Icons.person_outline,
                        controller: _nameController,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your full name';
                          }
                          if (value!.length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      )
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 300))
                          .slideX(begin: -0.1, end: 0),

                      const SizedBox(height: 20),

                      // Email Field
                      FuturisticTextField(
                        label: 'Email Address',
                        hint: 'name@example.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      )
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 400))
                          .slideX(begin: -0.1, end: 0),

                      const SizedBox(height: 20),

                      // Password Field
                      FuturisticTextField(
                        label: 'Password',
                        hint: '••••••••',
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        obscureText: _obscurePassword,
                        onSuffixTap: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        controller: _passwordController,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter a password';
                          }
                          if (value!.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      )
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 500))
                          .slideX(begin: -0.1, end: 0),

                      const SizedBox(height: 12),

                      // Password Strength Indicator
                      PasswordStrengthIndicator(
                        password: _passwordController.text,
                      )
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 550)),

                      const SizedBox(height: 20),

                      // Confirm Password Field
                      FuturisticTextField(
                        label: 'Confirm Password',
                        hint: '••••••••',
                        prefixIcon: Icons.lock_reset_outlined,
                        suffixIcon: _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        obscureText: _obscureConfirmPassword,
                        onSuffixTap: () {
                          setState(() =>
                              _obscureConfirmPassword = !_obscureConfirmPassword);
                        },
                        controller: _confirmPasswordController,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      )
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 600))
                          .slideX(begin: -0.1, end: 0),

                      const SizedBox(height: 24),

                      // Terms Checkbox
                      GestureDetector(
                        onTap: () {
                          setState(() => _agreedToTerms = !_agreedToTerms);
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _agreedToTerms
                                      ? AppTheme.neonCyan
                                      : AppTheme.glassBorder,
                                  width: _agreedToTerms ? 2 : 1.5,
                                ),
                                color: _agreedToTerms
                                    ? AppTheme.neonCyan
                                    : Colors.transparent,
                                boxShadow: _agreedToTerms
                                    ? [
                                        BoxShadow(
                                          color:
                                              AppTheme.neonCyan.withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: _agreedToTerms
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.black,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: AppTheme.textSecondary,
                                  ),
                                  children: [
                                    const TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: const TextStyle(
                                        color: AppTheme.neonCyan,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: const TextStyle(
                                        color: AppTheme.neonCyan,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 700)),

                      const SizedBox(height: 28),

                      // Create Account Button
                      NeonButton(
                        text: 'Create Account',
                        onPressed: _register,
                        isLoading: _isLoading,
                        height: 60,
                      )
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 800))
                          .scale(delay: const Duration(milliseconds: 800)),

                      const SizedBox(height: 20),

                      // Divider
                      const FuturisticDivider()
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 900)),

                      const SizedBox(height: 20),

                      // Google Sign Up Button
                      GoogleSignInButton(
                        onPressed: _signUpWithGoogle,
                        isLoading: _isGoogleLoading,
                      )
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 1000))
                          .slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 24),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: _navigateToLogin,
                            child: Text(
                              'Sign In',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.neonCyan,
                              ),
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 1100)),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
