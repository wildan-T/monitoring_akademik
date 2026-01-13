class TahunPelajaranModel {
  final String id;
  final String tahun; // Contoh: "2025/2026"
  final int semester; // 1 = Ganjil, 2 = Genap
  final bool isActive;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;

  TahunPelajaranModel({
    required this.id,
    required this.tahun,
    required this.semester,
    required this.isActive,
    required this.tanggalMulai,
    required this.tanggalSelesai,
  });

  factory TahunPelajaranModel.fromJson(Map<String, dynamic> json) {
    return TahunPelajaranModel(
      id: json['id']?.toString() ?? '',
      tahun: json['tahun']?.toString() ?? '',
      semester: int.tryParse(json['semester'].toString()) ?? 1,
      isActive: json['is_active'] == true,
      tanggalMulai: DateTime.parse(json['tanggal_mulai']),
      tanggalSelesai: DateTime.parse(json['tanggal_selesai']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'tahun': tahun,
      'semester': semester,
      'is_active': isActive,
      'tanggal_mulai': tanggalMulai.toIso8601String(),
      'tanggal_selesai': tanggalSelesai.toIso8601String(),
    };
  }

  // Helper untuk tampilan UI
  String get semesterLabel => semester == 1 ? 'Ganjil' : 'Genap';
}
