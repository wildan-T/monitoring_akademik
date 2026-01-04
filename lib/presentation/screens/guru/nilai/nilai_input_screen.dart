import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/nilai_provider.dart';
import '../../../../data/models/siswa_model.dart';

class NilaiInputScreen extends StatefulWidget {
  final String guruId;
  final String kelas;
  final String mataPelajaran;
  final List<SiswaModel> siswa;

  const NilaiInputScreen({
    super.key,
    required this.guruId,
    required this.kelas,
    required this.mataPelajaran,
    required this.siswa,
  });

  @override
  State<NilaiInputScreen> createState() => _NilaiInputScreenState();
}

class _NilaiInputScreenState extends State<NilaiInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, Map<String, TextEditingController>> _controllers = {};
  final Map<String, Map<String, dynamic>> _nilaiData = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (var siswa in widget.siswa) {
      _controllers[siswa.id] = {
        'tugas_1': TextEditingController(),
        'tugas_2': TextEditingController(),
        'tugas_3': TextEditingController(),
        'tugas_4': TextEditingController(),
        'uh_1': TextEditingController(),
        'uh_2': TextEditingController(),
        'uts': TextEditingController(),
        'uas': TextEditingController(),
      };

      _nilaiData[siswa.id] = {
        'tugas_1': 0,
        'tugas_2': 0,
        'tugas_3': 0,
        'tugas_4': 0,
        'uh_1': 0,
        'uh_2': 0,
        'uts': 0,
        'uas': 0,
        'nilai_akhir': 0,
        'status': 'draft',
      };
    }
  }

  double _calculateNilaiAkhir(Map<String, dynamic> nilai) {
    // Rumus: (Rata Tugas 20% + Rata UH 20% + UTS 30% + UAS 30%)
    final rataTugas = (nilai['tugas_1'] + nilai['tugas_2'] + nilai['tugas_3'] + nilai['tugas_4']) / 4;
    final rataUH = (nilai['uh_1'] + nilai['uh_2']) / 2;
    final uts = nilai['uts'];
    final uas = nilai['uas'];

    return (rataTugas * 0.2) + (rataUH * 0.2) + (uts * 0.3) + (uas * 0.3);
  }

  void _updateNilai(String siswaId, String key, String value) {
    final numValue = double.tryParse(value) ?? 0;
    _nilaiData[siswaId]![key] = numValue;
    _nilaiData[siswaId]!['nilai_akhir'] = _calculateNilaiAkhir(_nilaiData[siswaId]!);
    setState(() {});
  }

  Future<void> _saveNilai() async {
    if (!_formKey.currentState!.validate()) return;

    final nilaiProvider = Provider.of<NilaiProvider>(context, listen: false);

    // Get IDs (dalam real app, ambil dari database berdasarkan nama)
    final kelasId = widget.kelas; // Temporary - should get from DB
    final mataPelajaranId = widget.mataPelajaran; // Temporary - should get from DB

    final success = await nilaiProvider.saveNilai(
      kelasId: kelasId,
      mataPelajaranId: mataPelajaranId,
      guruId: widget.guruId,
      nilaiData: _nilaiData,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Nilai berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${nilaiProvider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    for (var siswaControllers in _controllers.values) {
      for (var controller in siswaControllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Nilai'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Info
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.class_, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Kelas ${widget.kelas}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.book, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      widget.mataPelajaran,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Table Headers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey[200],
            child: Row(
              children: [
                const SizedBox(width: 150, child: Text('Nama Siswa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                const SizedBox(width: 60, child: Text('T1', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                const SizedBox(width: 60, child: Text('T2', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                const SizedBox(width: 60, child: Text('T3', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                const SizedBox(width: 60, child: Text('T4', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                const SizedBox(width: 60, child: Text('UH1', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                const SizedBox(width: 60, child: Text('UH2', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                const SizedBox(width: 60, child: Text('UTS', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                const SizedBox(width: 60, child: Text('UAS', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                const SizedBox(width: 70, child: Text('NA', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              ],
            ),
          ),

          // Scrollable Table Content
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView.builder(
                itemCount: widget.siswa.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final siswa = widget.siswa[index];
                  final controllers = _controllers[siswa.id]!;
                  final nilaiAkhir = _nilaiData[siswa.id]!['nilai_akhir'];

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Nama Siswa
                        SizedBox(
                          width: 150,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                siswa.nama,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                siswa.nis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Input Fields
                        _buildNilaiField(siswa.id, 'tugas_1', controllers['tugas_1']!),
                        _buildNilaiField(siswa.id, 'tugas_2', controllers['tugas_2']!),
                        _buildNilaiField(siswa.id, 'tugas_3', controllers['tugas_3']!),
                        _buildNilaiField(siswa.id, 'tugas_4', controllers['tugas_4']!),
                        _buildNilaiField(siswa.id, 'uh_1', controllers['uh_1']!),
                        _buildNilaiField(siswa.id, 'uh_2', controllers['uh_2']!),
                        _buildNilaiField(siswa.id, 'uts', controllers['uts']!),
                        _buildNilaiField(siswa.id, 'uas', controllers['uas']!),

                        // Nilai Akhir (Auto-calculated)
                        SizedBox(
                          width: 70,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              nilaiAkhir.toStringAsFixed(1),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Bottom Save Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Consumer<NilaiProvider>(
              builder: (context, provider, _) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : _saveNilai,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Simpan Nilai',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNilaiField(String siswaId, String key, TextEditingController controller) {
    return SizedBox(
      width: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            isDense: true,
          ),
          onChanged: (value) => _updateNilai(siswaId, key, value),
          validator: (value) {
            if (value == null || value.isEmpty) return null;
            final num = double.tryParse(value);
            if (num == null || num < 0 || num > 100) {
              return 'Invalid';
            }
            return null;
          },
        ),
      ),
    );
  }
}