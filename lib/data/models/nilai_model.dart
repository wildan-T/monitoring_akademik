//C:\Users\MSITHIN\monitoring_akademik\lib\data\models\nilai_model.dart
import '../../domain/entities/nilai_entity.dart';

class NilaiModel extends NilaiEntity {
  NilaiModel({
    required super.id,
    required super.siswaId,
    required super.namaSiswa,
    required super.guruId,
    required super.kelasId,
    required super.kelas,
    required super.mataPelajaran,
    super.tugas1,
    super.tugas2,
    super.tugas3,
    super.tugas4,
    super.uh1,
    super.uh2,
    super.uts,
    super.uas,
    super.nilaiAkhir,
    super.nilaiPraktik,
    super.nilaiSikap,
    super.isFinalized,
    super.finalizedAt,
    super.finalizedBy,
    super.createdAt,
    super.updatedAt,
    // required super.nilaiTugas,
    // required super.nilaiUH,
    // required super.nilaiUTS,
    // required super.nilaiUAS,
  });
  // ✅ Helper: Get siswa object for compatibility
  Map<String, dynamic> get siswa => {
    'id': siswaId,
    'nama': namaSiswa,
    'nis': '',
  };
  // ✅ Calculate nilai akhir automatically
  double? get calculatedNilaiAkhir {
    final tugasList =
        [tugas1, tugas2, tugas3, tugas4].where((t) => t != null).toList();
    final rataTugas =
        tugasList.isNotEmpty
            ? tugasList.reduce((a, b) => a! + b!)! / tugasList.length
            : null;
    final uhList = [uh1, uh2].where((u) => u != null).toList();
    final rataUH =
        uhList.isNotEmpty
            ? uhList.reduce((a, b) => a! + b!)! / uhList.length
            : null;

    if (rataTugas == null || rataUH == null || uts == null || uas == null) {
      return null;
    }

    return (rataTugas! * 0.2) + (rataUH! * 0.2) + (uts! * 0.3) + (uas! * 0.3);
  }

