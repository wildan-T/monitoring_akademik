import 'package:flutter/material.dart';
import 'package:monitoring_akademik/core/constants/color_constants.dart';
import 'package:monitoring_akademik/data/models/nilai_model.dart';
import 'package:monitoring_akademik/presentation/providers/nilai_provider.dart';
import 'package:provider/provider.dart';
//import '../../../core/constants/color_constants.dart';
import '../../../../data/models/nilai_model.dart';
//import '../../../presentation/providers/nilai_provider.dart';

class NilaiEditScreen extends StatefulWidget {
  final NilaiModel nilai;

  const NilaiEditScreen({Key? key, required this.nilai}) : super(key: key);

  @override
  State<NilaiEditScreen> createState() => _NilaiEditScreenState();
}

class _NilaiEditScreenState extends State<NilaiEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nilaiTugasController;
  late TextEditingController _nilaiUHController;
  late TextEditingController _nilaiUTSController;
  late TextEditingController _nilaiUASController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nilaiTugasController = TextEditingController(
      text: widget.nilai.nilaiTugas?.toStringAsFixed(0) ?? '0',
    );
    _nilaiUHController = TextEditingController(
      text: widget.nilai.nilaiUH?.toStringAsFixed(0) ?? '0',
    );
    _nilaiUTSController = TextEditingController(
      text: widget.nilai.nilaiUTS?.toStringAsFixed(0) ?? '0',
    );
    _nilaiUASController = TextEditingController(
      text: widget.nilai.nilaiUAS?.toStringAsFixed(0) ?? '0',
    );
  }

  @override
  void dispose() {
    _nilaiTugasController.dispose();
    _nilaiUHController.dispose();
    _nilaiUTSController.dispose();
    _nilaiUASController.dispose();
    super.dispose();
  }

  double _calculateNilaiAkhir() {
    final tugas = double.tryParse(_nilaiTugasController.text) ?? 0;
    final uh = double.tryParse(_nilaiUHController.text) ?? 0;
    final uts = double.tryParse(_nilaiUTSController.text) ?? 0;
    final uas = double.tryParse(_nilaiUASController.text) ?? 0;

    // Formula: (Tugas * 20%) + (UH * 30%) + (UTS * 20%) + (UAS * 30%)
    return (tugas * 0.2) + (uh * 0.3) + (uts * 0.2) + (uas * 0.3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Edit Nilai'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info Siswa Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            widget.nilai.namaSiswa[0].toUpperCase(),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.nilai.namaSiswa,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Kelas ${widget.nilai.kelas}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.nilai.mataPelajaran,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Form Input Nilai
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Input Nilai',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nilai Tugas
                    _buildNilaiField(
                      controller: _nilaiTugasController,
                      label: 'Nilai Tugas',
                      hint: 'Masukkan nilai tugas (0-100)',
                      icon: Icons.assignment,
                    ),

                    const SizedBox(height: 16),

                    // Nilai Ulangan Harian
                    _buildNilaiField(
                      controller: _nilaiUHController,
                      label: 'Nilai Ulangan Harian (UH)',
                      hint: 'Masukkan nilai UH (0-100)',
                      icon: Icons.quiz,
                    ),

                    const SizedBox(height: 16),

                    // Nilai UTS
                    _buildNilaiField(
                      controller: _nilaiUTSController,
                      label: 'Nilai UTS',
                      hint: 'Masukkan nilai UTS (0-100)',
                      icon: Icons.edit_note,
                    ),

                    const SizedBox(height: 16),

                    // Nilai UAS
                    _buildNilaiField(
                      controller: _nilaiUASController,
                      label: 'Nilai UAS',
                      hint: 'Masukkan nilai UAS (0-100)',
                      icon: Icons.description,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Preview Nilai Akhir
            Card(
              color: AppColors.primary.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Preview Nilai Akhir',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _calculateNilaiAkhir().toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Formula: (Tugas × 20%) + (UH × 30%) + (UTS × 20%) + (UAS × 30%)',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Simpan
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveNilai,
                icon:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.save),
                label: Text(_isLoading ? 'Menyimpan...' : 'Simpan Perubahan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNilaiField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Nilai tidak boleh kosong';
        }

        final nilai = double.tryParse(value);
        if (nilai == null) {
          return 'Nilai harus berupa angka';
        }

        if (nilai < 0 || nilai > 100) {
          return 'Nilai harus antara 0-100';
        }

        return null;
      },
      onChanged: (value) {
        // Update preview nilai akhir
        setState(() {});
      },
    );
  }

  Future<void> _saveNilai() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<NilaiProvider>(context, listen: false);

      // ✅ FIX: Buat Map data update, mapping input ke field tugas1, uh1, dll
      final updateData = {
        'tugas1': double.tryParse(_nilaiTugasController.text),
        'uh1': double.tryParse(_nilaiUHController.text),
        'uts': double.tryParse(_nilaiUTSController.text),
        'uas': double.tryParse(_nilaiUASController.text),
        'nilai_akhir': _calculateNilaiAkhir(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // ✅ FIX: Panggil updateNilai dengan ID dan Map
      final success = await provider.updateNilai(widget.nilai.id, updateData);
      ;

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nilai berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Gagal memperbarui nilai'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
