import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/siswa_model.dart';

class RaporPdfService {
  /// Fungsi Utama Generate PDF
  Future<Uint8List> generateRapor({
    required SiswaModel siswa,
    required String namaKelas,
    required String tahunAjaran,
    required String semester,
    required String namaWaliKelas,
    required String nipWaliKelas,
    required List<Map<String, dynamic>> listNilaiRaw,
  }) async {
    final pdf = pw.Document();

    // 1. FILTER DATA BERDASARKAN KATEGORI
    // Pastikan database tabel mata_pelajaran kolom 'kategori' isinya:
    // 'KELOMPOK_A', 'KELOMPOK_B', atau 'EKSKUL'

    // Kelompok A (Wajib/Umum)
    final listKelompokA = listNilaiRaw.where((n) {
      final mapel = n['mata_pelajaran'];
      return mapel != null && mapel['kategori'] == 'Kelompok A';
    }).toList();

    // Kelompok B (Seni/Muatan Lokal)
    final listKelompokB = listNilaiRaw.where((n) {
      final mapel = n['mata_pelajaran'];
      return mapel != null && mapel['kategori'] == 'Kelompok B';
    }).toList();

    // Ekstrakurikuler
    final listEkskul = listNilaiRaw.where((n) {
      final mapel = n['mata_pelajaran'];
      return mapel != null && mapel['kategori'] == 'Ekstrakurikuler';
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // HEADER & INFO SISWA
            _buildHeader(tahunAjaran, semester),
            pw.SizedBox(height: 20),
            _buildStudentInfo(siswa, namaKelas),
            pw.SizedBox(height: 20),

            pw.Text(
              "CAPAIAN HASIL BELAJAR",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
            ),
            pw.SizedBox(height: 10),

            // --- TABEL A. KELOMPOK 1 (UMUM) ---
            if (listKelompokA.isNotEmpty) ...[
              pw.Container(
                width: double.infinity,
                color: PdfColors.grey200,
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                  "Kelompok A",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
              _buildTableAkademik(listKelompokA),
              pw.SizedBox(height: 15),
            ],

            // --- TABEL B. KELOMPOK 2 (MULOK) ---
            if (listKelompokB.isNotEmpty) ...[
              pw.Container(
                width: double.infinity,
                color: PdfColors.grey200,
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                  "Kelompok B",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
              _buildTableAkademik(listKelompokB),
              pw.SizedBox(height: 15),
            ],

            // --- TABEL C. EKSTRAKURIKULER ---
            if (listEkskul.isNotEmpty) ...[
              pw.Container(
                width: double.infinity,
                color: PdfColors.grey200,
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                  "Ekstrakurikuler",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
              _buildTableEkskul(listEkskul),
              pw.SizedBox(height: 20),
            ],

            // --- FOOTER TANDA TANGAN ---
            pw.Spacer(),
            _buildSignature(namaWaliKelas, nipWaliKelas),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ==========================================
  // 📝 WIDGET COMPONENTS
  // ==========================================

  // 1. Header Sekolah
  pw.Widget _buildHeader(String tahun, String semester) {
    return pw.Column(
      children: [
        pw.Text(
          'LAPORAN HASIL BELAJAR SISWA',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          'SMP NEGERI 20 TANGERANG',
          style: const pw.TextStyle(fontSize: 14),
        ),
        pw.Text(
          'Tahun Pelajaran $tahun - Semester $semester',
          style: const pw.TextStyle(fontSize: 12),
        ),
        pw.Divider(thickness: 2),
      ],
    );
  }

  // 2. Info Siswa
  pw.Widget _buildStudentInfo(SiswaModel siswa, String kelas) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Nama: ${siswa.nama}'),
            pw.Text('NISN: ${siswa.nisn}'),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Kelas: $kelas'),
            pw.Text(
              'Tanggal: ${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now())}',
            ),
          ],
        ),
      ],
    );
  }

  // 3. Tabel Akademik (Untuk Kelompok A & B)
  pw.Widget _buildTableAkademik(List<Map<String, dynamic>> listNilai) {
    return pw.Table.fromTextArray(
      headers: ['No', 'Mata Pelajaran', 'Nilai', 'Predikat', 'Deskripsi'],
      columnWidths: {
        0: const pw.FixedColumnWidth(30), // No
        1: const pw.FlexColumnWidth(3), // Mapel
        2: const pw.FixedColumnWidth(40), // Nilai
        3: const pw.FixedColumnWidth(60), // Predikat
        4: const pw.FlexColumnWidth(4), // Deskripsi
      },
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      cellAlignments: {
        0: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
      },
      data: List<List<dynamic>>.generate(listNilai.length, (index) {
        final item = listNilai[index];
        final mapel = item['mata_pelajaran']?['nama_mapel'] ?? '-';
        final nilai = item['nilai_akhir'] ?? 0;

        final predikat = _hitungPredikat(nilai);

        // Deskripsi sederhana (Bisa diganti logika yang lebih kompleks)
        String deskripsi =
            "Memiliki kemampuan ${predikat == 'A'
                ? 'Sangat Baik'
                : predikat == 'B'
                ? 'Baik'
                : 'Cukup'} dalam memahami materi.";

        return [index + 1, mapel, nilai, predikat, deskripsi];
      }),
    );
  }

  // 4. Tabel Ekstrakurikuler (Format Khusus)
  pw.Widget _buildTableEkskul(List<Map<String, dynamic>> listNilai) {
    return pw.Table.fromTextArray(
      headers: ['No', 'Kegiatan Ekstrakurikuler', 'Predikat', 'Deskripsi'],
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FixedColumnWidth(60),
        3: const pw.FlexColumnWidth(4),
      },
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      cellAlignments: {0: pw.Alignment.center, 2: pw.Alignment.center},
      data: List<List<dynamic>>.generate(listNilai.length, (index) {
        final item = listNilai[index];
        final mapel =
            item['mata_pelajaran']?['nama_mapel'] ?? '-'; // Nama Ekskul

        final nilai = item['nilai_akhir'] ?? 0;
        // Ekskul biasanya disimpan angka di DB (95) tapi tampil Huruf (A)
        final predikat = _hitungPredikat(nilai);

        // Deskripsi sederhana (Bisa diganti logika yang lebih kompleks)
        String deskripsi =
            "Memiliki kemampuan ${predikat == 'A'
                ? 'Sangat Baik'
                : predikat == 'B'
                ? 'Baik'
                : 'Cukup'} dalam memahami materi.";

        return [index + 1, mapel, predikat, deskripsi];
      }),
    );
  }

  // 5. Tanda Tangan (Dengan NIP Guru)
  pw.Widget _buildSignature(String waliKelas, String nipGuru) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          children: [
            pw.Text('Orang Tua / Wali'),
            pw.SizedBox(height: 60),
            pw.Text('( ...................... )'),
          ],
        ),
        pw.Column(
          children: [
            pw.Text('Wali Kelas'),
            pw.SizedBox(height: 60),
            pw.Text(
              waliKelas,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                decoration: pw.TextDecoration.underline,
              ),
            ),
            // ✅ TAMPILKAN NIP DI SINI
            pw.Text('NIP. ${nipGuru.isNotEmpty ? nipGuru : "-"}'),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // 🧮 HELPER FUNCTIONS
  // ==========================================

  String _hitungPredikat(dynamic nilai) {
    double n = (nilai is int)
        ? nilai.toDouble()
        : (double.tryParse(nilai.toString()) ?? 0.0);
    if (n >= 90) return 'A';
    if (n >= 80) return 'B';
    if (n >= 70) return 'C';
    return 'D';
  }
}
