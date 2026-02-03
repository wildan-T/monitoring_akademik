// lib/data/models/siswa_model.dart

class SiswaModel {
  final String id;
  final String nisn;
  final String? nis;
  final String nama;
  final String? jenisKelamin;
  final String? kelasId;

  // Data Join (Read Only)
  final String? namaKelas;
  final String? waliMuridId;
  final String? namaWali;
  final String? noHpWali;
  final String? emailWali;

  // Data Detail Siswa
  final String? tempatLahir;
  final DateTime? tanggalLahir;
  final String? agama;
  final String? alamat;
  final String? namaAyah;
  final String? namaIbu;
  final String status;

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

  factory SiswaModel.fromJson(Map<String, dynamic> json) {
    // 1. Parsing Data Kelas (Nested Object)
    String? _namaKelas;
    if (json['kelas'] != null && json['kelas'] is Map) {
      _namaKelas = json['kelas']['nama_kelas'];
    }

    // 2. Parsing Data Wali (Nested Object)
    String? _namaWali;
    String? _noHpWali;
    String? _emailWali;

    if (json['wali_murid'] != null && json['wali_murid'] is Map) {
      final wali = json['wali_murid'];
      _namaWali = wali['nama_lengkap'];

      // Coba ambil kontak langsung dari tabel wali_murid (jika ada kolomnya)
      _noHpWali = wali['no_telepon'];
      _emailWali = wali['email'];

      // OPSI: Jika kontak ada di tabel 'profiles' yang di-join via wali_murid
      // Pastikan query Supabase: .select('..., wali_murid(*, profiles(email, no_telepon))')
      if (wali['profiles'] != null && wali['profiles'] is Map) {
        _noHpWali = wali['profiles']['no_telepon'] ?? _noHpWali;
        _emailWali = wali['profiles']['email'] ?? _emailWali;
      }
    }

    return SiswaModel(
      id: json['id']?.toString() ?? '',
      nisn: json['nisn']?.toString() ?? '',
      nis: json['nis']?.toString(),
      nama: json['nama_lengkap'] ?? 'Tanpa Nama',
      jenisKelamin: json['jenis_kelamin']?.toString(),
      kelasId: json['kelas_id']?.toString(),

      // Assign data hasil parsing join
      namaKelas: _namaKelas ?? '-',
      waliMuridId: json['wali_murid_id']?.toString(),
      namaWali: _namaWali ?? '-',
      noHpWali: _noHpWali ?? '-',
      emailWali: _emailWali ?? '-',

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
