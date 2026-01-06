//C:\Users\MSITHIN\monitoring_akademik\lib\presentation\providers\guru_provider.dart
import 'package:flutter/foundation.dart';
import '../../data/services/supabase_service.dart';
import '../../data/models/guru_model.dart';
import '../../domain/entities/guru_entity.dart';

class GuruProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<GuruEntity> _guruList = [];
  GuruEntity? _currentGuru;
  bool _isLoading = false;
  String? _errorMessage;

  List<GuruEntity> get guruList => _guruList;
  GuruEntity? get currentGuru => _currentGuru;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ✅ FETCH ALL GURU - FIXED
  Future<void> fetchAllGuru() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('📚 Fetching all guru...');
      final data = await _supabaseService.getAllGuru();

      // ✅ FIX: Proper casting via GuruModel
      _guruList =
          data
              .map((json) => GuruModel.fromJson(json))
              .cast<GuruEntity>()
              .toList();
      print('✅ Fetched ${_guruList.length} guru');
    } catch (e) {
      print('❌ Error fetching guru: $e');
      _errorMessage = e.toString();
      _guruList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ FETCH GURU BY PROFILE ID - FIXED
  Future<void> fetchGuruByProfileId(String profileId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('📚 Fetching guru by profile ID: $profileId');
      final data = await _supabaseService.getGuruByProfileId(profileId);

      if (data != null) {
        // ✅ FIX: Create GuruModel then cast to Entity
        final guru = GuruModel.fromJson(data);
        _guruList = [guru];
        _currentGuru = guru;
        print('✅ Current guru loaded: ${guru.nama}');
        print('   - Is Wali Kelas: ${guru.isWaliKelas}');
        print('   - Wali Kelas: ${guru.waliKelas}');
      } else {
        _currentGuru = null;
        print('⚠️ No guru found for profile ID: $profileId');
      }
    } catch (e) {
      print('❌ Error fetching guru by profile ID: $e');
      _errorMessage = e.toString();
      _currentGuru = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ GET GURU BY ID (SYNC - FROM CACHE)
  GuruEntity? getGuruById(String id) {
    try {
      return _guruList.firstWhere((guru) => guru.id == id);
    } catch (e) {
      print('⚠️ Guru not found in cache: $id');
      return null;
    }
  }

  // ✅ UPDATE GURU PROFILE
  Future<bool> updateGuruProfile({
    required String guruId,
    required String nuptk,
    required String nama,
    String? nip,
    String? email,
    String? noTelp,
    String? alamat,
    String? pendidikanTerakhir,
    String? jenisKelamin,
    String? tempatLahir,
    DateTime? tanggalLahir,
    String? agama,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('💾 Updating guru profile: $guruId');

      final success = await _supabaseService.updateGuruProfile(
        guruId: guruId,
        nuptk: nuptk,
        nama: nama,
        nip: nip,
        email: email,
        noTelp: noTelp,
        alamat: alamat,
        pendidikanTerakhir: pendidikanTerakhir,
      );

      if (success) {
        print('✅ Guru profile updated successfully');
        final updatedData = await _supabaseService.getGuruById(guruId);
        if (updatedData != null) {
          _currentGuru = GuruModel.fromJson(updatedData);

          final index = _guruList.indexWhere((g) => g.id == guruId);
          if (index != -1) {
            _guruList[index] = _currentGuru!;
          }
        }
      }

      return success;
    } catch (e) {
      print('❌ Error updating guru profile: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ SET WALI KELAS
  Future<bool> setWaliKelas({
    required String guruId,
    required String kelasId,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('👨‍🏫 Setting wali kelas: $guruId -> $kelasId');

      final success = await _supabaseService.setWaliKelas(
        guruId: guruId,
        kelasId: kelasId,
      );

      if (success) {
        print('✅ Wali kelas set successfully');
        await fetchAllGuru();
      }

      return success;
    } catch (e) {
      print('❌ Error setting wali kelas: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ REMOVE WALI KELAS
  Future<bool> removeWaliKelas(String guruId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('❌ Removing wali kelas: $guruId');

      final success = await _supabaseService.removeWaliKelas(guruId);

      if (success) {
        print('✅ Wali kelas removed successfully');
        await fetchAllGuru();
      }

      return success;
    } catch (e) {
      print('❌ Error removing wali kelas: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ CLEAR DATA
  void clearData() {
    _guruList = [];
    _currentGuru = null;
    _errorMessage = null;
    notifyListeners();
  }

  // ✅ SEARCH GURU
  List<GuruEntity> searchGuru(String query) {
    if (query.isEmpty) return _guruList;

    final lowerQuery = query.toLowerCase();
    return _guruList.where((guru) {
      return guru.nama.toLowerCase().contains(lowerQuery) ||
          guru.nuptk.toLowerCase().contains(lowerQuery) ||
          (guru.nip?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  // ✅ FILTER BY WALI KELAS
  List<GuruEntity> get waliKelasList {
    return _guruList.where((guru) => guru.isWaliKelas).toList();
  }

  // ✅ GET AVAILABLE GURU (not wali kelas)
  List<GuruEntity> get availableGuruList {
    return _guruList.where((guru) => !guru.isWaliKelas).toList();
  }
}
