import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/nilai_provider.dart';
import '../../../../data/models/nilai_model.dart';

class NilaiDetailScreen extends StatefulWidget {
  final String siswaId;
  final String namaSiswa;

  const NilaiDetailScreen({
    super.key,
    required this.siswaId,
    required this.namaSiswa,
  });

  @override
  State<NilaiDetailScreen> createState() => _NilaiDetailScreenState();
}

class _NilaiDetailScreenState extends State<NilaiDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNilai();
    });
  }

  Future<void> _loadNilai() async {
    final nilaiProvider = Provider.of<NilaiProvider>(context, listen: false);
    await nilaiProvider.getNilai(widget.siswaId);
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
        title: const Text('Detail Nilai'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Siswa',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  widget.namaSiswa,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                    child: Text('Belum ada nilai'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.nilaiList.length,
                  itemBuilder: (context, index) {
                    final nilai = provider.nilaiList[index];
                    final grade = _getGrade(nilai.nilaiAkhir);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getGradeColor(grade).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              grade,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _getGradeColor(grade),
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          nilai.mataPelajaran?.namaMataPelajaran ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Nilai Akhir: ${nilai.nilaiAkhir.toStringAsFixed(1)}',
                        ),
                        trailing: nilai.status == 'final'
                            ? const Icon(Icons.lock, color: Colors.green)
                            : const Icon(Icons.pending, color: Colors.orange),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildNilaiRow('Tugas 1', nilai.tugas1),
                                _buildNilaiRow('Tugas 2', nilai.tugas2),
                                _buildNilaiRow('Tugas 3', nilai.tugas3),
                                _buildNilaiRow('Tugas 4', nilai.tugas4),
                                const Divider(height: 24),
                                _buildNilaiRow('Ulangan Harian 1', nilai.uh1),
                                _buildNilaiRow('Ulangan Harian 2', nilai.uh2),
                                const Divider(height: 24),
                                _buildNilaiRow('UTS', nilai.uts, isHighlight: true),
                                _buildNilaiRow('UAS', nilai.uas, isHighlight: true),
                                const Divider(height: 24),
                                _buildNilaiRow(
                                  'NILAI AKHIR',
                                  nilai.nilaiAkhir,
                                  isFinal: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNilaiRow(
    String label,
    double? nilai, {
    bool isHighlight = false,
    bool isFinal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isFinal ? 16 : 14,
              fontWeight: isFinal ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? Colors.blue : null,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isFinal
                  ? Colors.blue.withOpacity(0.2)
                  : isHighlight
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              nilai?.toStringAsFixed(1) ?? '0.0',
              style: TextStyle(
                fontSize: isFinal ? 18 : 14,
                fontWeight: isFinal ? FontWeight.bold : FontWeight.w500,
                color: isFinal ? Colors.blue : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}