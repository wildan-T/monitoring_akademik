//C:\Users\MSITHIN\monitoring_akademik\lib\core\services\nilai_export_service.dart
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:open_filex/open_filex.dart';
import 'package:open_file/open_file.dart'; // ✅ BENAR
import '../../data/models/nilai_model.dart';

class NilaiExportService {
  // ✅ 1. EXPORT TO EXCEL
  static Future<void> exportToExcel(List<NilaiModel> nilaiList) async {
    try {
      // Create Excel file
      final excel = Excel.createExcel();
      final sheet = excel['Daftar Nilai'];

      // Header styling
      final headerStyle = CellStyle(
        bold: true,
        fontSize: 12,
        backgroundColorHex: ExcelColor.fromHexString('#2196F3'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );

      // ✅ Add Headers
      final headers = [
        'No',
        'Nama Siswa',
        'Kelas',
        'Mata Pelajaran',
        'Nilai Tugas',
        'Nilai UH',
        'Nilai UTS',
        'Nilai UAS',
        'Nilai Praktik',
        'Nilai Sikap',
        'Nilai Akhir',
        'Grade',
        'Predikat',
      ];

      for (var i = 0; i < headers.length; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }

      // ✅ Add Data
      for (var i = 0; i < nilaiList.length; i++) {
        final nilai = nilaiList[i];
        final row = i + 1;

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .value = IntCellValue(
          i + 1,
        );

        //   sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        //     .value = TextCellValue(nilai.namaSiswa);

        //   sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
        //     .value = TextCellValue(nilai.kelas);

        //   sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
        //     .value = TextCellValue(nilai.mataPelajaran);

        //   sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
        //     .value = DoubleCellValue(nilai.nilaiTugas ?? 0);

        //   sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
        //     .value = DoubleCellValue(nilai.nilaiUH ?? 0);

        //   sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
        //     .value = DoubleCellValue(nilai.nilaiUTS ?? 0);

        //   sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row))
        //     .value = DoubleCellValue(nilai.nilaiUAS ?? 0);

        //   sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row))
        //     .value = nilai.nilaiPraktik != null
        //       ? DoubleCellValue(nilai.nilaiPraktik!)
        //       : TextCellValue('-');

        //   sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row))
        //     .value = TextCellValue(nilai.nilaiSikap ?? '-');

        //   sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: row))
        //     .value = nilai.nilaiAkhir != null
        //       ? DoubleCellValue(double.parse(nilai.nilaiAkhir!.toStringAsFixed(1)))
        //       : TextCellValue('-');

        //   sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: row))
        //     .value = TextCellValue(nilai.nilaiHuruf ?? '-');

        //   sheet.cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: row))
        //     .value = TextCellValue(nilai.predikat ?? '-');
      }

      // ✅ Auto-fit columns
      for (var i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 15);
      }

      // ✅ Save file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/daftar_nilai_$timestamp.xlsx';

      final fileBytes = excel.save();
      final file = File(filePath);
      await file.writeAsBytes(fileBytes!);

      // ✅ Open file
      await OpenFile.open(filePath);

      print('✅ Excel berhasil disimpan: $filePath');
    } catch (e) {
      print('❌ Error export Excel: $e');
      rethrow;
    }
  }

