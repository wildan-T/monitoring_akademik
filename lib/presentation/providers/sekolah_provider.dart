//C:\Users\MSITHIN\monitoring_akademik\lib\presentation\providers\sekolah_provider.dart
import 'package:flutter/material.dart';
import 'package:monitoring_akademik/core/utils/error_handler.dart';
import '../../data/models/sekolah_model.dart';

class SekolahProvider with ChangeNotifier {
  // Data sekolah (hanya 1 record)
  SekolahModel _sekolahData = SekolahModel(
    id: '1',
    namaSekolah: 'SMPN 20 KOTA TANGERANG',
    npsn: '20606758',
    alamat: 'Jl. Nuri Raya Perumnas I RT.001 RW.003',
    kota: 'Kota Tangerang',
    provinsi: 'Banten',
    kodePos: '15138',
    noTelp: '021-5522727',
    email: 'smpn20tangerang@gmail.com',
    website: 'www.smpn20tangerang.sch.id',
    namaKepalaSekolah: 'Dr. H. Budi Santoso, M.Pd',
    nipKepalaSekolah: '196505151990031005',
    akreditasi: 'A',
    statusSekolah: 'Negeri',
    logoPath: null, // Belum ada logo
    createdAt: DateTime.now(),
  );

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  SekolahModel get sekolahData => _sekolahData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Update data sekolah
  Future<bool> updateSekolah(SekolahModel updatedData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulasi delay network
      await Future.delayed(const Duration(seconds: 1));

      _sekolahData = updatedData.copyWith(
        id: _sekolahData.id, // ID tetap sama
        updatedAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage =
          'Gagal mengupdate data sekolah: ${ErrorHandler.interpret(e)}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update logo sekolah
  Future<bool> updateLogo(String logoPath) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulasi delay upload
      await Future.delayed(const Duration(seconds: 2));

      _sekolahData = _sekolahData.copyWith(
        logoPath: logoPath,
        updatedAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengupload logo: ${ErrorHandler.interpret(e)}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Remove logo sekolah
  Future<bool> removeLogo() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulasi delay
      await Future.delayed(const Duration(seconds: 1));

      _sekolahData = _sekolahData.copyWith(
        logoPath: null,
        updatedAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus logo: ${ErrorHandler.interpret(e)}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
