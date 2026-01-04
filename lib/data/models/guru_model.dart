//C:\Users\MSITHIN\monitoring_akademik\lib\data\models\guru_model.dart
import '../../domain/entities/guru_entity.dart';

class GuruModel extends GuruEntity {
  const GuruModel({
    required super.id,
    required super.nuptk,
    required super.nama,
    super.nip,
    super.email,
    super.noTelp,
    super.alamat,
    super.pendidikanTerakhir,
    super.isWaliKelas = false,
    super.waliKelas,
    super.createdAt,
    super.updatedAt,
  });

  // ✅ FROM JSON
  factory GuruModel.fromJson(Map<String, dynamic> json) {
    return GuruModel(
      id: json['id'] as String,
      nuptk: json['nuptk'] as String,
      nama: json['nama'] as String,
      nip: json['nip'] as String?,
      email: json['email'] as String?,
      noTelp: json['no_telp'] as String?,
      alamat: json['alamat'] as String?,
      pendidikanTerakhir: json['pendidikan_terakhir'] as String?,
      isWaliKelas: json['is_wali_kelas'] as bool? ?? false,
      waliKelas: json['wali_kelas'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // ✅ TO JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nuptk': nuptk,
      'nama': nama,
      'nip': nip,
      'email': email,
      'no_telp': noTelp,
      'alamat': alamat,
      'pendidikan_terakhir': pendidikanTerakhir,
      'is_wali_kelas': isWaliKelas,
      'wali_kelas': waliKelas,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // ✅ TO ENTITY (returns self since it already is an entity)
  GuruEntity toEntity() => this;

  // ✅ FROM ENTITY
  factory GuruModel.fromEntity(GuruEntity entity) {
    return GuruModel(
      id: entity.id,
      nuptk: entity.nuptk,
      nama: entity.nama,
      nip: entity.nip,
      email: entity.email,
      noTelp: entity.noTelp,
      alamat: entity.alamat,
      pendidikanTerakhir: entity.pendidikanTerakhir,
      isWaliKelas: entity.isWaliKelas,
      waliKelas: entity.waliKelas,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // ✅ COPY WITH
  @override
  GuruModel copyWith({
    String? id,
    String? nuptk,
    String? nama,
    String? nip,
    String? email,
    String? noTelp,
    String? alamat,
    String? pendidikanTerakhir,
    bool? isWaliKelas,
    String? waliKelas,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GuruModel(
      id: id ?? this.id,
      nuptk: nuptk ?? this.nuptk,
      nama: nama ?? this.nama,
      nip: nip ?? this.nip,
      email: email ?? this.email,
      noTelp: noTelp ?? this.noTelp,
      alamat: alamat ?? this.alamat,
      pendidikanTerakhir: pendidikanTerakhir ?? this.pendidikanTerakhir,
      isWaliKelas: isWaliKelas ?? this.isWaliKelas,
      waliKelas: waliKelas ?? this.waliKelas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}