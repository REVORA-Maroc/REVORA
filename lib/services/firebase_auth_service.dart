import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

/// Firebase Authentication Service
/// Handles Email/Password auth and Google OAuth Sign-In
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isFirebaseInitialized = false;

  FirebaseAuthService() {
    _checkFirebaseInitialization();
  }

  void _checkFirebaseInitialization() {
    try {
      Firebase.app();
      _isFirebaseInitialized = true;
    } catch (e) {
      _isFirebaseInitialized = false;
      debugPrint('Firebase not initialized. Auth operations will use mock data.');
    }
  }

  // Get current user
  User? get currentUser {
    if (!_isFirebaseInitialized) return null;
    return _auth.currentUser;
  }

  // Auth state stream
  Stream<User?> get authStateChanges {
    if (!_isFirebaseInitialized) return Stream.value(null);
    return _auth.authStateChanges();
  }

  /// Sign in with Email and Password
  Future<UserCredential?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    if (!_isFirebaseInitialized) {
      // Mock authentication for demo
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('Mock sign in: $email');
      return null;
    }
    
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Register with Email and Password
  Future<UserCredential?> signUpWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    if (!_isFirebaseInitialized) {
      // Mock registration for demo
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('Mock sign up: $email');
      return null;
    }
    
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await credential.user?.updateDisplayName(name);
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign in with Google OAuth
  Future<UserCredential?> signInWithGoogle() async {
    if (!_isFirebaseInitialized) {
      // Mock Google sign in for demo
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('Mock Google sign in');
      return null;
    }
    
    try {
      // Begin interactive sign-in process
      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();
      
      if (gUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Create credential for user
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Sign in to Firebase with credential
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Google sign-in failed. Please try again.';
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (!_isFirebaseInitialized) return;
    
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    if (!_isFirebaseInitialized) {
      throw 'Firebase not initialized. Cannot reset password.';
    }
    
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Handle Firebase Auth Exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'invalid-credential':
        return 'Invalid credentials. Please try again.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}
