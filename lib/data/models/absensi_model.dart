//C:\Users\MSITHIN\monitoring_akademik\lib\data\models\absensi_model.dart
import '../../domain/entities/absensi_entity.dart';

class AbsensiModel extends AbsensiEntity {
  AbsensiModel({
    required super.id,
    required super.siswaId,
    required super.namaSiswa,
    required super.guruId,
    required super.namaGuru,
    required super.kelasId,
    required super.kelas,
    required super.mataPelajaranId,
    required super.mataPelajaran,
    required super.tanggal,
    required super.pertemuan,
    required super.status,
    super.keterangan,
    required super.createdAt,
    super.updatedAt,
  });

  // ✅ Helper: Get siswa object for compatibility
  Map<String, dynamic> get siswa => {
    'id': siswaId,
    'nama': namaSiswa,
  };

  // Copy with
  AbsensiModel copyWith({
    String? id,
    String? siswaId,
    String? namaSiswa,
    String? guruId,
    String? namaGuru,
    String? kelasId,
    String? kelas,
    String? mataPelajaranId,
    String? mataPelajaran,
    DateTime? tanggal,
    int? pertemuan,
    AbsensiStatus? status,
    String? keterangan,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AbsensiModel(
      id: id ?? this.id,
      siswaId: siswaId ?? this.siswaId,
      namaSiswa: namaSiswa ?? this.namaSiswa,
      guruId: guruId ?? this.guruId,
      namaGuru: namaGuru ?? this.namaGuru,
      kelasId: kelasId ?? this.kelasId,
      kelas: kelas ?? this.kelas,
      mataPelajaranId: mataPelajaranId ?? this.mataPelajaranId,
      mataPelajaran: mataPelajaran ?? this.mataPelajaran,
      tanggal: tanggal ?? this.tanggal,
      pertemuan: pertemuan ?? this.pertemuan,
      status: status ?? this.status,
      keterangan: keterangan ?? this.keterangan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // From JSON
  factory AbsensiModel.fromJson(Map<String, dynamic> json) {
    final siswaData = json['siswa'] is Map ? json['siswa'] : null;
    final guruData = json['guru'] is Map ? json['guru'] : null;
    final kelasData = json['kelas'] is Map ? json['kelas'] : null;
    final mapelData = json['mata_pelajaran'] is Map ? json['mata_pelajaran'] : null;

    return AbsensiModel(
      id: json['id']?.toString() ?? '',
      siswaId: json['siswa_id']?.toString() ?? '',
      namaSiswa: siswaData?['nama']?.toString() ?? json['nama_siswa']?.toString() ?? 'Unknown',
      guruId: json['guru_id']?.toString() ?? '',
      namaGuru: guruData?['nama']?.toString() ?? json['nama_guru']?.toString() ?? 'Unknown',
      kelasId: json['kelas_id']?.toString() ?? '',
      kelas: kelasData?['nama']?.toString() ?? json['kelas']?.toString() ?? 'Unknown',
      mataPelajaranId: json['mata_pelajaran_id']?.toString() ?? '',
      mataPelajaran: mapelData?['nama']?.toString() ?? json['mata_pelajaran']?.toString() ?? 'Unknown',
      tanggal: json['tanggal'] != null 
          ? DateTime.parse(json['tanggal'].toString())
          : DateTime.now(),
      pertemuan: json['pertemuan'] is int 
          ? json['pertemuan'] 
          : int.tryParse(json['pertemuan']?.toString() ?? '1') ?? 1,
      status: _parseStatus(json['status']),
      keterangan: json['keterangan']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
    );
  }

  // Helper: Parse status from String
  static AbsensiStatus _parseStatus(dynamic status) {
    if (status == null) return AbsensiStatus.hadir;
    
    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'hadir':
        return AbsensiStatus.hadir;
      case 'izin':
        return AbsensiStatus.izin;
      case 'sakit':
        return AbsensiStatus.sakit;
      case 'alpha':
        return AbsensiStatus.alpha;
      default:
        try {
          return AbsensiStatus.values.firstWhere(
            (e) => e.toString() == status.toString(),
            orElse: () => AbsensiStatus.hadir,
          );
        } catch (_) {
          return AbsensiStatus.hadir;
        }
    }
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'siswa_id': siswaId,
      'nama_siswa': namaSiswa,
      'guru_id': guruId,
      'nama_guru': namaGuru,
      'kelas_id': kelasId,
      'kelas': kelas,
      'mata_pelajaran_id': mataPelajaranId,
      'mata_pelajaran': mataPelajaran,
      'tanggal': tanggal.toIso8601String(),
      'pertemuan': pertemuan,
      'status': status.toString().split('.').last,
      'keterangan': keterangan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Getter untuk label status
  String get statusLabel {
    switch (status) {
      case AbsensiStatus.hadir:
        return 'Hadir';
      case AbsensiStatus.izin:
        return 'Izin';
      case AbsensiStatus.sakit:
        return 'Sakit';
      case AbsensiStatus.alpha:
        return 'Alpha';
    }
  }

  // Getter untuk warna status
  String get statusColor {
    switch (status) {
      case AbsensiStatus.hadir:
        return '#4CAF50';
      case AbsensiStatus.izin:
        return '#FF9800';
      case AbsensiStatus.sakit:
        return '#2196F3';
      case AbsensiStatus.alpha:
        return '#F44336';
    }
  }
}