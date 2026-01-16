//C:\Users\MSITHIN\monitoring_akademik\lib\data\services\siswa_import_service.dart
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../models/siswa_model.dart';

class SiswaImportService {
  // ✅ METHOD 1: PICK EXCEL FILE
  static Future<File?> pickExcelFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;
        if (path != null) {
          return File(path);
        }
      }

      return null;
    } catch (e) {
      print('❌ Error pick file: $e');
      return null;
    }
  }

  // ✅ METHOD 2: IMPORT FROM EXCEL
  static Future<Map<String, dynamic>> importFromExcel(File file) async {
    try {
      // Read file bytes
      final bytes = await file.readAsBytes();

      // Decode Excel
      final excel = Excel.decodeBytes(bytes);

      // Get first sheet
      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName];

      if (sheet == null || sheet.rows.isEmpty) {
        return {
          'success': false,
          'message': 'File Excel kosong atau tidak valid',
          'data': [],
          'successCount': 0,
          'errorCount': 0,
          'errors': ['File tidak memiliki data'],
        };
      }

      final rows = sheet.rows;

      // Parse data menjadi list SiswaModel
      final List<SiswaModel> siswaList = [];
      final List<String> errors = [];
      int successCount = 0;
      int errorCount = 0;

      for (int i = 1; i < rows.length; i++) {
        // Skip header row (index 0)
        final row = rows[i];

        try {
          // Validasi row tidak kosong
          if (row.isEmpty || row.every((cell) => cell?.value == null)) {
            continue;
          }

          // Extract values dengan null safety
          final no = _getCellValue(row[0]);
          final nis = _getCellValue(row[1]);
          final nisn = _getCellValue(row[2]);
          final nama = _getCellValue(row[3]);
          final kelas = _getCellValue(row[4]);
          final jenisKelamin = _getCellValue(row[5]);
          final ttl = _getCellValue(row[6]); // Tempat, DD-MM-YYYY
          final agama = _getCellValue(row[7]);
          final alamat = _getCellValue(row[8]);
          final noHp = _getCellValue(row[9]);
          final namaAyah = _getCellValue(row[10]);
          final namaIbu = _getCellValue(row[11]);

          // ✅ FIELD TAMBAHAN (index 12 dan 13 jika ada)
          String tahunMasuk = DateTime.now().year.toString();
          String status = 'Aktif';

          // Cek apakah ada kolom 12 dan 13
          if (row.length > 12 && row[12] != null) {
            final tahunValue = _getCellValue(row[12]);
            if (tahunValue != null && tahunValue.isNotEmpty) {
              tahunMasuk = tahunValue;
            }
          }

          if (row.length > 13 && row[13] != null) {
            final statusValue = _getCellValue(row[13]);
            if (statusValue != null && statusValue.isNotEmpty) {
              status = statusValue;
            }
          }

          // Validasi field required
          if (nis == null || nis.isEmpty) {
            errors.add('Baris ${i + 1}: NIS tidak boleh kosong');
            errorCount++;
            continue;
          }

          if (nama == null || nama.isEmpty) {
            errors.add('Baris ${i + 1}: Nama tidak boleh kosong');
            errorCount++;
            continue;
          }

          if (kelas == null || kelas.isEmpty) {
            errors.add('Baris ${i + 1}: Kelas tidak boleh kosong');
            errorCount++;
            continue;
          }

          // Parse Tempat Tanggal Lahir
          String tempatLahir = '';
          DateTime tanggalLahir = DateTime.now();

          if (ttl != null && ttl.isNotEmpty) {
            final parts = ttl.split(',');
            if (parts.length == 2) {
              tempatLahir = parts[0].trim();
              final tanggalStr = parts[1].trim();
              final parsed = _parseTanggal(tanggalStr);
              if (parsed != null) {
                tanggalLahir = parsed;
              }
            }
          }

          // Create SiswaModel
          final siswa = SiswaModel(
            id: '', // Will be generated
            nis: nis,
            nisn: nisn ?? '',
            nama: nama,
            jenisKelamin: jenisKelamin ?? 'Laki-laki',
            tempatLahir: tempatLahir,
            tanggalLahir: tanggalLahir,
            agama: agama ?? '',
            alamat: alamat ?? '',
            namaAyah: namaAyah ?? '',
            namaIbu: namaIbu ?? '',
            // noTelpOrangTua: noHp ?? '',
            // kelas: kelas,
            // tahunMasuk: tahunMasuk,
            // status: status,
            // createdAt: DateTime.now(),
            // updatedAt: DateTime.now(),
          );

          siswaList.add(siswa);
          successCount++;
        } catch (e) {
          errors.add('Baris ${i + 1}: ${e.toString()}');
          errorCount++;
        }
      }

      return {
        'success': siswaList.isNotEmpty,
        'message': siswaList.isNotEmpty
            ? 'Berhasil memproses $successCount data siswa'
            : 'Gagal memproses data. Periksa format file Excel',
        'data': siswaList,
        'successCount': successCount,
        'errorCount': errorCount,
        'errors': errors,
      };
    } catch (e) {
      print('❌ Error import Excel: $e');
      return {
        'success': false,
        'message': 'Gagal membaca file: ${e.toString()}',
        'data': [],
        'successCount': 0,
        'errorCount': 1,
        'errors': [e.toString()],
      };
    }
  }

  // ✅ METHOD 3: DOWNLOAD TEMPLATE
  static Future<String> downloadTemplate() async {
    try {
      final excel = Excel.createExcel();
      final Sheet sheet = excel['Template Data Siswa'];

      // ✅ HEADER ROW (14 KOLOM)
      final headers = [
        'No',
        'NIS*',
        'NISN',
        'Nama Lengkap*',
        'Kelas*',
        'Jenis Kelamin',
        'Tempat, Tanggal Lahir',
        'Agama',
        'Alamat',
        'No HP/WA',
        'Nama Ayah',
        'Nama Ibu',
        'Tahun Masuk',
        'Status',
      ];

      // ✅ STYLE HEADER (FIXED - tanpa hex color)
      final headerStyle = CellStyle(bold: true, fontSize: 12);

      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }

      // ✅ EXAMPLE DATA ROW
      final exampleData = [
        '1',
        '2024001',
        '0078901234',
        'Budi Santoso',
        '7A',
        'Laki-laki',
        'Jakarta, 15-08-2010',
        'Islam',
        'Jl. Merdeka No. 123, Jakarta',
        '081234567890',
        'Santoso',
        'Dewi',
        '2024',
        'Aktif',
      ];

      for (int i = 0; i < exampleData.length; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1),
        );
        cell.value = TextCellValue(exampleData[i]);
      }

      // ✅ SHEET PETUNJUK
      final Sheet instructionSheet = excel['Petunjuk Pengisian'];

      final instructions = [
        'PETUNJUK PENGISIAN TEMPLATE DATA SISWA',
        '',
        'Kolom yang wajib diisi (bertanda *):',
        '1. NIS - Nomor Induk Siswa (contoh: 2024001)',
        '2. Nama Lengkap - Nama lengkap siswa',
        '3. Kelas - Kelas siswa (contoh: 7A, 8B, 9C)',
        '',
        'Format pengisian:',
        '- Tempat, Tanggal Lahir: Jakarta, 15-08-2010 atau Jakarta, 15/08/2010',
        '- Jenis Kelamin: Laki-laki atau Perempuan',
        '- Agama: Islam, Kristen, Katolik, Hindu, Buddha, Konghucu',
        '- Tahun Masuk: 2024 (tahun ajaran masuk)',
        '- Status: Aktif, Lulus, atau Pindah',
        '',
        'Catatan:',
        '- Jangan mengubah nama kolom pada sheet Template Data Siswa',
        '- Hapus contoh data sebelum mengisi data asli',
        '- Pastikan format tanggal: DD-MM-YYYY atau DD/MM/YYYY',
        '- NIS, Nama, dan Kelas WAJIB diisi',
        '- Jika ada error, periksa pesan error saat import',
      ];

      // ✅ STYLE UNTUK PETUNJUK (FIXED)
      final titleStyle = CellStyle(bold: true, fontSize: 14);

      final subtitleStyle = CellStyle(bold: true, fontSize: 11);

      for (int i = 0; i < instructions.length; i++) {
        final cell = instructionSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i),
        );
        cell.value = TextCellValue(instructions[i]);

        // Apply style
        if (i == 0) {
          cell.cellStyle = titleStyle;
        } else if (i == 2 || i == 7 || i == 14) {
          cell.cellStyle = subtitleStyle;
        }
      }

      // ✅ AUTO-FIT COLUMNS (optional)
      // Note: Auto-fit tidak selalu bekerja di semua versi Excel package

      // Save file
      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final filePath = '${directory.path}/template_data_siswa.xlsx';
      final List<int>? fileBytes = excel.encode();

      if (fileBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);

        print('✅ Template berhasil disimpan: $filePath');
        return filePath;
      } else {
        throw Exception('Gagal encode Excel file');
      }
    } catch (e) {
      print('❌ Error download template: $e');
      throw Exception('Gagal membuat template: ${e.toString()}');
    }
  }

  // ✅ HELPER METHOD: GET CELL VALUE (FIXED)
  static String? _getCellValue(Data? cell) {
    if (cell == null || cell.value == null) return null;

    final value = cell.value;

    if (value is TextCellValue) {
      // ✅ FIX: Langsung akses .value (string), bukan pakai .trim()
      return value.value.toString().trim();
    } else if (value is IntCellValue) {
      return value.value.toString();
    } else if (value is DoubleCellValue) {
      return value.value.toString();
    } else if (value is DateCellValue) {
      return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    } else if (value is FormulaCellValue) {
      // Handle formula cell
      return value.formula;
    }

    return value.toString();
  }

  // ✅ HELPER METHOD: PARSE TANGGAL
  static DateTime? _parseTanggal(String tanggalStr) {
    try {
      // Format: DD-MM-YYYY atau DD/MM/YYYY
      final cleaned = tanggalStr.trim();

      // Try with dash separator
      if (cleaned.contains('-')) {
        final parts = cleaned.split('-');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      }

      // Try with slash separator
      if (cleaned.contains('/')) {
        final parts = cleaned.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      }

      return null;
    } catch (e) {
      print('❌ Error parsing tanggal: $e');
      return null;
    }
  }
}
