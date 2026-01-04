//C:\Users\MSITHIN\monitoring_akademik\lib\core\constants\app_constants.dart
class AppConstants {
  // App Info
  static const String appName = 'Monitoring Akademik';
  static const String schoolName = 'SMPN 20 Kota Tangerang';
  static const String appVersion = '1.0.0';

  // ✅ FIX: Roles sesuai database Supabase
  static const String roleAdmin = 'super_admin';  // ✅ FIXED: 'admin' → 'super_admin'
  static const String roleGuru = 'guru';
  static const String roleWali = 'wali_murid';     // ✅ ADDED: roleWali constant
  
  // Alias untuk backward compatibility
  static const String roleWaliMurid = roleWali;

  // Storage Keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyUserRole = 'user_role';
}