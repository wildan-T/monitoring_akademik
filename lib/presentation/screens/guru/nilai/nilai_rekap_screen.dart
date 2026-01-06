import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/nilai_provider.dart';
import '../../../../data/models/nilai_model.dart';

class NilaiRekapScreen extends StatefulWidget {
  final String kelas;
  final String mataPelajaran;

  const NilaiRekapScreen({
    super.key,
    required this.kelas,
    required this.mataPelajaran,
  });

  @override
  State<NilaiRekapScreen> createState() => _NilaiRekapScreenState();
}

class _NilaiRekapScreenState extends State<NilaiRekapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNilai();
    });
  }

  Future<void> _loadNilai() async {
    final nilaiProvider = Provider.of<NilaiProvider>(context, listen: false);

    // Get IDs (dalam real app, ambil dari database)
    final kelasId = widget.kelas;
    final mataPelajaranId = widget.mataPelajaran;

    await nilaiProvider.fetchNilaiByKelasAndMapel(
      kelasId: kelasId,
      mataPelajaranId: mataPelajaranId,
    );
  }

  String _getGrade(double nilai) {
    if (nilai >= 90) return 'A';
    if (nilai >= 80) return 'B';
    if (nilai >= 70) return 'C';
    if (nilai >= 60) return 'D';
    return 'E';
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      case 'E':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap Nilai'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // TODO: Export to PDF/Excel
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon')),
              );
            },
            tooltip: 'Export',
          ),
        ],
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

          // Table
          Expanded(
            child: Consumer<NilaiProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.nilaiList.isEmpty) {
                  return const Center(child: Text('Belum ada data nilai'));
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columnSpacing: 20,
                      headingRowColor: MaterialStateProperty.all(
                        Colors.grey[200],
                      ),
                      columns: const [
                        DataColumn(
                          label: Text(
                            'No',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Nama Siswa',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'NIS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'T1',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'T2',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'T3',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'T4',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'UH1',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'UH2',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'UTS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'UAS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'NA',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Grade',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                      rows:
                          provider.nilaiList.asMap().entries.map((entry) {
                            final index = entry.key;
                            final nilai = entry.value;
                            final grade = _getGrade(nilai.nilaiAkhir ?? 0.0);
                            final namaSiswa =
                                nilai.siswa['nama']?.toString() ?? '-';
                            final nisSiswa =
                                nilai.siswa['nis']?.toString() ?? '-';

                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    '${index + 1}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                      namaSiswa,
                                      style: const TextStyle(fontSize: 12),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    nisSiswa,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    nilai.tugas1?.toString() ?? '0',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    nilai.tugas2?.toString() ?? '0',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    nilai.tugas3?.toString() ?? '0',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    nilai.tugas4?.toString() ?? '0',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    nilai.uh1?.toString() ?? '0',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    nilai.uh2?.toString() ?? '0',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    nilai.uts?.toString() ?? '0',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    nilai.uas?.toString() ?? '0',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    (nilai.nilaiAkhir ?? 0).toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getGradeColor(
                                        grade,
                                      ).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      grade,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                        color: _getGradeColor(grade),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Actions
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
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Kembali'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Consumer<NilaiProvider>(
                    builder: (context, provider, _) {
                      return ElevatedButton.icon(
                        onPressed:
                            provider.isLoading
                                ? null
                                : () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text('Finalisasi Nilai'),
                                          content: const Text(
                                            'Nilai yang sudah difinalisasi tidak dapat diubah lagi. Lanjutkan?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    false,
                                                  ),
                                              child: const Text('Batal'),
                                            ),
                                            ElevatedButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    true,
                                                  ),
                                              child: const Text('Finalisasi'),
                                            ),
                                          ],
                                        ),
                                  );

                                  if (confirm == true && mounted) {
                                    final success = await provider
                                        .finalisasiNilai(
                                          kelasId: widget.kelas,
                                          mataPelajaranId: widget.mataPelajaran,
                                        );

                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            success
                                                ? '✅ Nilai berhasil difinalisasi'
                                                : '❌ Gagal finalisasi nilai',
                                          ),
                                          backgroundColor:
                                              success
                                                  ? Colors.green
                                                  : Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Finalisasi'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
