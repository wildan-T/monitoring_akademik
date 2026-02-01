class NilaiConverter {
  // Konversi dari Input Dropdown (A/B/C) ke Database (Angka)
  // Kita pakai standar konversi 1-4 atau 0-100, terserah Anda.
  // Di sini saya pakai 0-100 agar konsisten dengan tipe data double/int.
  static double predikatToAngka(String predikat) {
    switch (predikat) {
      case 'A':
        return 95.0; // Representasi Sangat Baik
      case 'B':
        return 85.0; // Representasi Baik
      case 'C':
        return 75.0; // Representasi Cukup
      case 'D':
        return 60.0; // Representasi Kurang
      default:
        return 0.0;
    }
  }

  // Konversi dari Database (Angka) ke Tampilan UI (A/B/C)
  static String angkaToPredikat(double nilai) {
    if (nilai >= 91) return 'A';
    if (nilai >= 81) return 'B';
    if (nilai >= 71) return 'C';
    return 'D';
  }

  static String getKeteranganDefault(String predikat) {
    switch (predikat) {
      case 'A':
        return "Sangat Baik";
      case 'B':
        return "Baik";
      case 'C':
        return "Cukup";
      default:
        return "Kurang";
    }
  }
}
