//C:\Users\MSITHIN\monitoring_akademik\lib\presentation\providers\siswa_provider.dart
import 'package:flutter/foundation.dart';
import '../../data/models/siswa_model.dart';
import '../../data/services/supabase_service.dart';

class SiswaProvider with ChangeNotifier {
  final SupabaseService _supabaseService;

  SiswaProvider(this._supabaseService);

  List<SiswaModel> _siswaList = [];
  List<SiswaModel> _filteredSiswaList = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter states
  String? _filterKelas;
  String? _filterStatus;
  String _searchQuery = '';

  // Getters
  List<SiswaModel> get siswaList =>
      _filteredSiswaList.isEmpty &&
          _searchQuery.isEmpty &&
          _filterKelas == null &&
          _filterStatus == null
      ? _siswaList
      : _filteredSiswaList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get filterKelas => _filterKelas;
  String? get filterStatus => _filterStatus;

  // Fetch all siswa with joins
  Future<void> fetchAllSiswa() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabaseService.supabase
          .from('siswa')
          .select('''
            *,
            kelas:kelas_id(*),
            wali_murid:wali_murid_id(*)
          ''')
          .order('nama', ascending: true);

      _siswaList = (response as List)
          .map((json) => SiswaModel.fromJson(json))
          .toList();

      _applyFilters();
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('✅ Fetched ${_siswaList.length} siswa');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('❌ Error fetching siswa: $e');
      }
    }
  }

  // Get siswa by ID
  SiswaModel? getSiswaById(String siswaId) {
    try {
      return _siswaList.firstWhere((s) => s.id == siswaId);
    } catch (e) {
      return null;
    }
  }

  // Get siswa by kelas - FIXED
  List<SiswaModel> getSiswaByKelas(String kelasId) {
    // ✅ FIXED: Use kelasId instead of kelas?.id
    final filteredList = _siswaList.where((s) => s.kelasId == kelasId).toList();

    if (kDebugMode) {
      print('📚 Siswa in kelas $kelasId: ${filteredList.length}');
    }

    return filteredList;
  }

  // Get siswa by wali murid
  Future<List<SiswaModel>> getSiswaByWaliMuridId(String waliMuridId) async {
    try {
      final response = await _supabaseService.supabase
          .from('siswa')
          .select('''
            *,
            kelas:kelas_id(*),
            wali_murid:wali_murid_id(*)
          ''')
          .eq('wali_murid_id', waliMuridId);

      return (response as List)
          .map((json) => SiswaModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching siswa by wali murid: $e');
      }
      return [];
    }
  }

  // Search and filter methods
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();

    if (kDebugMode) {
      print('🔍 Search query: $_searchQuery');
    }
  }

  void setFilterKelas(String kelas) {
    _filterKelas = kelas;
    _applyFilters();
    notifyListeners();

    if (kDebugMode) {
      print('🎯 Filter kelas: $_filterKelas');
    }
  }

  void setFilterStatus(String status) {
    _filterStatus = status;
    _applyFilters();
    notifyListeners();

    if (kDebugMode) {
      print('📊 Filter status: $_filterStatus');
    }
  }

  void clearFilters() {
    _searchQuery = '';
    _filterKelas = null;
    _filterStatus = null;
    _applyFilters();
    notifyListeners();

    if (kDebugMode) {
      print('🧹 Filters cleared');
    }
  }

  // Apply filters - FIXED
  void _applyFilters() {
    _filteredSiswaList = _siswaList.where((siswa) {
      bool matchesSearch = true;
      bool matchesKelas = true;
      bool matchesStatus = true;

      if (_searchQuery.isNotEmpty) {
        matchesSearch =
            siswa.nama.toLowerCase().contains(_searchQuery) ||
            siswa.nisn.toLowerCase().contains(_searchQuery) ||
            siswa.nis.toLowerCase().contains(_searchQuery);
      }

      if (_filterKelas != null) {
        // ✅ FIXED: Use kelas (display name) for comparison
        matchesKelas = siswa.kelas == _filterKelas;
      }

      if (_filterStatus != null) {
        matchesStatus = siswa.status == _filterStatus;
      }

      return matchesSearch && matchesKelas && matchesStatus;
    }).toList();

    if (kDebugMode) {
      print(
        '📋 Filtered: ${_filteredSiswaList.length} / ${_siswaList.length} siswa',
      );
    }
  }

  // CRUD operations
  Future<bool> createSiswa(SiswaModel siswa) async {
    try {
      await _supabaseService.supabase.from('siswa').insert(siswa.toJson());

      await fetchAllSiswa();

      if (kDebugMode) {
        print('✅ Siswa created: ${siswa.nama}');
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();

      if (kDebugMode) {
        print('❌ Error creating siswa: $e');
      }

      return false;
    }
  }

  Future<bool> updateSiswa(String siswaId, SiswaModel siswa) async {
    try {
      await _supabaseService.supabase
          .from('siswa')
          .update(siswa.toJson())
          .eq('id', siswaId);

      await fetchAllSiswa();

      if (kDebugMode) {
        print('✅ Siswa updated: ${siswa.nama}');
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();

      if (kDebugMode) {
        print('❌ Error updating siswa: $e');
      }

      return false;
    }
  }

  Future<bool> deleteSiswa(String siswaId) async {
    try {
      await _supabaseService.supabase.from('siswa').delete().eq('id', siswaId);

      await fetchAllSiswa();

      if (kDebugMode) {
        print('✅ Siswa deleted: $siswaId');
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();

      if (kDebugMode) {
        print('❌ Error deleting siswa: $e');
      }

      return false;
    }
  }

  // Helper - Get count by kelas - FIXED
  int getSiswaCountByKelas(String kelasId) {
  // ✅ FIXED: Use kelasId instead of kelas?.id
  return _siswaList.where((s) => s.kelasId == kelasId).length;
  }
}
