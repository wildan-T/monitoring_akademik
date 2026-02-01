// lib/presentation/providers/tahun_pelajaran_provider.dart
import 'package:flutter/material.dart';
import 'package:monitoring_akademik/core/utils/error_handler.dart';
import '../../data/models/tahun_pelajaran_model.dart';
import '../../data/services/supabase_service.dart';

class TahunPelajaranProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<TahunPelajaranModel> _tahunList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TahunPelajaranModel> get tahunList => _tahunList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // READ
  Future<void> fetchTahunPelajaran() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _supabaseService.fetchAllTahunPelajaran();
      _tahunList = data.map((e) => TahunPelajaranModel.fromJson(e)).toList();
    } catch (e) {
      _errorMessage = 'Gagal memuat data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // CREATE / UPDATE
  Future<bool> saveTahunPelajaran({
    String? id,
    required String tahun,
    required int semester,
    required bool isActive,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (id == null) {
        await _supabaseService.createTahunPelajaran(
          tahun: tahun,
          semester: semester,
          isActive: isActive,
          tanggalMulai: tanggalMulai,
          tanggalSelesai: tanggalSelesai,
        );
      } else {
        await _supabaseService.updateTahunPelajaran(
          id: id,
          tahun: tahun,
          semester: semester,
          isActive: isActive,
          tanggalMulai: tanggalMulai,
          tanggalSelesai: tanggalSelesai,
        );
      }

      await fetchTahunPelajaran();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.interpret(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // DELETE
  Future<bool> deleteTahunPelajaran(String id) async {
    try {
      await _supabaseService.deleteTahunPelajaran(id);
      _tahunList.removeWhere((item) => item.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage =
          'Gagal menghapus data. Mungkin sudah terpakai di data lain.';
      notifyListeners();
      return false;
    }
  }
}
