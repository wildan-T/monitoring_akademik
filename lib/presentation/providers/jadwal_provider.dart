import 'package:flutter/material.dart';
import '../../data/models/jadwal_model.dart';
import '../../data/services/supabase_service.dart';

class JadwalProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<JadwalModel> _jadwalList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<JadwalModel> get jadwalList => _jadwalList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // READ
  Future<void> fetchJadwal({
    required String tahunPelajaranId,
    String? kelasId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _supabaseService.fetchJadwalPelajaran(
        tahunPelajaranId: tahunPelajaranId,
        kelasId: kelasId,
      );

      _jadwalList = data.map((e) => JadwalModel.fromJson(e)).toList();

      // Sorting Hari Manual (Senin -> Minggu)
      final hariOrder = {
        'Senin': 1,
        'Selasa': 2,
        'Rabu': 3,
        'Kamis': 4,
        'Jumat': 5,
        'Sabtu': 6,
      };
      _jadwalList.sort((a, b) {
        int orderA = hariOrder[a.hari] ?? 7;
        int orderB = hariOrder[b.hari] ?? 7;
        return orderA.compareTo(orderB);
      });
    } catch (e) {
      _errorMessage = 'Gagal memuat jadwal: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // CREATE
  Future<bool> addJadwal({
    required String guruId,
    required String kelasId,
    required String mapelId,
    required String tahunPelajaranId,
    required String hari,
    required String jamMulai,
    required String jamSelesai,
  }) async {
    try {
      await _supabaseService.createJadwal(
        guruId: guruId,
        kelasId: kelasId,
        mapelId: mapelId,
        tahunPelajaranId: tahunPelajaranId,
        hari: hari,
        jamMulai: jamMulai,
        jamSelesai: jamSelesai,
      );

      // Refresh list jika filter kelas aktif
      await fetchJadwal(tahunPelajaranId: tahunPelajaranId, kelasId: kelasId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // DELETE
  Future<bool> deleteJadwal(String id) async {
    try {
      await _supabaseService.deleteJadwal(id);
      _jadwalList.removeWhere((item) => item.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus jadwal';
      notifyListeners();
      return false;
    }
  }
}
