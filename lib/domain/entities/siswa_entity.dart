//C:\Users\MSITHIN\monitoring_akademik\lib\domain\entities\siswa_entity.dart

class SiswaEntity {
  final String id;
  final String nis;
  final String nisn;
  final String nama;
  final String jenisKelamin;
  final String tempatLahir;
  final DateTime tanggalLahir;
  final String agama;
  final String alamat;
  final String namaAyah;
  final String namaIbu;
  final String noTelpOrangTua;
  final String? kelasId;        // ✅ ADDED
  final String kelas;
  final String tahunMasuk;
  final String status;
  final String? waliMuridId;    // ✅ ADDED
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SiswaEntity({
    required this.id,
    required this.nis,
    required this.nisn,
    required this.nama,
    required this.jenisKelamin,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.agama,
    required this.alamat,
    required this.namaAyah,
    required this.namaIbu,
    required this.noTelpOrangTua,
    this.kelasId,               // ✅ ADDED
    required this.kelas,
    required this.tahunMasuk,
    required this.status,
    this.waliMuridId,           // ✅ ADDED
    this.createdAt,
    this.updatedAt,
  });
}