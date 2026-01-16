// lib/data/models/siswa_model.dart

class SiswaModel {
  final String id;
  final String nisn;
  final String? nis;
  final String nama;
  final String? jenisKelamin;
  final String? kelasId;
  final String? namaKelas; // Dari tabel kelas
  final String? waliMuridId; // Ini adalah Profile ID
  final String? namaWali; // Dari tabel wali_murid
  final String? noHpWali; // Dari tabel profiles
  final String? emailWali; // Dari tabel profiles
  final String? tempatLahir;
  final DateTime? tanggalLahir;
  final String? agama;
  final String? alamat;
  final String? namaAyah;
  final String? namaIbu;
  final String status; // aktif, lulus, dll

  SiswaModel({
    required this.id,
    required this.nisn,
    this.nis,
    required this.nama,
    this.jenisKelamin,
    this.kelasId,
    this.namaKelas,
    this.waliMuridId,
    this.namaWali,
    this.noHpWali,
    this.emailWali,
    this.tempatLahir,
    this.tanggalLahir,
    this.agama,
    this.alamat,
    this.namaAyah,
    this.namaIbu,
    this.status = 'aktif',
  });

  factory SiswaModel.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? kelasData,
    Map<String, dynamic>?
    waliData, // Data wali dari tabel wali_murid & profiles
  }) {
    // 1. Handle Join Kelas (jika dari query langsung) atau Injection
    final kelasObj = json['kelas'] is Map ? json['kelas'] : null;
    final finalNamaKelas =
        kelasData?['nama_kelas'] ?? kelasObj?['nama_kelas'] ?? '-';

    return SiswaModel(
      id: json['id']?.toString() ?? '',
      nisn: json['nisn']?.toString() ?? '',
      nis: json['nis']?.toString(),
      nama: json['nama_lengkap'] ?? 'Tanpa Nama',
      jenisKelamin: json['jenis_kelamin']?.toString(),

      kelasId: json['kelas_id']?.toString(),
      namaKelas: finalNamaKelas,

      waliMuridId: json['wali_murid_id']?.toString(),

      // Data Wali (Diambil dari Injection waliData)
      namaWali: waliData?['nama_lengkap'] ?? '-',
      noHpWali: waliData?['no_telepon'] ?? '-',
      emailWali: waliData?['email'] ?? '-',

      tempatLahir: json['tempat_lahir']?.toString(),
      tanggalLahir: json['tanggal_lahir'] != null
          ? DateTime.tryParse(json['tanggal_lahir'].toString())
          : null,
      agama: json['agama']?.toString(),
      alamat: json['alamat']?.toString(),
      namaAyah: json['nama_ayah']?.toString(),
      namaIbu: json['nama_ibu']?.toString(),
      status: json['status']?.toString() ?? 'aktif',
    );
  }

  // Untuk Update ke DB (Hanya field tabel siswa)
  Map<String, dynamic> toJson() {
    return {
      'nisn': nisn,
      'nis': nis,
      'nama_lengkap': nama,
      'jenis_kelamin': jenisKelamin,
      'kelas_id': kelasId,
      'tempat_lahir': tempatLahir,
      'tanggal_lahir': tanggalLahir?.toIso8601String(),
      'agama': agama,
      'alamat': alamat,
      'nama_ayah': namaAyah,
      'nama_ibu': namaIbu,
      'status': status,
    };
  }
}
