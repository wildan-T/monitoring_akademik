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
    super.fotoProfil,
    super.jenisKelamin,
    super.tempatLahir,
    super.tanggalLahir,
    super.agama,
    super.status,
    super.createdAt,
    super.updatedAt,
  });

  // ✅ FROM JSON
  factory GuruModel.fromJson(Map<String, dynamic> json) {
    // ✅ Extract profiles data (relasi)
    final profiles = json['profiles'] as Map<String, dynamic>?;

    return GuruModel(
      // Gunakan toString() ?? '' untuk mencegah error casting Null
      id: json['id']?.toString() ?? '',

      // ✅ FIX 1: Berikan nilai default jika NUPTK null
      nuptk: json['nuptk']?.toString() ?? '-',

      // ✅ FIX 2: Cek 'nama' ATAU 'nama_lengkap' (antisipasi beda nama kolom)
      nama:
          json['nama']?.toString() ??
          json['nama_lengkap']?.toString() ??
          'Tanpa Nama',

      nip: json['nip']?.toString(),
      // ✅ Prioritaskan email/telp dari tabel profiles, fallback ke tabel guru
      email: profiles?['email']?.toString() ?? json['email']?.toString(),
      noTelp:
          profiles?['no_telepon']?.toString() ?? json['no_telp']?.toString(),

      alamat: json['alamat']?.toString(),
      pendidikanTerakhir: json['pendidikan_terakhir']?.toString(),
      // Handle boolean dengan aman
      isWaliKelas: json['is_wali_kelas'] == true || json['is_wali_kelas'] == 1,

      // Handle nested object atau string untuk wali kelas
      waliKelas: json['wali_kelas'] is Map
          ? json['wali_kelas']['nama_kelas']?.toString()
          : json['wali_kelas']?.toString(),

      // ✅ Ambil foto profil dari profiles
      fotoProfil: profiles?['foto_profil']?.toString(),

      jenisKelamin: json['jenis_kelamin']?.toString(),
      tempatLahir: json['tempat_lahir']?.toString(),
      tanggalLahir: json['tanggal_lahir'] != null
          ? DateTime.tryParse(json['tanggal_lahir'].toString())
          : null,
      agama: json['agama']?.toString(),
      status: json['status_kepegawaian']
          ?.toString(), // Map 'status' entity ke 'status_kepegawaian' DB

      createdAt: json['created_at'] != null
          ? DateTime.tryParse(
              json['created_at'].toString(),
            ) // Gunakan tryParse agar tidak crash format salah
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
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
      'jenis_kelamin': jenisKelamin,
      'tempat_lahir': tempatLahir,
      'tanggal_lahir': tanggalLahir?.toIso8601String(),
      'agama': agama,
      'status_kepegawaian': status,
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
    String? fotoProfil,
    String? jenisKelamin,
    String? tempatLahir,
    DateTime? tanggalLahir,
    String? agama,
    String? status,
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
      fotoProfil: fotoProfil ?? this.fotoProfil,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      tempatLahir: tempatLahir ?? this.tempatLahir,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      agama: agama ?? this.agama,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
