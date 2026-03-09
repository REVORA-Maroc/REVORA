import 'package:shared_preferences/shared_preferences.dart';

/// Service to handle app preferences and persistent storage
/// Used to track first-time user states
class PreferencesService {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String _isLoggedInKey = 'is_logged_in';
  
  // Singleton instance
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();
  
  SharedPreferences? _prefs;
  
  /// Initialize SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  /// Check if user has seen onboarding
  /// Returns true if user has completed onboarding, false for first-time users
  bool get hasSeenOnboarding {
    return _prefs?.getBool(_hasSeenOnboardingKey) ?? false;
  }
  
  /// Mark onboarding as completed
  /// Call this after user finishes all onboarding screens
  Future<void> setHasSeenOnboarding(bool value) async {
    await _prefs?.setBool(_hasSeenOnboardingKey, value);
  }
  
  /// Check if user is logged in
  bool get isLoggedIn {
    return _prefs?.getBool(_isLoggedInKey) ?? false;
  }
  
  /// Set login state
  Future<void> setIsLoggedIn(bool value) async {
    await _prefs?.setBool(_isLoggedInKey, value);
  }
  
  /// Clear all preferences (useful for logout)
  Future<void> clear() async {
    await _prefs?.clear();
  }
}
