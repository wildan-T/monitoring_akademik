//C:\Users\MSITHIN\monitoring_akademik\lib\presentation\providers\mata_pelajaran_provider.dart
import 'package:flutter/foundation.dart';
import '../../data/services/supabase_service.dart';

class MataPelajaranProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  List<Map<String, dynamic>> _mataPelajaranList = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get mataPelajaranList => _mataPelajaranList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ✅ Get all mata pelajaran
  Future<void> fetchAllMataPelajaran() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _mataPelajaranList = await _supabaseService.getAllMataPelajaran();
      print('✅ Fetched ${_mataPelajaranList.length} mata pelajaran');
    } catch (e) {
      _error = e.toString();
      print('❌ Error fetchAllMataPelajaran: $e');
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