// lib/data/models/mata_pelajaran_model.dart
class MataPelajaranModel {
  final String id;
  final String kodeMapel;
  final String namaMapel;
  final String? kategori;

  MataPelajaranModel({
    required this.id,
    required this.kodeMapel,
    required this.namaMapel,
    this.kategori,
  });

  factory MataPelajaranModel.fromJson(Map<String, dynamic> json) {
    return MataPelajaranModel(
      id: json['id']?.toString() ?? '',
      kodeMapel: json['kode_mapel']?.toString() ?? '',
      namaMapel: json['nama_mapel']?.toString() ?? '',
      kategori: json['kategori']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // ID tidak dikirim saat insert karena auto-generate
      if (id.isNotEmpty) 'id': id,
      'kode_mapel': kodeMapel,
      'nama_mapel': namaMapel,
      'kategori': kategori,
    };
  }
}
