//C:\Users\MSITHIN\monitoring_akademik\lib\data\models\statistik_nilai_model.dart
class StatistikNilaiModel {
  final String kelas;
  final String mataPelajaran;
  final int totalSiswa;
  final int sudahDinilai;
  final int belumDinilai;
  final double rataRata;
  final double nilaiTertinggi;
  final double nilaiTerendah;
  final int jumlahA;
  final int jumlahB;
  final int jumlahC;
  final int jumlahD;
  final int jumlahE;

  StatistikNilaiModel({
    required this.kelas,
    required this.mataPelajaran,
    required this.totalSiswa,
    required this.sudahDinilai,
    required this.belumDinilai,
    required this.rataRata,
    required this.nilaiTertinggi,
    required this.nilaiTerendah,
    required this.jumlahA,
    required this.jumlahB,
    required this.jumlahC,
    required this.jumlahD,
    required this.jumlahE,
  });

  // Helper untuk persentase kelulusan (nilai >= 70)
  double get persentaseKelulusan {
    if (sudahDinilai == 0) return 0;
    final lulus = jumlahA + jumlahB + jumlahC;
    return (lulus / sudahDinilai) * 100;
  }

  // Helper untuk persentase tidak lulus (nilai < 70)
  double get persentaseTidakLulus {
    if (sudahDinilai == 0) return 0;
    final tidakLulus = jumlahD + jumlahE;
    return (tidakLulus / sudahDinilai) * 100;
  }

  // ✅ NEW: Factory constructor from Map
  factory StatistikNilaiModel.fromMap(Map<String, dynamic> map) {
    return StatistikNilaiModel(
      kelas: map['kelas'] ?? '',
      mataPelajaran: map['mataPelajaran'] ?? '',
      totalSiswa: map['totalSiswa'] ?? 0,
      sudahDinilai: map['sudahDinilai'] ?? 0,
      belumDinilai: map['belumDinilai'] ?? 0,
      rataRata: (map['rataRata'] ?? 0).toDouble(),
      nilaiTertinggi: (map['nilaiTertinggi'] ?? 0).toDouble(),
      nilaiTerendah: (map['nilaiTerendah'] ?? 0).toDouble(),
      jumlahA: map['jumlahA'] ?? 0,
      jumlahB: map['jumlahB'] ?? 0,
      jumlahC: map['jumlahC'] ?? 0,
      jumlahD: map['jumlahD'] ?? 0,
      jumlahE: map['jumlahE'] ?? 0,
    );
  }
}