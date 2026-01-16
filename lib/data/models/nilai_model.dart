// lib/data/models/nilai_model.dart

class NilaiModel {
  final String id;
  final String siswaId;
  final String mataPelajaranId;
  final String tahunPelajaranId;
  final String kelasId;
  final String guruId;

  // Nilai Komponen
  final double? nilaiTugas;
  final double? nilaiUh;
  final double? nilaiUts;
  final double? nilaiUas;
  final double? nilaiPraktik;
  final double? nilaiAkhir;

  final String? nilaiSikap; // A, B, C, D
  final bool isFinalized;

  NilaiModel({
    required this.id,
    required this.siswaId,
    required this.mataPelajaranId,
    required this.tahunPelajaranId,
    required this.kelasId,
    required this.guruId,
    this.nilaiTugas,
    this.nilaiUh,
    this.nilaiUts,
    this.nilaiUas,
    this.nilaiPraktik,
    this.nilaiAkhir,
    this.nilaiSikap,
    this.isFinalized = false,
  });

  factory NilaiModel.fromJson(Map<String, dynamic> json) {
    return NilaiModel(
      id: json['id'] ?? '',
      siswaId: json['siswa_id'] ?? '',
      mataPelajaranId: json['mata_pelajaran_id'] ?? '',
      tahunPelajaranId: json['tahun_pelajaran_id'] ?? '',
      kelasId: json['kelas_id'] ?? '',
      guruId: json['guru_id'] ?? '',

      nilaiTugas: json['nilai_tugas'] != null
          ? (json['nilai_tugas'] as num).toDouble()
          : 0.0,
      nilaiUh: json['nilai_uh'] != null
          ? (json['nilai_uh'] as num).toDouble()
          : 0.0,
      nilaiUts: json['nilai_uts'] != null
          ? (json['nilai_uts'] as num).toDouble()
          : 0.0,
      nilaiUas: json['nilai_uas'] != null
          ? (json['nilai_uas'] as num).toDouble()
          : 0.0,
      nilaiPraktik: json['nilai_praktik'] != null
          ? (json['nilai_praktik'] as num).toDouble()
          : 0.0,
      nilaiAkhir: json['nilai_akhir'] != null
          ? (json['nilai_akhir'] as num).toDouble()
          : 0.0,

      nilaiSikap: json['nilai_sikap'],
      isFinalized: json['is_finalized'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'siswa_id': siswaId,
      'mata_pelajaran_id': mataPelajaranId,
      'tahun_pelajaran_id': tahunPelajaranId,
      'kelas_id': kelasId,
      'guru_id': guruId,
      'nilai_tugas': nilaiTugas,
      'nilai_uh': nilaiUh,
      'nilai_uts': nilaiUts,
      'nilai_uas': nilaiUas,
      'nilai_praktik': nilaiPraktik,
      'nilai_akhir': nilaiAkhir,

      'nilai_sikap': nilaiSikap,
      'is_finalized': isFinalized,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
