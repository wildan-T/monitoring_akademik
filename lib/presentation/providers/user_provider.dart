//C:\Users\MSITHIN\monitoring_akademik\lib\presentation\providers\user_provider.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/services/supabase_service.dart';
import '../../../core/constants/app_constants.dart';
//import '../../core/constants/app_constants.dart';

class UserProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<Map<String, dynamic>> _userList = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get userList => _userList;
  bool get isLoading => _isLoading;

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _userList = await _supabaseService.getAllUsers();
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser(
    String uid, {
    String? email,
    String? pass,
    Map<String, dynamic>? meta,
  }) async {
    try {
      await _supabaseService.updateUserAccount(
        userId: uid,
        email: email,
        password: pass,
        metadata: meta,
      );
      await fetchUsers();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUser(String uid) async {
    try {
      await _supabaseService.deleteUserPermanent(uid);
      _userList.removeWhere((u) => u['id'] == uid);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
