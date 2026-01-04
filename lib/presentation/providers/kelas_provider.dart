//C:\Users\MSITHIN\monitoring_akademik\lib\presentation\providers\kelas_provider.dart
import 'package:flutter/foundation.dart';
import '../../data/services/supabase_service.dart';

class KelasProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  List<Map<String, dynamic>> _kelasList = [];
  List<Map<String, dynamic>> _availableKelasForWali = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get kelasList => _kelasList;
  List<Map<String, dynamic>> get availableKelasForWali => _availableKelasForWali;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ✅ Get all kelas
  Future<void> fetchAllKelas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _kelasList = await _supabaseService.getAllKelas();
      print('✅ Fetched ${_kelasList.length} kelas');
    } catch (e) {
      _error = e.toString();
      print('❌ Error fetchAllKelas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Get available kelas for wali kelas
  Future<void> fetchAvailableKelasForWali({String? currentGuruId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _availableKelasForWali = await _supabaseService.getAvailableKelasForWali(
        currentGuruId: currentGuruId,
      );
      print('✅ Fetched ${_availableKelasForWali.length} available kelas');
    } catch (e) {
      _error = e.toString();
      print('❌ Error fetchAvailableKelasForWali: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}