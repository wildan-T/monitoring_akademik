//C:\Users\MSITHIN\monitoring_akademik\lib\presentation\providers\auth_provider.dart
import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/services/supabase_service.dart';
import '../../core/constants/app_constants.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  // ✅ Check if user is guru with incomplete profile
  bool get needsProfileCompletion {
    if (_currentUser == null) return false;
    if (_currentUser!.role != AppConstants.roleGuru) return false;
    return !_currentUser!.isActive; // is_active = false means incomplete
  }

  // ✅ Auto-login on app start
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Cek apakah ada sesi login yang tersimpan (Auto-login)
      final session = _supabaseService.supabase.auth.currentSession;

      if (session != null) {
        // ✅ PERBAIKAN UTAMA DI SINI:
        // Jangan hanya percaya session, tapi AMBIL ULANG data user dari tabel profiles
        // untuk mendapatkan nama terbaru.
        final userDetail = await _supabaseService.getCurrentUser();

        if (userDetail != null) {
          _currentUser = userDetail;
        } else {
          // Jika sesi ada tapi data di tabel profiles tidak ditemukan (aneh), logout.
          await logout();
        }
      } else {
        _currentUser = null;
      }
    } catch (e) {
      print('❌ Error checkAuthStatus: $e');
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Login dengan email
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔐 Attempting login: $email');

      _currentUser = await _supabaseService.signInWithEmail(
        email: email,
        password: password,
      );

      if (_currentUser != null) {
        print('✅ Login berhasil!');
        print('📋 Email: ${_currentUser!.email}');
        print('📋 Role: ${_currentUser!.role}');
        print('📋 Is Active: ${_currentUser!.isActive}');

        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      throw Exception('Login gagal: User null');
    } catch (e) {
      print('❌ Error login: $e');
      _errorMessage = 'Login gagal: ${e.toString()}';
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ✅ Logout
  Future<void> logout() async {
    try {
      await _supabaseService.signOut();
      _currentUser = null;
      _errorMessage = null;
      notifyListeners();
      print('✅ Logout berhasil');
    } catch (e) {
      print('❌ Error logout: $e');
      _errorMessage = 'Logout gagal: ${e.toString()}';
      notifyListeners();
    }
  }

  // ✅ Refresh current user data
  Future<void> refreshUser() async {
    try {
      _currentUser = await _supabaseService.getCurrentUser();
      notifyListeners();
      print('✅ User data refreshed');
    } catch (e) {
      print('❌ Error refreshUser: $e');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