  // ✅ 2. EXPORT TO PDF
  static Future<void> exportToPdf(List<NilaiModel> nilaiList) async {
    try {
      final pdf = pw.Document();

      // ✅ Add Page
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              // Header
              pw.Header(
                level: 0,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'DAFTAR NILAI SISWA',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'SMPN 20 TANGERANG',
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Divider(thickness: 2),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

              // Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                columnWidths: {
                  0: const pw.FixedColumnWidth(30),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FixedColumnWidth(50),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FixedColumnWidth(45),
                  5: const pw.FixedColumnWidth(45),
                  6: const pw.FixedColumnWidth(45),
                  7: const pw.FixedColumnWidth(45),
                  8: const pw.FixedColumnWidth(50),
                  9: const pw.FixedColumnWidth(50),
                },
                children: [
                  // Header Row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.blue),
                    children: [
                      _buildTableCell('No', isHeader: true),
                      _buildTableCell('Nama Siswa', isHeader: true),
                      _buildTableCell('Kelas', isHeader: true),
                      _buildTableCell('Mata Pelajaran', isHeader: true),
                      _buildTableCell('Tugas', isHeader: true),
                      _buildTableCell('UH', isHeader: true),
                      _buildTableCell('UTS', isHeader: true),
                      _buildTableCell('UAS', isHeader: true),
                      _buildTableCell('Nilai Akhir', isHeader: true),
                      _buildTableCell('Grade', isHeader: true),
                    ],
                  ),

                  // Data Rows
                  ...nilaiList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final nilai = entry.value;

                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: index % 2 == 0
                            ? PdfColors.grey100
                            : PdfColors.white,
                      ),
                      children: [
                        _buildTableCell('${index + 1}'),
                        // _buildTableCell(nilai.namaSiswa),
                        // _buildTableCell(nilai.kelas),
                        // _buildTableCell(nilai.mataPelajaran),
                        // _buildTableCell(nilai.nilaiTugas?.toStringAsFixed(0) ?? '-'),
                        // _buildTableCell(nilai.nilaiUH?.toStringAsFixed(0) ?? '-'),
                        // _buildTableCell(nilai.nilaiUTS?.toStringAsFixed(0) ?? '-'),
                        // _buildTableCell(nilai.nilaiUAS?.toStringAsFixed(0) ?? '-'),
                        // _buildTableCell(nilai.nilaiAkhir?.toStringAsFixed(1) ?? '-'),
                        // _buildTableCell(nilai.nilaiHuruf ?? '-'),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.SizedBox(height: 24),

              // Footer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total: ${nilaiList.length} data',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                  pw.Text(
                    'Dicetak: ${DateTime.now().toString().split('.')[0]}',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                ],
              ),
            ];
          },
        ),
      );

      // ✅ Save PDF
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/daftar_nilai_$timestamp.pdf';

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // ✅ Open PDF
      await OpenFile.open(filePath);

      print('✅ PDF berhasil disimpan: $filePath');
    } catch (e) {
      print('❌ Error export PDF: $e');
      rethrow;
    }
  }

  // ✅ 3. PRINT (Preview & Print)
  static Future<void> printNilai(List<NilaiModel> nilaiList) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          final pdf = pw.Document();

          pdf.addPage(
            pw.MultiPage(
              pageFormat: format.landscape,
              margin: const pw.EdgeInsets.all(20),
              build: (pw.Context context) {
                return [
                  // Header
                  pw.Header(
                    level: 0,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'DAFTAR NILAI SISWA',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'SMPN 20 TANGERANG',
                          style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Divider(thickness: 2),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 16),

                  // Table (sama dengan PDF export)
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey400),
                    columnWidths: {
                      0: const pw.FixedColumnWidth(30),
                      1: const pw.FlexColumnWidth(3),
                      2: const pw.FixedColumnWidth(50),
                      3: const pw.FlexColumnWidth(2),
                      4: const pw.FixedColumnWidth(45),
                      5: const pw.FixedColumnWidth(45),
                      6: const pw.FixedColumnWidth(45),
                      7: const pw.FixedColumnWidth(45),
                      8: const pw.FixedColumnWidth(50),
                      9: const pw.FixedColumnWidth(50),
                    },
                    children: [
                      // Header Row
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.blue,
                        ),
                        children: [
                          _buildTableCell('No', isHeader: true),
                          _buildTableCell('Nama Siswa', isHeader: true),
                          _buildTableCell('Kelas', isHeader: true),
                          _buildTableCell('Mata Pelajaran', isHeader: true),
                          _buildTableCell('Tugas', isHeader: true),
                          _buildTableCell('UH', isHeader: true),
                          _buildTableCell('UTS', isHeader: true),
                          _buildTableCell('UAS', isHeader: true),
                          _buildTableCell('Nilai Akhir', isHeader: true),
                          _buildTableCell('Grade', isHeader: true),
                        ],
                      ),

                      // Data Rows
                      ...nilaiList.asMap().entries.map((entry) {
                        final index = entry.key;
                        final nilai = entry.value;

                        return pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: index % 2 == 0
                                ? PdfColors.grey100
                                : PdfColors.white,
                          ),
                          children: [
                            _buildTableCell('${index + 1}'),
                            // _buildTableCell(nilai.namaSiswa),
                            // _buildTableCell(nilai.kelas),
                            // _buildTableCell(nilai.mataPelajaran),
                            // _buildTableCell(nilai.nilaiTugas?.toStringAsFixed(0) ?? '-'),
                            // _buildTableCell(nilai.nilaiUH?.toStringAsFixed(0) ?? '-'),
                            // _buildTableCell(nilai.nilaiUTS?.toStringAsFixed(0) ?? '-'),
                            // _buildTableCell(nilai.nilaiUAS?.toStringAsFixed(0) ?? '-'),
                            // _buildTableCell(nilai.nilaiAkhir?.toStringAsFixed(1) ?? '-'),
                            // _buildTableCell(nilai.nilaiHuruf ?? '-'),
                          ],
                        );
                      }).toList(),
                    ],
                  ),

                  pw.SizedBox(height: 24),

                  // Footer
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Total: ${nilaiList.length} data',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        'Dicetak: ${DateTime.now().toString().split('.')[0]}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ];
              },
            ),
          );

          return pdf.save();
        },
      );

      print('✅ Print preview dibuka');
    } catch (e) {
      print('❌ Error print: $e');
      rethrow;
    }
  }

  // ✅ Helper: Build Table Cell
  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : PdfColors.black,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}
