// lib/presentation/providers/siswa_provider.dart

import 'dart:io';

import 'package:excel/excel.dart' show Excel;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:monitoring_akademik/core/utils/error_handler.dart';
import 'package:monitoring_akademik/presentation/providers/kelas_provider.dart';
import 'package:provider/provider.dart';
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
        return SiswaModel.fromJson(e);
      }).toList();
    } catch (e) {
      _errorMessage = ErrorHandler.interpret(e);
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
        // 1. SIAPKAN MAP BERSIH
        final Map<String, dynamic> cleanData = Map.from(e);

        // 2. PARSING DATA WALI MURID (Sesuai Log)
        final waliObj =
            e['wali_murid']; // 👈 Ambil dari key 'wali_murid', BUKAN 'profiles'

        String namaWali = '-';
        String noHp = '-';
        String email = '-';

        if (waliObj != null && waliObj is Map) {
          // Ambil Nama langsung dari tabel wali_murid
          namaWali = waliObj['nama_lengkap'] ?? '-';

          // Ambil Kontak dari tabel profiles (Nested di dalam wali_murid)
          final profileObj = waliObj['profiles'];
          if (profileObj != null && profileObj is Map) {
            noHp = profileObj['no_telepon'] ?? '-';
            email = profileObj['email'] ?? '-';
          }
        }

        // 3. INJECT DATA YANG SUDAH DIPARSING AGAR MUDAH DIBACA MODEL
        // Kita buat struktur standar yang bisa dibaca oleh SiswaModel.fromJson
        cleanData['wali_murid'] = {
          'nama_lengkap': namaWali,
          'no_telepon': noHp,
          'email': email,
        };

        // 4. Pastikan Data Kelas Aman
        if (e['kelas'] != null) {
          cleanData['kelas'] = e['kelas'];
        }

        return SiswaModel.fromJson(cleanData);
      }).toList();
    } catch (e) {
      print('❌ Error fetchSiswaByKelas: $e');
      _errorMessage = ErrorHandler.interpret(e);
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
      _errorMessage = ErrorHandler.interpret(e);
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
      _errorMessage = ErrorHandler.interpret(e);
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

  // ==========================================
  // 📥 IMPORT EXCEL
  // ==========================================

  Future<Map<String, int>> importSiswaFromExcel(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    int successCount = 0;
    int failCount = 0;

    try {
      // 1. Pilih File
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        // Ambil bytes file (Support Web & Mobile)
        final bytes =
            result.files.single.bytes ??
            File(result.files.single.path!).readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);

        // 2. Siapkan Data Referensi (Kelas)
        // Kita butuh mengubah "7A" menjadi "UUID-123..."
        // Pastikan KelasProvider sudah ter-load atau fetch ulang
        final kelasProv = Provider.of<KelasProvider>(context, listen: false);
        if (kelasProv.kelasList.isEmpty) {
          await kelasProv.fetchAllKelas();
        }
        final listKelas = kelasProv.kelasList;

        // 3. Baca Sheet Pertama
        final sheet = excel.tables[excel.tables.keys.first];

        // Loop mulai dari baris ke-2 (index 1), karena index 0 adalah Header
        if (sheet != null) {
          // Menggunakan 'rows' untuk iterasi
          for (var i = 1; i < sheet.rows.length; i++) {
            final row = sheet.rows[i];

            try {
              // Pastikan baris tidak kosong
              if (row.isEmpty) continue;

              // Helper function ambil value cell aman
              String getVal(int index) {
                if (index >= row.length) return '';
                return row[index]?.value?.toString().trim() ?? '';
              }

              // Mapping Kolom (Sesuaikan dengan urutan Template Excel Anda)
              final nisn = getVal(0); // Col A
              final nis = getVal(1); // Col B
              final nama = getVal(2); // Col C
              final jk = getVal(3); // Col D
              final namaKelas = getVal(4); // Col E
              final namaWali = getVal(5); // Col F
              final noHpWali = getVal(6); // Col G

              if (nisn.isEmpty || nama.isEmpty)
                continue; // Skip data tidak lengkap

              // Cari ID Kelas berdasarkan Nama Kelas di Excel
              final kelasId = listKelas
                  .firstWhere(
                    (k) => k.namaKelas.toLowerCase() == namaKelas.toLowerCase(),
                    orElse: () =>
                        listKelas.first, // Fallback atau error handling
                  )
                  .id;

              // Siapkan Payload (Sama seperti Add Manual)
              final payload = {
                'nisn': nisn,
                'nis': nis,
                'nama_lengkap': nama,
                'jenis_kelamin': jk.toUpperCase(),
                'kelas_id': kelasId,
                'nama_wali': namaWali.isNotEmpty ? namaWali : 'Wali $nama',
                'jk_wali':
                    'L', // Default karena Excel simple biasanya ga ada JK Wali
                'no_telpon': noHpWali,
                'email': '$nisn@wali.sekolah.id', // Auto Generate Email
                'alamat': '-',
                'tempat_lahir': '-',
              };

              // Panggil fungsi Add Existing (Insert Auth + DB)
              final success = await addSiswa(payload);

              if (success) {
                successCount++;
              } else {
                failCount++;
                print('Gagal baris $i: $errorMessage');
              }

              // Opsional: Delay sedikit agar server tidak overload (Rate Limiting)
              await Future.delayed(const Duration(milliseconds: 200));
            } catch (e) {
              print('Error parsing row $i: $e');
              failCount++;
            }
          }
        }
      }
    } catch (e) {
      _errorMessage = 'Gagal import: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return {'success': successCount, 'fail': failCount};
  }
}
