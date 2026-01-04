//C:\Users\MSITHIN\monitoring_akademik\lib\data\models\kelas_mapel_model.dart
class KelasMapelModel {
  final String id;
  final String guruId;
  final String kelas; // 7A, 7B, dst
  final String mataPelajaran;

  KelasMapelModel({
    required this.id,
    required this.guruId,
    required this.kelas,
    required this.mataPelajaran,
  });

  // Helper untuk display
  String get displayName {
    return '$kelas - $mataPelajaran';
  }

  // From JSON
  factory KelasMapelModel.fromJson(Map<String, dynamic> json) {
    return KelasMapelModel(
      id: json['id']?.toString() ?? '',
      guruId: json['guru_id']?.toString() ?? '',
      kelas: json['kelas']?.toString() ?? '',
      mataPelajaran: json['mata_pelajaran']?.toString() ?? '',
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guru_id': guruId,
      'kelas': kelas,
      'mata_pelajaran': mataPelajaran,
    };
  }
}