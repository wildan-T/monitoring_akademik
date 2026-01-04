//C:\Users\MSITHIN\monitoring_akademik\lib\domain\entities\sekolah_entity.dart
class SekolahEntity {
  final String id;
  final String namaSekolah;
  final String npsn;
  final String alamat;
  final String kota;
  final String provinsi;
  final String kodePos;
  final String noTelp;
  final String email;
  final String website;
  final String namaKepalaSekolah;
  final String nipKepalaSekolah;
  final String akreditasi; // A, B, C
  final String statusSekolah; // Negeri, Swasta
  final String? logoPath; // Opsional
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SekolahEntity({
    required this.id,
    required this.namaSekolah,
    required this.npsn,
    required this.alamat,
    required this.kota,
    required this.provinsi,
    required this.kodePos,
    required this.noTelp,
    required this.email,
    required this.website,
    required this.namaKepalaSekolah,
    required this.nipKepalaSekolah,
    required this.akreditasi,
    required this.statusSekolah,
    this.logoPath,
    this.createdAt,
    this.updatedAt,
  });

  // Helper untuk alamat lengkap
  String get alamatLengkap {
    return '$alamat, $kota, $provinsi $kodePos';
  }

  // Helper untuk info akreditasi
  String get infoAkreditasi {
    switch (akreditasi) {
      case 'A':
        return 'Akreditasi A (Sangat Baik)';
      case 'B':
        return 'Akreditasi B (Baik)';
      case 'C':
        return 'Akreditasi C (Cukup)';
      default:
        return 'Belum Terakreditasi';
    }
  }
}