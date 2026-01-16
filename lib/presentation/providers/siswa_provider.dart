// lib/presentation/providers/siswa_provider.dart

import 'package:flutter/material.dart';
import '../../data/models/siswa_model.dart';
import '../../data/services/supabase_service.dart';

class SiswaProvider extends ChangeNotifier {
  final SupabaseService _service = SupabaseService();

  List<SiswaModel> _siswaList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SiswaModel> get siswaList => _siswaList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch Data
  Future<void> fetchAllSiswa() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _service.getAllSiswa();

      _siswaList = data.map((e) {
        // Ambil data wali hasil injeksi manual di Service
        final waliData = e['wali_data'] as Map<String, dynamic>?;
        return SiswaModel.fromJson(e, waliData: waliData);
      }).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Fetch Siswa by Kelas ID (Untuk fitur Guru lihat siswa ajar)
  Future<void> fetchSiswaByKelas(String kelasId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _service.getSiswaByKelasId(kelasId);

      if (data.isNotEmpty) {
        print("📦 DATA MENTAH SISWA PERTAMA:");
        print(data[0]);
        // Perhatikan output di console: apakah ada key 'wali_murid' di dalam 'profiles'?
      }
      _siswaList = data.map((e) {
        // --- 1. AMBIL NAMA KELAS ---
        final kelasObj = e['kelas'];
        final namaKelas = (kelasObj is Map) ? kelasObj['nama_kelas'] : '-';

        // --- 2. AMBIL DATA WALI ---
        final profileObj = e['profiles'];

        String namaWali = '-';
        String noHp = '-';
        String email = '-';

        if (profileObj != null && profileObj is Map) {
          // Ambil No HP & Email dari Profiles
          noHp = profileObj['no_telepon'] ?? '-';
          email = profileObj['email'] ?? '-';

          // Ambil Nama Wali (Reverse Lookup ke tabel wali_murid)
          // Hasilnya adalah List karena relasi One-to-Many
          final listWali = profileObj['wali_murid'];

          if (listWali is List && listWali.isNotEmpty) {
            // Jika List, ambil item pertama
            namaWali = listWali[0]['nama_lengkap']?.toString() ?? '-';
          } else if (listWali is Map) {
            // Jaga-jaga jika Supabase mengembalikan Map (Single)
            namaWali = listWali['nama_lengkap']?.toString() ?? '-';
          }
        }

        // --- 3. BUNGKUS KE DALAM MAP UNTUK MODEL ---
        // Kita masukkan data yang sudah diekstrak agar Model mudah membacanya
        final Map<String, dynamic> injectedData = {
          'nama_kelas': namaKelas,
          'nama_lengkap': namaWali, // Nama Wali
          'no_telepon': noHp, // HP Wali
          'email': email, // Email Wali
        };

        // Masukkan ke parameter 'waliData' dan 'kelasData'
        return SiswaModel.fromJson(
          e,
          waliData: injectedData,
          kelasData: injectedData,
        );
      }).toList();
    } catch (e) {
      print('❌ Error fetchSiswaByKelas: $e');
      _errorMessage = e.toString();
      _siswaList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tambah Data
  Future<bool> addSiswa(Map<String, dynamic> rawData) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.createSiswaAndWali(rawData);
      await fetchAllSiswa(); // Refresh
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update Data
  Future<bool> updateSiswa(String id, SiswaModel siswa) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.updateSiswa(id, siswa.toJson());
      await fetchAllSiswa();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cari Siswa
  List<SiswaModel> searchSiswa(String query) {
    if (query.isEmpty) return _siswaList;
    final lower = query.toLowerCase();
    return _siswaList
        .where(
          (s) => s.nama.toLowerCase().contains(lower) || s.nisn.contains(lower),
        )
        .toList();
  }
}
