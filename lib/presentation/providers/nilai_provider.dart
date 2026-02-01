import 'package:flutter/material.dart';
import 'package:monitoring_akademik/core/utils/error_handler.dart';
import '../../data/models/nilai_model.dart';
import '../../data/models/siswa_model.dart'; // Pastikan ada
import '../../data/services/supabase_service.dart';

class NilaiInputItem {
  final SiswaModel siswa;
  final NilaiModel? nilai; // Null jika belum dinilai

  NilaiInputItem({required this.siswa, this.nilai});
}

class NilaiProvider extends ChangeNotifier {
  final SupabaseService _service = SupabaseService();

  List<NilaiInputItem> _inputList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<NilaiInputItem> get inputList => _inputList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch Gabungan Siswa & Nilai
  Future<void> fetchInputList({
    required String kelasId,
    required String mapelId,
    required String tahunId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Ambil Semua Siswa di Kelas itu
      // (Gunakan fungsi getSiswaByKelasId yg sudah dibuat sebelumnya)
      final rawSiswa = await _service.getSiswaByKelasId(kelasId);
      final listSiswa = rawSiswa.map((e) => SiswaModel.fromJson(e)).toList();

      // 2. Ambil Data Nilai yang sudah ada di DB
      final listNilai = await _service.getNilaiByFilter(
        kelasId: kelasId,
        mapelId: mapelId,
        tahunId: tahunId,
      );

      // 3. Gabungkan (Merge)
      _inputList = listSiswa.map((siswa) {
        // Cari apakah siswa ini sudah punya nilai
        final nilaiFound = listNilai.firstWhere(
          (n) => n.siswaId == siswa.id,
          orElse: () => NilaiModel(
            id: '', // Dummy ID
            siswaId: siswa.id,
            mataPelajaranId: mapelId,
            tahunPelajaranId: tahunId,
            kelasId: kelasId,
            guruId: '', // Akan diisi saat save
          ),
        );

        // Jika ID kosong, berarti belum ada di DB -> kirim null atau object kosong
        return NilaiInputItem(
          siswa: siswa,
          nilai: nilaiFound.id.isEmpty ? null : nilaiFound,
        );
      }).toList();
    } catch (e) {
      _errorMessage = ErrorHandler.interpret(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Simpan Satu Nilai
  Future<bool> submitNilai(NilaiModel nilai) async {
    try {
      await _service.saveNilai(nilai);

      // Update state lokal agar UI langsung berubah tanpa refresh
      final index = _inputList.indexWhere(
        (item) => item.siswa.id == nilai.siswaId,
      );
      if (index != -1) {
        _inputList[index] = NilaiInputItem(
          siswa: _inputList[index].siswa,
          nilai: nilai, // Nilai terbaru
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.interpret(e);
      notifyListeners();
      return false;
    }
  }
}
