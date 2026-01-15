import 'package:flutter/material.dart';
import '../../data/models/kelas_model.dart';
import '../../data/services/supabase_service.dart';

class KelasProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<KelasModel> _kelasList = [];
  List<Map<String, dynamic>> _allGuruList = []; // Simpan master data guru
  List<Map<String, dynamic>> _guruOptions = []; // Untuk dropdown

  bool _isLoading = false;
  String? _errorMessage;

  List<KelasModel> get kelasList => _kelasList;
  List<Map<String, dynamic>> get guruOptions => _guruOptions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 1. Fetch Data
  Future<void> fetchAllKelas() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Ambil data Kelas
      final kelasData = await _supabaseService.fetchAllKelasData();
      _kelasList = kelasData.map((e) => KelasModel.fromJson(e)).toList();

      // Ambil data Guru Master
      final guruData = await _supabaseService.getAllGuru();
      _allGuruList = List<Map<String, dynamic>>.from(guruData);

      // Mapping Nama Wali (Logic lama tetap dipakai untuk display list)
      for (var kelas in _kelasList) {
        if (kelas.waliKelasId != null) {
          final guru = _allGuruList.firstWhere(
            (g) => g['profile_id'] == kelas.waliKelasId,
            orElse: () => {},
          );
          if (guru.isNotEmpty) {
            kelas.namaWali = guru['nama_lengkap'] ?? guru['nama'];
          }
        }
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ LOGIC BARU: Get Options Guru yang Tersedia
  // Parameter currentWaliId diperlukan saat Edit, agar wali kelas saat ini tetap muncul di list
  List<Map<String, dynamic>> getAvailableGuruOptions(String? currentWaliId) {
    // 1. Kumpulkan semua ID wali kelas yang SUDAH TERPAKAI di kelas lain
    final usedWaliIds = _kelasList
        .where((k) => k.waliKelasId != null && k.waliKelasId != currentWaliId)
        .map((k) => k.waliKelasId)
        .toSet(); // Pakai Set biar unik dan cepat

    // 2. Filter Guru: Hanya yang punya profile_id DAN tidak ada di list terpakai
    return _allGuruList
        .where((g) {
          final String? pId = g['profile_id'];
          if (pId == null) return false;

          // Tampilkan jika: TIDAK terpakai ATAU ini adalah wali kelas yang sedang diedit
          return !usedWaliIds.contains(pId);
        })
        .map((g) {
          return {
            'profile_id': g['profile_id'],
            'nama': g['nama_lengkap'] ?? g['nama'] ?? 'Guru',
          };
        })
        .toList();
  }

  // CREATE / UPDATE
  Future<bool> saveKelas({
    String? id,
    required String namaKelas,
    required int tingkat,
    String? waliKelasId, // profile_id
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (id == null) {
        // Create
        await _supabaseService.createKelas(
          namaKelas: namaKelas,
          tingkat: tingkat,
          waliKelasId: waliKelasId,
        );
      } else {
        // Update
        await _supabaseService.updateKelas(
          id: id,
          namaKelas: namaKelas,
          tingkat: tingkat,
          waliKelasId: waliKelasId,
        );
      }

      await fetchAllKelas(); // Refresh data
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // DELETE
  Future<bool> deleteKelas(String id) async {
    try {
      await _supabaseService.deleteKelas(id);
      _kelasList.removeWhere((item) => item.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage =
          'Gagal menghapus kelas. Pastikan tidak ada siswa terkait.';
      notifyListeners();
      return false;
    }
  }
}
