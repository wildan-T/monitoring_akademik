//C:\Users\MSITHIN\monitoring_akademik\lib\data\models\sekolah_model.dart
import '../../domain/entities/sekolah_entity.dart';

class SekolahModel extends SekolahEntity {
  SekolahModel({
    required super.id,
    required super.namaSekolah,
    required super.npsn,
    required super.alamat,
    required super.kota,
    required super.provinsi,
    required super.kodePos,
    required super.noTelp,
    required super.email,
    required super.website,
    required super.namaKepalaSekolah,
    required super.nipKepalaSekolah,
    required super.akreditasi,
    required super.statusSekolah,
    super.logoPath,
    super.createdAt,
    super.updatedAt,
  });

  // From JSON (untuk parsing dari API/Database)
  factory SekolahModel.fromJson(Map<String, dynamic> json) {
    return SekolahModel(
      id: json['id']?.toString() ?? '1',
      namaSekolah: json['nama_sekolah']?.toString() ?? '',
      npsn: json['npsn']?.toString() ?? '',
      alamat: json['alamat']?.toString() ?? '',
      kota: json['kota']?.toString() ?? '',
      provinsi: json['provinsi']?.toString() ?? '',
      kodePos: json['kode_pos']?.toString() ?? '',
      noTelp: json['no_telp']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
      namaKepalaSekolah: json['nama_kepala_sekolah']?.toString() ?? '',
      nipKepalaSekolah: json['nip_kepala_sekolah']?.toString() ?? '',
      akreditasi: json['akreditasi']?.toString() ?? '',
      statusSekolah: json['status_sekolah']?.toString() ?? '',
      logoPath: json['logo_path']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // To JSON (untuk kirim ke API/Database)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_sekolah': namaSekolah,
      'npsn': npsn,
      'alamat': alamat,
      'kota': kota,
      'provinsi': provinsi,
      'kode_pos': kodePos,
      'no_telp': noTelp,
      'email': email,
      'website': website,
      'nama_kepala_sekolah': namaKepalaSekolah,
      'nip_kepala_sekolah': nipKepalaSekolah,
      'akreditasi': akreditasi,
      'status_sekolah': statusSekolah,
      'logo_path': logoPath,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Copy with (untuk update data)
  SekolahModel copyWith({
    String? id,
    String? namaSekolah,
    String? npsn,
    String? alamat,
    String? kota,
    String? provinsi,
    String? kodePos,
    String? noTelp,
    String? email,
    String? website,
    String? namaKepalaSekolah,
    String? nipKepalaSekolah,
    String? akreditasi,
    String? statusSekolah,
    String? logoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SekolahModel(
      id: id ?? this.id,
      namaSekolah: namaSekolah ?? this.namaSekolah,
      npsn: npsn ?? this.npsn,
      alamat: alamat ?? this.alamat,
      kota: kota ?? this.kota,
      provinsi: provinsi ?? this.provinsi,
      kodePos: kodePos ?? this.kodePos,
      noTelp: noTelp ?? this.noTelp,
      email: email ?? this.email,
      website: website ?? this.website,
      namaKepalaSekolah: namaKepalaSekolah ?? this.namaKepalaSekolah,
      nipKepalaSekolah: nipKepalaSekolah ?? this.nipKepalaSekolah,
      akreditasi: akreditasi ?? this.akreditasi,
      statusSekolah: statusSekolah ?? this.statusSekolah,
      logoPath: logoPath ?? this.logoPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}