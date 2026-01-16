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

  // ✅ FROM JSON (Updated untuk Reverse Lookup)
  // Menambahkan parameter opsional 'kelasData' untuk menampung data dari tabel kelas
  factory GuruModel.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? kelasData,
  }) {
    // Pastikan ini bisa menangkap objek 'profiles' dari query select('*, profiles(...)')
    final profiles = json['profiles'] is Map ? json['profiles'] : null;

    // print('JSON GURU: $json');
    // print('PROFILES: ${json['profiles']}');
    return GuruModel(
      id: json['id']?.toString() ?? '',
      nuptk: json['nuptk']?.toString() ?? '-',

      // Handle nama (prioritas nama di tabel guru, fallback ke profiles)
      nama:
          json['nama']?.toString() ??
          json['nama_lengkap']?.toString() ??
          profiles?['nama_lengkap']?.toString() ??
          'Tanpa Nama',

      nip: json['nip']?.toString(),

      // Prioritaskan email/telp dari tabel profiles, fallback ke tabel guru
      email: profiles?['email']?.toString() ?? json['email']?.toString(),
      noTelp:
          profiles?['no_telepon']?.toString() ?? json['no_telp']?.toString(),

      alamat: json['alamat']?.toString(),
      pendidikanTerakhir: json['pendidikan_terakhir']?.toString(),

      // ✅ LOGIC WALI KELAS (PENTING)
      // 1. Cek apakah ada parameter kelasData yang dikirim (dari Reverse Lookup)
      // 2. Jika tidak, cek apakah ada key 'kelas' di json (jika pakai Join Query)
      isWaliKelas: kelasData != null || json['kelas'] != null,

      // Ambil nama kelas dari parameter kelasData ATAU dari json join
      waliKelas:
          kelasData?['nama_kelas']?.toString() ??
          (json['kelas'] is Map
              ? json['kelas']['nama_kelas']?.toString()
              : null),

      // Ambil foto profil dari profiles
      fotoProfil: profiles?['foto_profil']?.toString(),

      jenisKelamin: json['jenis_kelamin']?.toString(),
      tempatLahir: json['tempat_lahir']?.toString(),
      tanggalLahir: json['tanggal_lahir'] != null
          ? DateTime.tryParse(json['tanggal_lahir'].toString())
          : null,
      agama: json['agama']?.toString(),
      status: json['status_kepegawaian']?.toString(),

      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  // ✅ TO JSON (Untuk dikirim ke API/Supabase)
  Map<String, dynamic> toJson() {
    final data = {
      'id': id,
      'nuptk': nuptk,
      'nama_lengkap': nama,
      'nip': nip,
      'alamat': alamat,
      'pendidikan_terakhir': pendidikanTerakhir,
      // 'is_wali_kelas': isWaliKelas, // ⚠️ Jangan kirim ini ke tabel Guru (karena kolom tidak ada)
      // 'wali_kelas': waliKelas,      // ⚠️ Jangan kirim ini ke tabel Guru
      'jenis_kelamin': jenisKelamin,
      'tempat_lahir': tempatLahir,
      'tanggal_lahir': tanggalLahir?.toIso8601String(),
      'agama': agama,
      'status_kepegawaian': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };

    // Hapus nilai null agar tidak menimpa data di DB dengan null (opsional)
    data.removeWhere((key, value) => value == null);

    return data;
  }

  // ✅ TO ENTITY
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
      fotoProfil: entity.fotoProfil,
      jenisKelamin: entity.jenisKelamin,
      tempatLahir: entity.tempatLahir,
      tanggalLahir: entity.tanggalLahir,
      agama: entity.agama,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

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
