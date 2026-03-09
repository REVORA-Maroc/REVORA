import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/firebase_auth_service.dart';
import 'register_screen.dart';
import 'home_screen.dart';

/// Professional Login Screen with compact layout
/// Features clean design, smooth animations, and OAuth options
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = FirebaseAuthService();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle email/password login
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final credential = await _authService.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (credential != null && mounted) {
        _navigateToHome();
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

  /// Handle Google Sign-In
  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);

    try {
      final credential = await _authService.signInWithGoogle();

      if (credential != null && mounted) {
        _navigateToHome();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Google sign-in failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  /// Handle Apple Sign-In
  Future<void> _signInWithApple() async {
    setState(() => _isAppleLoading = true);

    try {
      final credential = await _authService.signInWithApple();

      if (credential != null && mounted) {
        _navigateToHome();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Apple sign-in failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isAppleLoading = false);
      }
    }
  }

  /// Navigate to Home screen after successful login
  /// Using pushReplacement to prevent going back to login
  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Fade + Scale transition for smooth entry
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
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
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
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
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RegisterScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var tween = Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeInOutCubic));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 750;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.systemUiOverlayStyle,
      child: Scaffold(
        backgroundColor: AppTheme.deepSpace,
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.darkBackgroundGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: isSmallScreen ? 8 : 12,
              ),
              child: Column(
                children: [
                  // Main scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: isSmallScreen ? 16 : 24),
                            
                            // Logo with proper spacing
                            Center(
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.neonCyan.withOpacity(0.3),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    'assets/images/revora_logo.png',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppTheme.neonCyan,
                                              AppTheme.neonBlue
                                            ],
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.electric_car,
                                          size: 40,
                                          color: Colors.black,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: const Duration(milliseconds: 400))
                                  .scale(delay: const Duration(milliseconds: 100)),
                            ),

                            const SizedBox(height: 20),

                            // Welcome Text
                            Text(
                              'Welcome Back',
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            )
                                .animate()
                                .fadeIn(delay: const Duration(milliseconds: 200))
                                .slideY(begin: 0.2, end: 0),

                            const SizedBox(height: 4),

                            Text(
                              'Sign in to continue',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            )
                                .animate()
                                .fadeIn(delay: const Duration(milliseconds: 300)),

                            SizedBox(height: isSmallScreen ? 20 : 28),

                            // Email Field
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'name@example.com',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value!)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            )
                                .animate()
                                .fadeIn(delay: const Duration(milliseconds: 400))
                                .slideX(begin: -0.1, end: 0),

                            const SizedBox(height: 14),

                            // Password Field
                            _buildTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: '••••••••',
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              suffixIcon: _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              onSuffixTap: () {
                                setState(() =>
                                    _obscurePassword = !_obscurePassword);
                              },
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter your password';
                                }
                                if (value!.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            )
                                .animate()
                                .fadeIn(delay: const Duration(milliseconds: 500))
                                .slideX(begin: -0.1, end: 0),

                            const SizedBox(height: 8),

                            // Forgot Password - Right aligned
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // Handle forgot password
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.neonCyan,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(delay: const Duration(milliseconds: 600)),

                            SizedBox(height: isSmallScreen ? 16 : 20),

                            // Sign In Button
                            _buildSignInButton()
                                .animate()
                                .fadeIn(delay: const Duration(milliseconds: 700))
                                .scale(delay: const Duration(milliseconds: 700)),

                            const SizedBox(height: 20),

                            // Divider
                            _buildDivider()
                                .animate()
                                .fadeIn(delay: const Duration(milliseconds: 800)),

                            const SizedBox(height: 16),

                            // Social Login Options
                            _buildSocialButtons()
                                .animate()
                                .fadeIn(delay: const Duration(milliseconds: 900)),

                            const SizedBox(height: 20),

                            // Register Link
                            _buildRegisterLink()
                                .animate()
                                .fadeIn(delay: const Duration(milliseconds: 1000)),

                            SizedBox(height: isSmallScreen ? 16 : 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: AppTheme.textPrimary,
          ),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 15,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: AppTheme.textSecondary,
              size: 20,
            ),
            suffixIcon: suffixIcon != null
                ? GestureDetector(
                    onTap: onSuffixTap,
                    child: Icon(
                      suffixIcon,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                  )
                : null,
            filled: true,
            fillColor: AppTheme.glassDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppTheme.glassBorder,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppTheme.neonCyan,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Colors.redAccent,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.neonCyan,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sign In',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.black,
                    size: 20,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.glassBorder,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or continue with',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.glassBorder,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Google Button
        _buildSocialButton(
          onTap: _isGoogleLoading ? null : _signInWithGoogle,
          iconPath: 'assets/icons/Google.png',
          isLoading: _isGoogleLoading,
          label: 'Google',
        ),
        const SizedBox(width: 16),
        // Apple Button
        _buildSocialButton(
          onTap: _isAppleLoading ? null : _signInWithApple,
          iconPath: 'assets/icons/Apple.png',
          isLoading: _isAppleLoading,
          label: 'Apple',
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required VoidCallback? onTap,
    required String iconPath,
    required bool isLoading,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 56,
        decoration: BoxDecoration(
          color: AppTheme.glassDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.glassBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppTheme.neonCyan),
                  ),
                ),
              )
            : Center(
                child: Image.asset(
                  iconPath,
                  width: 28,
                  height: 28,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      label == 'Google' ? Icons.g_mobiledata : Icons.apple,
                      color: AppTheme.textPrimary,
                      size: 28,
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: _navigateToRegister,
          child: Text(
            'Create Account',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.neonCyan,
            ),
          ),
        ),
      ],
    );
  }
}
