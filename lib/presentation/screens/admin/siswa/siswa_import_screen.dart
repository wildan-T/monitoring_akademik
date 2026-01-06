//C:\Users\MSITHIN\monitoring_akademik\lib\presentation\screens\admin\siswa\siswa_import_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:monitoring_akademik/core/constants/color_constants.dart';
import 'package:monitoring_akademik/data/services/siswa_import_service.dart';
import 'package:monitoring_akademik/presentation/providers/siswa_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

class SiswaImportScreen extends StatefulWidget {
  const SiswaImportScreen({Key? key}) : super(key: key);

  @override
  State<SiswaImportScreen> createState() => _SiswaImportScreenState();
}

class _SiswaImportScreenState extends State<SiswaImportScreen> {
  File? _selectedFile;
  bool _isLoading = false;
  Map<String, dynamic>? _importResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Data Siswa'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ 1. DOWNLOAD TEMPLATE CARD
            _buildDownloadTemplateCard(),

            const SizedBox(height: 16),

            // ✅ 2. SELECT FILE CARD
            _buildSelectFileCard(),

            const SizedBox(height: 16),

            // ✅ 3. PREVIEW/RESULT CARD
            if (_importResult != null) _buildResultCard(),

            const SizedBox(height: 24),

            // ✅ 4. IMPORT BUTTON
            if (_selectedFile != null && _importResult == null)
              ElevatedButton(
                onPressed: _isLoading ? null : _processImport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          'PROSES IMPORT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),

            // ✅ 5. SAVE TO DATABASE BUTTON
            if (_importResult != null && _importResult!['success'] == true)
              ElevatedButton(
                onPressed: _isLoading ? null : _saveToDatabase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          'SIMPAN KE DATABASE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
          ],
        ),
      ),
    );
  }

  // ✅ BUILD: Download Template Card
  Widget _buildDownloadTemplateCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.download, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Template Excel',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Download template Excel terlebih dahulu untuk melihat format data yang benar.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _downloadTemplate,
              icon: const Icon(Icons.file_download),
              label: const Text('Download Template'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ BUILD: Select File Card
  Widget _buildSelectFileCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.upload_file, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Pilih File Excel',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_selectedFile == null)
              const Text(
                'Pilih file Excel (.xlsx atau .xls) yang berisi data siswa.',
                style: TextStyle(color: Colors.grey),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'File terpilih:',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            _selectedFile!.path.split('/').last,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedFile = null;
                          _importResult = null;
                        });
                      },
                      icon: const Icon(Icons.close, color: Colors.red),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.folder_open),
              label: Text(_selectedFile == null ? 'Pilih File' : 'Ganti File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ BUILD: Result Card
  Widget _buildResultCard() {
    final result = _importResult!;
    final success = result['success'] as bool;
    final message = result['message'] as String;
    final successCount = result['successCount'] as int? ?? 0;
    final errorCount = result['errorCount'] as int? ?? 0;
    final errors = result['errors'] as List<String>? ?? [];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: success ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Hasil Import',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    success
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message,
                style: TextStyle(
                  color: success ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            if (success) ...[
              const SizedBox(height: 16),

              // Statistics
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Berhasil',
                      successCount.toString(),
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Gagal',
                      errorCount.toString(),
                      Colors.red,
                    ),
                  ),
                ],
              ),

              // Errors list
              if (errors.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Detail Error:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        errors
                            .map(
                              (error) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '• $error',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  // ✅ BUILD: Stat Card
  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  // ✅ FUNCTION: Download Template
  Future<void> _downloadTemplate() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final filePath = await SiswaImportService.downloadTemplate();

      if (mounted) {
        Navigator.pop(context);

        // Open file
        await OpenFile.open(filePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Template berhasil didownload: $filePath'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'BUKA',
              textColor: Colors.white,
              onPressed: () => OpenFile.open(filePath),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal download template: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ✅ FUNCTION: Pick File
  Future<void> _pickFile() async {
    final file = await SiswaImportService.pickExcelFile();

    if (file != null) {
      setState(() {
        _selectedFile = file;
        _importResult = null; // Reset result
      });
    }
  }

  // ✅ FUNCTION: Process Import
  Future<void> _processImport() async {
    if (_selectedFile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await SiswaImportService.importFromExcel(_selectedFile!);

      setState(() {
        _importResult = result;
        _isLoading = false;
      });

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ File berhasil diproses!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ✅ FUNCTION: Save To Database
  Future<void> _saveToDatabase() async {
    if (_importResult == null || _importResult!['data'] == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<SiswaProvider>(context, listen: false);
      final siswaList = _importResult!['data'] as List;

      int savedCount = 0;
      for (var siswa in siswaList) {
        final success = await provider.createSiswa(siswa);
        if (success) savedCount++;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Berhasil menyimpan $savedCount data siswa'),
            backgroundColor: Colors.green,
          ),
        );

        // Kembali ke halaman sebelumnya
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
