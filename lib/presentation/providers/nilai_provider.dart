//C:\Users\MSITHIN\monitoring_akademik\lib\presentation\providers\nilai_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/models/nilai_model.dart';
import '../../data/services/supabase_service.dart';

class NilaiProvider with ChangeNotifier {
  final SupabaseService _supabaseService;
  
  List<NilaiModel> _nilaiList = [];
  List<Map<String, dynamic>> _kelasMapelList = [];
  bool _isLoading = false;
  String _errorMessage = '';

  NilaiProvider(this._supabaseService);

  // Getters
  List<NilaiModel> get nilaiList => _nilaiList;
  List<Map<String, dynamic>> get kelasMapelList => _kelasMapelList;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // ========== GET KELAS-MAPEL BY GURU ID ==========
  Future<List<Map<String, dynamic>>> getKelasMapelByGuruId(String guruId) async {
    try {
      final response = await _supabaseService.supabase
          .from('guru_kelas_mapel')
          .select('''
            *,
            kelas:kelas_id(id, nama_kelas, tingkat),
            mata_pelajaran:mata_pelajaran_id(id, nama_mata_pelajaran, kode)
          ''')
          .eq('guru_id', guruId);

      _kelasMapelList = List<Map<String, dynamic>>.from(response as List);
      
      if (kDebugMode) {
        print('✅ Fetched ${_kelasMapelList.length} kelas-mapel for guru');
      }

      notifyListeners();
      return _kelasMapelList;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching kelas-mapel: $e');
      }
      return [];
    }
  }

  // ========== FETCH NILAI BY KELAS ==========
  Future<void> fetchNilaiByKelas(String kelasId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _supabaseService.supabase
          .from('nilai')
          .select('''
            *,
            siswa:siswa_id(id, nama, nis, nisn),
            kelas:kelas_id(id, nama_kelas, tingkat),
            mata_pelajaran:mata_pelajaran_id(id, nama_mata_pelajaran, kode),
            guru:guru_id(id, nama)
          ''')
          .eq('kelas_id', kelasId)
          .order('created_at', ascending: false);

      _nilaiList = (response as List)
          .map((json) => NilaiModel.fromJson(json))
          .toList();

      if (kDebugMode) {
        print('✅ Fetched ${_nilaiList.length} nilai for kelas');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching nilai: $e');
      }
      _errorMessage = 'Gagal memuat data nilai: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== FETCH NILAI BY KELAS & MAPEL ==========
  Future<void> fetchNilaiByKelasAndMapel({
    required String kelasId,
    required String mataPelajaranId,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _supabaseService.supabase
          .from('nilai')
          .select('''
            *,
            siswa:siswa_id(id, nama, nis, nisn),
            kelas:kelas_id(id, nama_kelas, tingkat),
            mata_pelajaran:mata_pelajaran_id(id, nama_mata_pelajaran, kode),
            guru:guru_id(id, nama)
          ''')
          .eq('kelas_id', kelasId)
          .eq('mata_pelajaran_id', mataPelajaranId)
          .order('created_at', ascending: false);

      _nilaiList = (response as List)
          .map((json) => NilaiModel.fromJson(json))
          .toList();

      if (kDebugMode) {
        print('✅ Fetched ${_nilaiList.length} nilai for kelas & mapel');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching nilai: $e');
      }
      _errorMessage = 'Gagal memuat data nilai: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== GET ALL NILAI (for admin) ==========
  Future<void> getAllNilai() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _supabaseService.supabase
          .from('nilai')
          .select('''
            *,
            siswa:siswa_id(id, nama, nis, nisn),
            kelas:kelas_id(id, nama_kelas, tingkat),
            mata_pelajaran:mata_pelajaran_id(id, nama_mata_pelajaran, kode),
            guru:guru_id(id, nama)
          ''')
          .order('created_at', ascending: false);

      _nilaiList = (response as List)
          .map((json) => NilaiModel.fromJson(json))
          .toList();

      if (kDebugMode) {
        print('✅ Fetched ${_nilaiList.length} total nilai');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching all nilai: $e');
      }
      _errorMessage = 'Gagal memuat data nilai: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== GET NILAI BY SISWA ==========
  Future<List<NilaiModel>> getNilai(String siswaId) async {
    try {
      final response = await _supabaseService.supabase
          .from('nilai')
          .select('''
            *,
            kelas:kelas_id(id, nama_kelas),
            mata_pelajaran:mata_pelajaran_id(id, nama_mata_pelajaran, kode),
            guru:guru_id(id, nama)
          ''')
          .eq('siswa_id', siswaId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => NilaiModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching nilai for siswa: $e');
      }
      return [];
    }
  }

  // ========== SAVE NILAI (BATCH) ==========
  Future<bool> saveNilai({
    required String kelasId,
    required String mataPelajaranId,
    required String guruId,
    required Map<String, Map<String, dynamic>> nilaiData, // siswaId: {tugas1, tugas2, ...}
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final List<Map<String, dynamic>> nilaiRecords = [];

      for (var entry in nilaiData.entries) {
        final siswaId = entry.key;
        final nilai = entry.value;

        nilaiRecords.add({
          'siswa_id': siswaId,
          'kelas_id': kelasId,
          'mata_pelajaran_id': mataPelajaranId,
          'guru_id': guruId,
          'tugas_1': nilai['tugas_1'],
          'tugas_2': nilai['tugas_2'],
          'tugas_3': nilai['tugas_3'],
          'tugas_4': nilai['tugas_4'],
          'uh_1': nilai['uh_1'],
          'uh_2': nilai['uh_2'],
          'uts': nilai['uts'],
          'uas': nilai['uas'],
          'nilai_akhir': nilai['nilai_akhir'],
          'status': nilai['status'] ?? 'draft',
        });
      }

      await _supabaseService.supabase.from('nilai').insert(nilaiRecords);

      if (kDebugMode) {
        print('✅ Saved ${nilaiRecords.length} nilai records');
      }

      await fetchNilaiByKelasAndMapel(
        kelasId: kelasId,
        mataPelajaranId: mataPelajaranId,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving nilai: $e');
      }
      _errorMessage = 'Gagal menyimpan nilai: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ========== UPDATE NILAI ==========
  Future<bool> updateNilai(String nilaiId, Map<String, dynamic> updatedData) async {
    try {
      await _supabaseService.supabase
          .from('nilai')
          .update(updatedData)
          .eq('id', nilaiId);

      if (kDebugMode) {
        print('✅ Nilai updated successfully');
      }

      // Update local list
      final index = _nilaiList.indexWhere((n) => n.id == nilaiId);
      if (index != -1) {
        // Refresh from server to get latest data
        final response = await _supabaseService.supabase
            .from('nilai')
            .select('''
              *,
              siswa:siswa_id(id, nama, nis, nisn),
              kelas:kelas_id(id, nama_kelas, tingkat),
              mata_pelajaran:mata_pelajaran_id(id, nama_mata_pelajaran, kode),
              guru:guru_id(id, nama)
            ''')
            .eq('id', nilaiId)
            .single();

        _nilaiList[index] = NilaiModel.fromJson(response);
        notifyListeners();
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating nilai: $e');
      }
      return false;
    }
  }

  // ========== FINALISASI NILAI ==========
  Future<bool> finalisasiNilai({
    required String kelasId,
    required String mataPelajaranId,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _supabaseService.supabase
          .from('nilai')
          .update({'status': 'final'})
          .eq('kelas_id', kelasId)
          .eq('mata_pelajaran_id', mataPelajaranId);

      if (kDebugMode) {
        print('✅ Nilai finalized successfully');
      }

      await fetchNilaiByKelasAndMapel(
        kelasId: kelasId,
        mataPelajaranId: mataPelajaranId,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error finalizing nilai: $e');
      }
      _errorMessage = 'Gagal finalisasi nilai: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ========== DELETE NILAI ==========
  Future<bool> deleteNilai(String nilaiId) async {
    try {
      await _supabaseService.supabase
          .from('nilai')
          .delete()
          .eq('id', nilaiId);

      if (kDebugMode) {
        print('✅ Nilai deleted successfully');
      }

      _nilaiList.removeWhere((n) => n.id == nilaiId);
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting nilai: $e');
      }
      return false;
    }
  }
}