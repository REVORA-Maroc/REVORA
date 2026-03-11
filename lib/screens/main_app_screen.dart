import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_auth_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

/// Main App Dashboard (Placeholder)
/// Shows after successful authentication
class MainAppScreen extends StatelessWidget {
  const MainAppScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final authService = FirebaseAuthService();
    await authService.signOut();
    
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuthService().currentUser;
    
    return Scaffold(
      backgroundColor: AppTheme.deepSpace,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'REVORA',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _signOut(context),
            icon: const Icon(
              Icons.logout,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.darkBackgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppTheme.neonCyan, AppTheme.neonBlue],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonCyan.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 60,
                    color: Colors.black,
                  ),
                )
                    .animate()
                    .scale(duration: const Duration(milliseconds: 500))
                    .then()
                    .shimmer(duration: const Duration(seconds: 2)),
                
                const SizedBox(height: 32),
                
                // Welcome Text
                Text(
                  'Welcome!',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // User Info
                if (user != null) ...[
                  Text(
                    user.displayName ?? 'User',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.neonCyan,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Description
                Text(
                  'Dashboard will be implemented here.\nThis is a placeholder for the main app content.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textMuted,
                    height: 1.6,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Sign Out Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.glassBorder,
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _signOut(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.logout,
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Sign Out',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
