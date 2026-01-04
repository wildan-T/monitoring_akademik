import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/nilai_provider.dart';
import '../../../providers/siswa_provider.dart';
import '../../../../data/models/siswa_model.dart';

class FinalisasiNilaiScreen extends StatefulWidget {
  const FinalisasiNilaiScreen({super.key});

  @override
  State<FinalisasiNilaiScreen> createState() => _FinalisasiNilaiScreenState();
}

class _FinalisasiNilaiScreenState extends State<FinalisasiNilaiScreen> {
  String? _selectedKelas;
  String? _selectedMataPelajaran;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (_selectedKelas == null) return;

    final siswaProvider = Provider.of<SiswaProvider>(context, listen: false);
    await siswaProvider.fetchAllSiswa();

    if (_selectedMataPelajaran != null) {
      final nilaiProvider = Provider.of<NilaiProvider>(context, listen: false);
      await nilaiProvider.fetchNilaiByKelasAndMapel(
        kelasId: _selectedKelas!,
        mataPelajaranId: _selectedMataPelajaran!,
      );
    }
  }

  Future<void> _finalisasi() async {
    if (_selectedKelas == null || _selectedMataPelajaran == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kelas dan mata pelajaran')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Finalisasi'),
        content: const Text(
          'Nilai yang sudah difinalisasi tidak dapat diubah lagi. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Ya, Finalisasi'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final nilaiProvider = Provider.of<NilaiProvider>(context, listen: false);
    final success = await nilaiProvider.finalisasiNilai(
      kelasId: _selectedKelas!,
      mataPelajaranId: _selectedMataPelajaran!,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? '✅ Nilai berhasil difinalisasi' : '❌ Gagal finalisasi nilai',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalisasi Nilai'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedKelas,
                  decoration: const InputDecoration(
                    labelText: 'Kelas',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: ['7A', '7B', '8A', '8B', '9A', '9B']
                      .map((kelas) => DropdownMenuItem(
                            value: kelas,
                            child: Text(kelas),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedKelas = value;
                      _loadData();
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedMataPelajaran,
                  decoration: const InputDecoration(
                    labelText: 'Mata Pelajaran',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: [
                    'Matematika',
                    'Bahasa Indonesia',
                    'IPA',
                    'IPS',
                    'Bahasa Inggris'
                  ]
                      .map((mapel) => DropdownMenuItem(
                            value: mapel,
                            child: Text(mapel),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMataPelajaran = value;
                      _loadData();
                    });
                  },
                ),
              ],
            ),
          ),

          // Nilai List
          Expanded(
            child: Consumer<NilaiProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.nilaiList.isEmpty) {
                  return const Center(
                    child: Text('Belum ada data nilai untuk kelas ini'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.nilaiList.length,
                  itemBuilder: (context, index) {
                    final nilai = provider.nilaiList[index];
                    final grade = nilai.nilaiAkhir >= 90
                        ? 'A'
                        : nilai.nilaiAkhir >= 80
                            ? 'B'
                            : nilai.nilaiAkhir >= 70
                                ? 'C'
                                : nilai.nilaiAkhir >= 60
                                    ? 'D'
                                    : 'E';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text(
                          nilai.siswa?.nama ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('NIS: ${nilai.siswa?.nis ?? '-'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  nilai.nilaiAkhir.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  'Grade: $grade',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              nilai.status == 'final'
                                  ? Icons.check_circle
                                  : Icons.pending,
                              color: nilai.status == 'final'
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Bottom Button
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
                final allFinal = provider.nilaiList.every((n) => n.status == 'final');

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: provider.isLoading || allFinal ? null : _finalisasi,
                    icon: Icon(allFinal ? Icons.check_circle : Icons.lock),
                    label: Text(
                      allFinal ? 'Sudah Difinalisasi' : 'Finalisasi Nilai',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: allFinal ? Colors.grey : Colors.green,
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
}