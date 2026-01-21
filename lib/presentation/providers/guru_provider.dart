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

  // ========================================
  // ⚡ CRUD OPERATIONS
  // ========================================

  /// Tambah Guru Baru
  Future<bool> addGuru(GuruModel guru) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabaseService.createGuru(guru);
      await fetchAllGuru(); // Refresh list setelah tambah
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menambah guru: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Edit Guru
  Future<bool> updateGuru(GuruModel guru) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabaseService.updateGuru(guru);
      await fetchGuruByProfileId(guru.id); // Refresh list setelah update
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengupdate guru: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Hapus Guru
  Future<bool> deleteGuru(String id) async {
    try {
      await _supabaseService.deleteGuru(id);

      // Hapus dari list lokal agar UI langsung update tanpa loading
      _guruList.removeWhere((item) => item.id == id);
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage =
          'Gagal menghapus guru. Data mungkin terkait dengan kelas/jadwal.';
      notifyListeners();
      return false;
    }
  }

  // Future<bool> addGuru(GuruModel guru) async {
  //   _isLoading = true;
  //   _errorMessage = null;
  //   notifyListeners();

  //   try {
  //     // Skenario: Password default adalah NIP atau NUPTK
  //     final defaultPassword = '123456';

  //     final success = await _supabaseService.createGuruAccount(
  //       guru: guru,
  //       password: defaultPassword, // 🔐 Password default
  //     );

  //     if (success) {
  //       // Refresh list lokal agar data terbaru muncul
  //       await fetchAllGuru();
  //       _errorMessage = null;
  //     } else {
  //       _errorMessage = 'Gagal menyimpan data ke database';
  //     }

  //     _isLoading = false;
  //     notifyListeners();
  //     return success;
  //   } catch (e) {
  //     print('❌ ERROR addGuru: $e');
  //     _errorMessage = e.toString();
  //     _isLoading = false;
  //     notifyListeners();
  //     return false;
  //   }
  // }

  // ✅ FETCH ALL GURU - FIXED
  Future<void> fetchAllGuru() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('📚 Fetching all guru...');
      final data = await _supabaseService.getAllGuru();

      // ✅ FIX: Proper casting via GuruModel
      _guruList = data
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
  // Future<void> fetchGuruByProfileId(String profileId) async {
  //   try {
  //     _isLoading = true;
  //     _errorMessage = null;
  //     notifyListeners();

  //     print('📚 Fetching guru by profile ID: $profileId');
  //     final data = await _supabaseService.getGuruByProfileId(profileId);

  //     if (data != null) {
  //       // ✅ FIX: Create GuruModel then cast to Entity
  //       final guru = GuruModel.fromJson(data);
  //       _guruList = [guru];
  //       _currentGuru = guru;
  //       print('✅ Current guru loaded: ${guru.nama}');
  //       print('   - Is Wali Kelas: ${guru.isWaliKelas}');
  //       print('   - Wali Kelas: ${guru.waliKelas}');
  //     } else {
  //       _currentGuru = null;
  //       print('⚠️ No guru found for profile ID: $profileId');
  //     }
  //   } catch (e) {
  //     print('❌ Error fetching guru by profile ID: $e');
  //     _errorMessage = e.toString();
  //     _currentGuru = null;
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }
  Future<void> fetchGuruByProfileId(String profileId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Panggil fungsi service yang sudah diupdate
      _currentGuru = await _supabaseService.getGuruByProfileId(profileId);

      // Debugging untuk memastikan
      if (_currentGuru != null) {
        print('👨‍🏫 Guru Loaded: ${_currentGuru!.nama}');
        print(
          '🏫 Status Wali Kelas: ${_currentGuru!.isWaliKelas ? "YA (${_currentGuru!.waliKelas})" : "TIDAK"}',
        );
      }
    } catch (e) {
      print('Error fetching guru: $e');
      _errorMessage = e.toString();
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

  // Future<bool> updateCurrentGuru(Map<String, dynamic> newData) async {
  //     if (_currentGuru == null) return false;
  //     _isLoading = true;
  //     notifyListeners();

  //     try {
  //       await _supabaseService.updateGuruProfile(_currentGuru!.id, newData);

  //       // Update data lokal di RAM agar UI langsung berubah tanpa reload
  //       // Kita copy object lama dan timpa dengan data baru
  //       _currentGuru = GuruModel(
  //         id: _currentGuru!.id,
  //         profileId: _currentGuru!.profileId,
  //         nip: _currentGuru!.nip, // NIP tidak berubah
  //         nama: newData['nama_lengkap'] ?? _currentGuru!.nama,
  //         jenisKelamin: newData['jenis_kelamin'] ?? _currentGuru!.jenisKelamin,
  //         tempatLahir: newData['tempat_lahir'] ?? _currentGuru!.tempatLahir,
  //         tanggalLahir: newData['tanggal_lahir'] ?? _currentGuru!.tanggalLahir,
  //         alamat: newData['alamat'] ?? _currentGuru!.alamat,
  //         pendidikanTerakhir: newData['pendidikan_terakhir'] ?? _currentGuru!.pendidikanTerakhir,
  //         statusKepegawaian: newData['status_kepegawaian'] ?? _currentGuru!.statusKepegawaian,
  //         agama: newData['agama'] ?? _currentGuru!.agama,
  //         nuptk: _currentGuru!.nuptk, // NUPTK tidak berubah
  //       );

  //       _isLoading = false;
  //       notifyListeners();
  //       return true;
  //     } catch (e) {
  //       _errorMessage = e.toString();
  //       _isLoading = false;
  //       notifyListeners();
  //       return false;
  //     }
  //   }

  // ✅ UPDATE GURU PROFILE
  Future<bool> updateGuruProfile({
    required String guruId,
    required String nuptk,
    required String nama,
    String? nip,
    String? alamat,
    String? pendidikanTerakhir,
    String? jenisKelamin,
    String? tempatLahir,
    DateTime? tanggalLahir,
    String? agama,
    String? statusKepegawaian,
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
        alamat: alamat,
        pendidikanTerakhir: pendidikanTerakhir,
        jenisKelamin: jenisKelamin,
        tempatLahir: tempatLahir,
        tanggalLahir: tanggalLahir,
        agama: agama,
        statusKepegawaian: statusKepegawaian,
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
