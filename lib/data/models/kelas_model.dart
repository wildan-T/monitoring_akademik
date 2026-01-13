// lib/data/models/kelas_model.dart
class KelasModel {
  final String id;
  final String namaKelas;
  final int tingkat;
  final String? waliKelasId; // Ini adalah profile_id
  String? namaWali; // Diisi manual oleh Provider dari data Guru

  KelasModel({
    required this.id,
    required this.namaKelas,
    required this.tingkat,
    this.waliKelasId,
    this.namaWali,
  });

  factory KelasModel.fromJson(Map<String, dynamic> json) {
    return KelasModel(
      id: json['id']?.toString() ?? '',
      namaKelas: json['nama_kelas']?.toString() ?? '',
      tingkat: int.tryParse(json['tingkat'].toString()) ?? 7,
      waliKelasId: json['wali_kelas_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // id tidak dikirim saat create
      'nama_kelas': namaKelas,
      'tingkat': tingkat,
      'wali_kelas_id': waliKelasId,
    };
  }

  void operator [](String other) {}
}
