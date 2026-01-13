import 'package:flutter/material.dart';
import '../../data/models/kelas_model.dart';
import '../../data/services/supabase_service.dart';

class KelasProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<KelasModel> _kelasList = [];
  List<Map<String, dynamic>> _guruOptions = []; // Untuk dropdown

  bool _isLoading = false;
  String? _errorMessage;

  List<KelasModel> get kelasList => _kelasList;
  List<Map<String, dynamic>> get guruOptions => _guruOptions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // READ Data
  Future<void> fetchAllKelas() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Ambil data Kelas
      final kelasData = await _supabaseService.fetchAllKelasData();
      final List<KelasModel> tempKelas = kelasData
          .map((e) => KelasModel.fromJson(e))
          .toList();

      // 2. Ambil data Guru (untuk mendapatkan profile_id dan nama_lengkap)
      final guruData = await _supabaseService.getAllGuru();

      // Siapkan opsi dropdown (Hanya guru yang punya profile_id)
      _guruOptions = guruData.where((g) => g['profile_id'] != null).map((g) {
        return {
          'profile_id': g['profile_id'],
          'nama': g['nama_lengkap'] ?? g['nama'] ?? 'Guru',
        };
      }).toList();

      // 3. Mapping Nama Wali Kelas
      // Mencocokkan kelas.waliKelasId (profile_id) dengan guru.profile_id
      for (var kelas in tempKelas) {
        if (kelas.waliKelasId != null) {
          final guru = _guruOptions.firstWhere(
            (g) => g['profile_id'] == kelas.waliKelasId,
            orElse: () => {},
          );

          if (guru.isNotEmpty) {
            kelas.namaWali = guru['nama'];
          }
        }
      }

      _kelasList = tempKelas;
    } catch (e) {
      print('Error fetching kelas: $e');
      _errorMessage = 'Gagal memuat data kelas';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
