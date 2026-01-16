import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/siswa_model.dart';
import '../models/nilai_model.dart';

class RaporPdfService {
  /// Fungsi Utama Generate PDF
  Future<Uint8List> generateRapor({
    required SiswaModel siswa,
    required String namaKelas,
    required String tahunAjaran,
    required String semester,
    required String namaWaliKelas,
    required List<Map<String, dynamic>>
    listNilaiRaw, // Data gabungan nilai + nama mapel
  }) async {
    final pdf = pw.Document();

    // Load Font (Opsional, pakai default dulu biar ringan)
    // final font = await PdfGoogleFonts.nunitoExtraLight();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(tahunAjaran, semester),
              pw.SizedBox(height: 20),
              _buildStudentInfo(siswa, namaKelas),
              pw.SizedBox(height: 20),
              _buildTableNilai(listNilaiRaw),
              pw.Spacer(),
              _buildSignature(namaWaliKelas),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // 1. Header Sekolah
  pw.Widget _buildHeader(String tahun, String semester) {
    return pw.Column(
      children: [
        pw.Text(
          'LAPORAN HASIL BELAJAR SISWA',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text('SMP NEGERI 20 TANGERANG', style: pw.TextStyle(fontSize: 14)),
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
              'Tanggal: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
            ),
          ],
        ),
      ],
    );
  }

  // 3. Tabel Nilai
  pw.Widget _buildTableNilai(List<Map<String, dynamic>> listNilai) {
    return pw.TableHelper.fromTextArray(
      headers: [
        'No',
        'Mata Pelajaran',
        'Nilai Akhir',
        'Predikat',
        'Keterangan',
      ],
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FlexColumnWidth(3), // Mapel lebih lebar
        2: const pw.FixedColumnWidth(60),
        3: const pw.FixedColumnWidth(60),
        4: const pw.FlexColumnWidth(2),
      },
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      cellAlignment: pw.Alignment.centerLeft,
      data: List<List<String>>.generate(listNilai.length, (index) {
        final item = listNilai[index];
        final mapel = item['mata_pelajaran']?['nama_mapel'] ?? 'Mapel Dihapus';
        final nilaiAkhir = item['nilai_akhir'] ?? 0.0;

        return [
          (index + 1).toString(),
          mapel,
          nilaiAkhir.toString(),
          _hitungPredikat(nilaiAkhir),
          _hitungKeterangan(nilaiAkhir),
        ];
      }),
    );
  }

  // 4. Tanda Tangan
  pw.Widget _buildSignature(String waliKelas) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          children: [
            pw.Text('Orang Tua / Wali'),
            pw.SizedBox(height: 50),
            pw.Text('( ...................... )'),
          ],
        ),
        pw.Column(
          children: [
            pw.Text('Wali Kelas'),
            pw.SizedBox(height: 50),
            pw.Text(
              waliKelas,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                decoration: pw.TextDecoration.underline,
              ),
            ),
            pw.Text('NIP. ......................'),
          ],
        ),
      ],
    );
  }

  String _hitungPredikat(dynamic nilai) {
    double n = (nilai is int) ? nilai.toDouble() : (nilai as double);
    if (n >= 90) return 'A';
    if (n >= 80) return 'B';
    if (n >= 70) return 'C';
    if (n >= 60) return 'D';
    return 'E';
  }

  String _hitungKeterangan(dynamic nilai) {
    double n = (nilai is int) ? nilai.toDouble() : (nilai as double);
    return n >= 70 ? 'Tuntas' : 'Belum Tuntas';
  }
}
