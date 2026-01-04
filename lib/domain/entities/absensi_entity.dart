//C:\Users\MSITHIN\monitoring_akademik\lib\domain\entities\absensi_entity.dart

class AbsensiEntity {
  final String id;
  final String siswaId;
  final String namaSiswa;
  final String guruId;
  final String namaGuru;
  final String kelasId;
  final String kelas;
  final String mataPelajaranId;
  final String mataPelajaran;
  final DateTime tanggal;
  final int pertemuan;
  final AbsensiStatus status;
  final String? keterangan;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AbsensiEntity({
    required this.id,
    required this.siswaId,
    required this.namaSiswa,
    required this.guruId,
    required this.namaGuru,
    required this.kelasId,
    required this.kelas,
    required this.mataPelajaranId,
    required this.mataPelajaran,
    required this.tanggal,
    required this.pertemuan,
    required this.status,
    this.keterangan,
    required this.createdAt,
    this.updatedAt,
  });
}

// Enum untuk status absensi
enum AbsensiStatus {
  hadir,
  izin,
  sakit,
  alpha,
}