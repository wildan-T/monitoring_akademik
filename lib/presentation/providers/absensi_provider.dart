//C:\Users\MSITHIN\monitoring_akademik\lib\presentation\providers\absensi_provider.dart
import 'package:flutter/foundation.dart';
import '../../data/models/absensi_model.dart';
import '../../data/services/supabase_service.dart';
import '../../domain/entities/absensi_entity.dart';

class AbsensiProvider with ChangeNotifier {
  final SupabaseService _supabaseService;

  AbsensiProvider(this._supabaseService);

  List<AbsensiModel> _absensiList = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, int> _statistikKehadiran = {};

  // Getters
  List<AbsensiModel> get absensiList => _absensiList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, int> get statistikKehadiran => _statistikKehadiran;

  // ✅ ADD: Helper to convert String to AbsensiStatus
  AbsensiStatus _stringToStatus(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return AbsensiStatus.hadir;
      case 'izin':
        return AbsensiStatus.izin;
      case 'sakit':
        return AbsensiStatus.sakit;
      case 'alpha':
        return AbsensiStatus.alpha;
      default:
        return AbsensiStatus.hadir;
    }
  }

  // ✅ ADD: Helper to convert AbsensiStatus to String
  String _statusToString(AbsensiStatus status) {
    return status.toString().split('.').last;
  }

  // Fetch absensi by kelas and mapel
  Future<void> fetchAbsensiByKelasMapel({
    required String kelasId,
    required String mataPelajaranId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      var query = _supabaseService.supabase
          .from('absensi')
          .select('''
            *,
            siswa:siswa_id(*),
            kelas:kelas_id(*),
            mata_pelajaran:mata_pelajaran_id(*),
            guru:guru_id(*)
          ''')
          .eq('kelas_id', kelasId)
          .eq('mata_pelajaran_id', mataPelajaranId);

      if (startDate != null) {
        query = query.gte('tanggal', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('tanggal', endDate.toIso8601String());
      }

      final response = await query.order('tanggal', ascending: false);

      _absensiList = (response as List)
          .map((json) => AbsensiModel.fromJson(json))
          .toList();

      _calculateStatistik();
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('✅ Fetched ${_absensiList.length} absensi records');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('❌ Error fetching absensi: $e');
      }
    }
  }

  // Get absensi for specific siswa
  Future<List<AbsensiModel>> getAbsensiSiswa(String siswaId) async {
    try {
      final response = await _supabaseService.supabase
          .from('absensi')
          .select('''
            *,
            siswa:siswa_id(*),
            kelas:kelas_id(*),
            mata_pelajaran:mata_pelajaran_id(*),
            guru:guru_id(*)
          ''')
          .eq('siswa_id', siswaId)
          .order('tanggal', ascending: false);

      return (response as List)
          .map((json) => AbsensiModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting absensi siswa: $e');
      }
      return [];
    }
  }

  // Get rekap absensi siswa - FIXED
// ✅ FIXED: Use helper method for comparison
Future<Map<String, int>> getRekapAbsensiSiswa(String siswaId) async {
  try {
    final absensiList = await getAbsensiSiswa(siswaId);

    final Map<String, int> rekap = {
      'hadir': absensiList.where((a) => a.status == AbsensiStatus.hadir).length,
      'izin': absensiList.where((a) => a.status == AbsensiStatus.izin).length,
      'sakit': absensiList.where((a) => a.status == AbsensiStatus.sakit).length,
      'alpha': absensiList.where((a) => a.status == AbsensiStatus.alpha).length,
    };

    return rekap;
  } catch (e) {
    if (kDebugMode) {
      print('❌ Error getting rekap absensi: $e');
    }
    return {'hadir': 0, 'izin': 0, 'sakit': 0, 'alpha': 0};
  }
}

  // Get persentase kehadiran
  Future<double> getPersentaseKehadiran(String siswaId) async {
    try {
      final rekap = await getRekapAbsensiSiswa(siswaId);
      final total = rekap.values.reduce((a, b) => a + b);

      if (total == 0) return 0;

      final hadir = rekap['hadir'] ?? 0;
      return (hadir / total * 100);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error calculating persentase: $e');
      }
      return 0;
    }
  }

  // Save absensi (batch) - FIXED
  Future<bool> saveAbsensi({
    required String kelasId,
    required String mataPelajaranId,
    required String guruId,
    required int pertemuan,
    required DateTime tanggal,
    required Map<String, String> absensiData, // siswaId -> status (String)
  }) async {
    try {
      final List<Map<String, dynamic>> records = [];

      for (var entry in absensiData.entries) {
        records.add({
          'siswa_id': entry.key,
          'kelas_id': kelasId,
          'mata_pelajaran_id': mataPelajaranId,
          'guru_id': guruId,
          'tanggal': tanggal.toIso8601String(),
          'pertemuan': pertemuan,
          'status': entry.value, // String langsung disimpan ke DB
          'keterangan': '',
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      await _supabaseService.supabase.from('absensi').insert(records);

      if (kDebugMode) {
        print('✅ Saved ${records.length} absensi records');
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();

      if (kDebugMode) {
        print('❌ Error saving absensi: $e');
      }

      return false;
    }
  }

  // Update absensi - FIXED
// ✅ FIXED: Accept String status parameter
Future<bool> updateAbsensi(
  String absensiId,
  String status, // ✅ Accept String directly
  String keterangan,
) async {
  try {
    await _supabaseService.supabase
        .from('absensi')
        .update({
          'status': status, // ✅ Save as String to DB
          'keterangan': keterangan,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', absensiId);

    if (kDebugMode) {
      print('✅ Updated absensi: $absensiId');
    }

    return true;
  } catch (e) {
    _errorMessage = e.toString();
    notifyListeners();

    if (kDebugMode) {
      print('❌ Error updating absensi: $e');
    }

    return false;
  }
}

  // Calculate statistik - FIXED  
// ✅ FIXED: Direct enum comparison (no conversion needed)
void _calculateStatistik() {
  _statistikKehadiran = {
    'hadir': _absensiList.where((a) => a.status == AbsensiStatus.hadir).length,
    'izin': _absensiList.where((a) => a.status == AbsensiStatus.izin).length,
    'sakit': _absensiList.where((a) => a.status == AbsensiStatus.sakit).length,
    'alpha': _absensiList.where((a) => a.status == AbsensiStatus.alpha).length,
  };

  if (kDebugMode) {
    print('📊 Statistik: $_statistikKehadiran');
  }
}
}
