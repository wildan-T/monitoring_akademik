//C:\Users\MSITHIN\monitoring_akademik\lib\domain\entities\nilai_entity.dart

class NilaiEntity {
  final String id;
  final String siswaId;
  final String namaSiswa;      // ✅ ADDED
  final String guruId;
  final String kelasId;
  final String kelas;          // ✅ ADDED
  final String mataPelajaran;
  
  // ✅ CHANGED: Individual component scores
  final double? tugas1;
  final double? tugas2;
  final double? tugas3;
  final double? tugas4;
  final double? uh1;
  final double? uh2;
  final double? uts;
  final double? uas;
  final double? nilaiAkhir;    // ✅ ADDED
  
  final double? nilaiPraktik;
  final String? nilaiSikap;
  final bool isFinalized;
  final DateTime? finalizedAt;
  final String? finalizedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NilaiEntity({
    required this.id,
    required this.siswaId,
    required this.namaSiswa,
    required this.guruId,
    required this.kelasId,
    required this.kelas,
    required this.mataPelajaran,
    this.tugas1,
    this.tugas2,
    this.tugas3,
    this.tugas4,
    this.uh1,
    this.uh2,
    this.uts,
    this.uas,
    this.nilaiAkhir,
    this.nilaiPraktik,
    this.nilaiSikap,
    this.isFinalized = false,
    this.finalizedAt,
    this.finalizedBy,
    this.createdAt,
    this.updatedAt,
  });
}