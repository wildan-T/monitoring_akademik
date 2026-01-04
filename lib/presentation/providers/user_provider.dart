//C:\Users\MSITHIN\monitoring_akademik\lib\presentation\providers\user_provider.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/services/supabase_service.dart';
import '../../../core/constants/app_constants.dart';
//import '../../core/constants/app_constants.dart';

class UserProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<UserEntity> _users = [];
  bool _isLoading = false;
  String? _error;
  String _selectedRole = 'all'; // ✅ ADDED: for filtering
  String _searchQuery = ''; // ✅ ADDED: for search

  List<UserEntity> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedRole => _selectedRole; // ✅ ADDED

  // ✅ ADDED: Get filtered users
  List<UserEntity> get filteredUsers {
    var result = _users;

    // Filter by role
    if (_selectedRole != 'all') {
      result = result.where((u) => u.role == _selectedRole).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      result = result.where((u) {
        return u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            u.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            u.username.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return result;
  }

  // ✅ Get all users
  Future<void> fetchUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📦 Fetching users from Supabase...');

      final userModels = await _supabaseService.getAllUsers();
      _users = userModels;

      print('✅ Fetched ${_users.length} users');
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('❌ Error fetchUsers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ ADDED: Search users
  void searchUser(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ✅ ADDED: Filter by role
  void filterByRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  // ✅ ADDED: Get total by role
  int getTotalByRole(String role) {
    if (role == 'all') return _users.length;
    return _users.where((u) => u.role == role).length;
  }

  // ✅ Create user
  Future<bool> createUser({
    required String username,
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('👤 Creating user: $username');

      final newUser = await _supabaseService.createUser(
        username: username,
        name: name,
        email: email,
        password: password,
        role: role,
        phone: phone,
      );

      if (newUser != null) {
        _users.add(newUser);
        print('✅ User created successfully');
        _error = null;
        notifyListeners();
        return true;
      }

      throw Exception('Create user returned null');
    } catch (e) {
      _error = e.toString();
      print('❌ Error createUser: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Update user
  Future<bool> updateUser({
    required String userId,
    String? name,
    String? email,
    String? phone,
    String? role,
    bool? isActive,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔄 Updating user: $userId');

      final success = await _supabaseService.updateUser(
        userId: userId,
        name: name,
        email: email,
        phone: phone,
        role: role,
        isActive: isActive,
      );

      if (success) {
        await fetchUsers();
        print('✅ User updated successfully');
        return true;
      }

      throw Exception('Update user failed');
    } catch (e) {
      _error = e.toString();
      print('❌ Error updateUser: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Delete user
  Future<bool> deleteUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🗑️ Deleting user: $userId');

      final success = await _supabaseService.deleteUser(userId);

      if (success) {
        _users.removeWhere((user) => user.id == userId);
        print('✅ User deleted successfully');
        notifyListeners();
        return true;
      }

      throw Exception('Delete user failed');
    } catch (e) {
      _error = e.toString();
      print('❌ Error deleteUser: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
