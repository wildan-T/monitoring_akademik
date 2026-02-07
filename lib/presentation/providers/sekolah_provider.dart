import 'dart:io';
import 'package:flutter/material.dart';
import 'package:monitoring_akademik/core/utils/error_handler.dart';
import '../../data/models/sekolah_model.dart';
import '../../data/services/supabase_service.dart';

class SekolahProvider with ChangeNotifier {
  final SupabaseService _service = SupabaseService();

  SekolahModel? _sekolahData;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  SekolahModel? get sekolahData => _sekolahData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// FETCH DATA SEKOLAH DARI SUPABASE
  Future<void> fetchSekolahData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Ambil data dari Service
      final data = await _service.getSekolah();

      if (data != null) {
        _sekolahData = SekolahModel.fromJson(data);
      } else {
        _errorMessage = "Data sekolah belum diatur.";
      }
    } catch (e) {
      _errorMessage = ErrorHandler.interpret(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// UPDATE DATA SEKOLAH
  Future<bool> updateSekolah(SekolahModel updatedData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Panggil Service untuk update ke DB
      // Kita kirim toJson() tapi hapus field yang tidak perlu diupdate manual (seperti created_at)
      await _service.updateSekolah(updatedData.toJson());

      // Update state lokal jika sukses
      _sekolahData = updatedData.copyWith(updatedAt: DateTime.now());

      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.interpret(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