  // ✅✅✅ COMPUTED GETTERS (TAMBAHAN BARU) ✅✅✅
  // Rata-rata Tugas (tugas1 + tugas2 + tugas3 + tugas4) / 4
  double? get nilaiTugas {
    final scores =
        [tugas1, tugas2, tugas3, tugas4]
            .where((s) => s != null)
            .map((s) => s!) // Pastikan non-null
            .toList();

    if (scores.isEmpty) return null;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  // ✅ FIX: Sama untuk UH
  double? get nilaiUH {
    final scores = [uh1, uh2].where((s) => s != null).map((s) => s!).toList();

    if (scores.isEmpty) return null;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  // Alias untuk UTS
  double? get nilaiUTS => uts;
  // Alias untuk UAS
  double? get nilaiUAS => uas;
  // Konversi nilai angka ke huruf
  String get nilaiHuruf {
    final nilai = nilaiAkhir ?? 0;
    if (nilai >= 90) return 'A';
    if (nilai >= 80) return 'B';
    if (nilai >= 70) return 'C';
    if (nilai >= 60) return 'D';
    return 'E';
  }

  // Predikat berdasarkan nilai
  String get predikat {
    final nilai = nilaiAkhir ?? 0;
    if (nilai >= 90) return 'Sangat Baik';
    if (nilai >= 80) return 'Baik';
    if (nilai >= 70) return 'Cukup';
    if (nilai >= 60) return 'Kurang';
    return 'Sangat Kurang';
  }

  // Status finalisasi
  String get status => isFinalized ? 'final' : 'draft';
  // From JSON
  factory NilaiModel.fromJson(Map<String, dynamic> json) {
    final siswaData = json['siswa'] is Map ? json['siswa'] : null;
    final kelasData = json['kelas'] is Map ? json['kelas'] : null;
    final mapelData =
        json['mata_pelajaran'] is Map ? json['mata_pelajaran'] : null;
    // Parsing nilai individual
    final t1 =
        json['tugas1'] != null
            ? double.tryParse(json['tugas1'].toString())
            : null;
    final t2 =
        json['tugas2'] != null
            ? double.tryParse(json['tugas2'].toString())
            : null;
    final t3 =
        json['tugas3'] != null
            ? double.tryParse(json['tugas3'].toString())
            : null;
    final t4 =
        json['tugas4'] != null
            ? double.tryParse(json['tugas4'].toString())
            : null;

    final u1 =
        json['uh1'] != null ? double.tryParse(json['uh1'].toString()) : null;
    final u2 =
        json['uh2'] != null ? double.tryParse(json['uh2'].toString()) : null;

    final utsVal =
        json['uts'] != null ? double.tryParse(json['uts'].toString()) : null;
    final uasVal =
        json['uas'] != null ? double.tryParse(json['uas'].toString()) : null;

    // ✅ Helper: Hitung rata-rata tugas
    double? calcNilaiTugas() {
      final list = [t1, t2, t3, t4].where((e) => e != null).toList();
      if (list.isEmpty) return null;
      return list.reduce((a, b) => a! + b!)! / list.length;
    }

    // ✅ Helper: Hitung rata-rata UH
    double? calcNilaiUH() {
      final list = [u1, u2].where((e) => e != null).toList();
      if (list.isEmpty) return null;
      return list.reduce((a, b) => a! + b!)! / list.length;
    }

    return NilaiModel(
      id: json['id']?.toString() ?? '',
      siswaId: json['siswa_id']?.toString() ?? '',
      namaSiswa:
          siswaData?['nama']?.toString() ??
          json['nama_siswa']?.toString() ??
          'Unknown',
      guruId: json['guru_id']?.toString() ?? '',
      kelasId: json['kelas_id']?.toString() ?? '',
      kelas:
          kelasData?['nama']?.toString() ??
          json['kelas']?.toString() ??
          'Unknown',
      mataPelajaran:
          mapelData?['nama']?.toString() ??
          json['mata_pelajaran']?.toString() ??
          'Unknown',

      tugas1:
          json['tugas1'] != null
              ? double.tryParse(json['tugas1'].toString())
              : null,
      tugas2:
          json['tugas2'] != null
              ? double.tryParse(json['tugas2'].toString())
              : null,
      tugas3:
          json['tugas3'] != null
              ? double.tryParse(json['tugas3'].toString())
              : null,
      tugas4:
          json['tugas4'] != null
              ? double.tryParse(json['tugas4'].toString())
              : null,
      uh1: json['uh1'] != null ? double.tryParse(json['uh1'].toString()) : null,
      uh2: json['uh2'] != null ? double.tryParse(json['uh2'].toString()) : null,
      uts: json['uts'] != null ? double.tryParse(json['uts'].toString()) : null,
      uas: json['uas'] != null ? double.tryParse(json['uas'].toString()) : null,

      nilaiAkhir:
          json['nilai_akhir'] != null
              ? double.tryParse(json['nilai_akhir'].toString())
              : null,
      nilaiPraktik:
          json['nilai_praktik'] != null
              ? double.tryParse(json['nilai_praktik'].toString())
              : null,
      nilaiSikap: json['nilai_sikap']?.toString(),
      isFinalized: json['is_finalized'] == true || json['is_finalized'] == 1,
      finalizedAt:
          json['finalized_at'] != null
              ? DateTime.parse(json['finalized_at'].toString())
              : null,
      finalizedBy: json['finalized_by']?.toString(),
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'].toString())
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'].toString())
              : null,
      // nilaiTugas: calcNilaiTugas(),
      // nilaiUH: calcNilaiUH(),
      // nilaiUTS: utsVal,
      // nilaiUAS: uasVal,
    );
  }
  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'siswa_id': siswaId,
      'nama_siswa': namaSiswa,
      'guru_id': guruId,
      'kelas_id': kelasId,
      'kelas': kelas,
      'mata_pelajaran': mataPelajaran,
      'tugas1': tugas1,
      'tugas2': tugas2,
      'tugas3': tugas3,
      'tugas4': tugas4,
      'uh1': uh1,
      'uh2': uh2,
      'uts': uts,
      'uas': uas,
      'nilai_akhir': nilaiAkhir ?? calculatedNilaiAkhir,
      'nilai_praktik': nilaiPraktik,
      'nilai_sikap': nilaiSikap,
      'is_finalized': isFinalized,
      'finalized_at': finalizedAt?.toIso8601String(),
      'finalized_by': finalizedBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Copy with
  NilaiModel copyWith({
    String? id,
    String? siswaId,
    String? namaSiswa,
    String? guruId,
    String? kelasId,
    String? kelas,
    String? mataPelajaran,
    double? tugas1,
    double? tugas2,
    double? tugas3,
    double? tugas4,
    double? uh1,
    double? uh2,
    double? uts,
    double? uas,
    double? nilaiAkhir,
    double? nilaiPraktik,
    String? nilaiSikap,
    bool? isFinalized,
    DateTime? finalizedAt,
    String? finalizedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    // double? nilaiTugas,
    // double? nilaiUH,
    // double? nilaiUTS,
    // double? nilaiUAS,
  }) {
    return NilaiModel(
      id: id ?? this.id,
      siswaId: siswaId ?? this.siswaId,
      namaSiswa: namaSiswa ?? this.namaSiswa,
      guruId: guruId ?? this.guruId,
      kelasId: kelasId ?? this.kelasId,
      kelas: kelas ?? this.kelas,
      mataPelajaran: mataPelajaran ?? this.mataPelajaran,
      tugas1: tugas1 ?? this.tugas1,
      tugas2: tugas2 ?? this.tugas2,
      tugas3: tugas3 ?? this.tugas3,
      tugas4: tugas4 ?? this.tugas4,
      uh1: uh1 ?? this.uh1,
      uh2: uh2 ?? this.uh2,
      uts: uts ?? this.uts,
      uas: uas ?? this.uas,
      nilaiAkhir: nilaiAkhir ?? this.nilaiAkhir,
      nilaiPraktik: nilaiPraktik ?? this.nilaiPraktik,
      nilaiSikap: nilaiSikap ?? this.nilaiSikap,
      isFinalized: isFinalized ?? this.isFinalized,
      finalizedAt: finalizedAt ?? this.finalizedAt,
      finalizedBy: finalizedBy ?? this.finalizedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // nilaiTugas: nilaiTugas ?? this.nilaiTugas,
      // nilaiUH: nilaiUH ?? this.nilaiUH,
      // nilaiUTS: nilaiUTS ?? this.nilaiUTS,
      // nilaiUAS: nilaiUAS ?? this.nilaiUAS,
    );
  }
}
