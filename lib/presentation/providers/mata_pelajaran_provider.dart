// lib/presentation/providers/mata_pelajaran_provider.dart
import 'package:flutter/material.dart';
import 'package:monitoring_akademik/core/utils/error_handler.dart';
import '../../data/models/mata_pelajaran_model.dart';
import '../../data/services/supabase_service.dart';

class MataPelajaranProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<MataPelajaranModel> _mapelList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MataPelajaranModel> get mapelList => _mapelList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // READ
  Future<void> fetchMataPelajaran() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _supabaseService.fetchAllMataPelajaran();
      _mapelList = data.map((e) => MataPelajaranModel.fromJson(e)).toList();
    } catch (e) {
      _errorMessage = 'Gagal memuat data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // CREATE / UPDATE
  Future<bool> saveMataPelajaran({
    String? id,
    required String kodeMapel,
    required String namaMapel,
    String? kategori,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (id == null) {
        // Create
        await _supabaseService.createMataPelajaran(
          kodeMapel: kodeMapel,
          namaMapel: namaMapel,
          kategori: kategori,
        );
      } else {
        // Update
        await _supabaseService.updateMataPelajaran(
          id: id,
          kodeMapel: kodeMapel,
          namaMapel: namaMapel,
          kategori: kategori,
        );
      }

      await fetchMataPelajaran(); // Refresh list
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.interpret(e);
      if (e.toString().contains('duplicate key')) {
        _errorMessage = 'Kode Mapel "$kodeMapel" sudah ada.';
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // DELETE
  Future<bool> deleteMataPelajaran(String id) async {
    try {
      await _supabaseService.deleteMataPelajaran(id);
      _mapelList.removeWhere((item) => item.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage =
          'Gagal menghapus data. Mungkin sedang digunakan di jadwal/nilai.';
      notifyListeners();
      return false;
    }
  }
}
