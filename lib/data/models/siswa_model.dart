//C:\Users\MSITHIN\monitoring_akademik\lib\data\models\siswa_model.dart
import '../../domain/entities/siswa_entity.dart';


class SiswaModel extends SiswaEntity {
  SiswaModel({
    required super.id,
    required super.nis,
    required super.nisn,
    required super.nama,
    required super.jenisKelamin,
    required super.tempatLahir,
    required super.tanggalLahir,
    required super.agama,
    required super.alamat,
    required super.namaAyah,
    required super.namaIbu,
    required super.noTelpOrangTua,
    super.kelasId,        // ✅ ADDED - for database FK
    required super.kelas, // Display name
    required super.tahunMasuk,
    required super.status,
    super.waliMuridId,    // ✅ ADDED - for relationship
    super.createdAt,
    super.updatedAt,
  });

  // From JSON (untuk parsing dari API/Supabase)
  factory SiswaModel.fromJson(Map<String, dynamic> json) {
    // Handle nested kelas object OR flat structure
    final kelasData = json['kelas'] is Map ? json['kelas'] : null;
    final waliData = json['wali_murid'] is Map ? json['wali_murid'] : null;

    return SiswaModel(
      id: json['id']?.toString() ?? '',
      nis: json['nis']?.toString() ?? '',
      nisn: json['nisn']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      jenisKelamin: json['jenis_kelamin']?.toString() ?? '',
      tempatLahir: json['tempat_lahir']?.toString() ?? '',
      tanggalLahir: json['tanggal_lahir'] != null
          ? DateTime.parse(json['tanggal_lahir'].toString())
          : DateTime.now(),
      agama: json['agama']?.toString() ?? '',
      alamat: json['alamat']?.toString() ?? '',
      namaAyah: json['nama_ayah']?.toString() ?? '',
      namaIbu: json['nama_ibu']?.toString() ?? '',
      noTelpOrangTua: json['no_telp_orang_tua']?.toString() ?? '',
      kelasId: json['kelas_id']?.toString(), // ✅ ADDED
      kelas: kelasData?['nama']?.toString() ?? json['kelas']?.toString() ?? '',
      tahunMasuk: json['tahun_masuk']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Aktif',
      waliMuridId: json['wali_murid_id']?.toString(), // ✅ ADDED
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
    );
  }

  // To JSON (untuk kirim ke API/Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nis': nis,
      'nisn': nisn,
      'nama': nama,
      'jenis_kelamin': jenisKelamin,
      'tempat_lahir': tempatLahir,
      'tanggal_lahir': tanggalLahir.toIso8601String(),
      'agama': agama,
      'alamat': alamat,
      'nama_ayah': namaAyah,
      'nama_ibu': namaIbu,
      'no_telp_orang_tua': noTelpOrangTua,
      'kelas_id': kelasId,           // ✅ ADDED
      'kelas': kelas,
      'tahun_masuk': tahunMasuk,
      'status': status,
      'wali_murid_id': waliMuridId,  // ✅ ADDED
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Copy with (untuk update data)
  SiswaModel copyWith({
    String? id,
    String? nis,
    String? nisn,
    String? nama,
    String? jenisKelamin,
    String? tempatLahir,
    DateTime? tanggalLahir,
    String? agama,
    String? alamat,
    String? namaAyah,
    String? namaIbu,
    String? noTelpOrangTua,
    String? kelasId,
    String? kelas,
    String? tahunMasuk,
    String? status,
    String? waliMuridId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SiswaModel(
      id: id ?? this.id,
      nis: nis ?? this.nis,
      nisn: nisn ?? this.nisn,
      nama: nama ?? this.nama,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      tempatLahir: tempatLahir ?? this.tempatLahir,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      agama: agama ?? this.agama,
      alamat: alamat ?? this.alamat,
      namaAyah: namaAyah ?? this.namaAyah,
      namaIbu: namaIbu ?? this.namaIbu,
      noTelpOrangTua: noTelpOrangTua ?? this.noTelpOrangTua,
      kelasId: kelasId ?? this.kelasId,
      kelas: kelas ?? this.kelas,
      tahunMasuk: tahunMasuk ?? this.tahunMasuk,
      status: status ?? this.status,
      waliMuridId: waliMuridId ?? this.waliMuridId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}