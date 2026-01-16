import 'package:flutter/material.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../data/services/supabase_service.dart';

class GuruRekapDetailScreen extends StatefulWidget {
  final String kelasId;
  final String mapelId;
  final String namaKelas;
  final String namaMapel;
  final String tahunId;

  const GuruRekapDetailScreen({
    super.key,
    required this.kelasId,
    required this.mapelId,
    required this.namaKelas,
    required this.namaMapel,
    required this.tahunId,
  });

  @override
  State<GuruRekapDetailScreen> createState() => _GuruRekapDetailScreenState();
}

class _GuruRekapDetailScreenState extends State<GuruRekapDetailScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _rekapList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRekap());
  }

  Future<void> _loadRekap() async {
    try {
      final data = await SupabaseService().getRekapNilaiKelas(
        kelasId: widget.kelasId,
        mapelId: widget.mapelId,
        tahunId: widget.tahunId,
      );
      if (mounted)
        setState(() {
          _rekapList = data;
          _isLoading = false;
        });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rekap Nilai', style: TextStyle(fontSize: 16)),
            Text(
              '${widget.namaMapel} - ${widget.namaKelas}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rekapList.isEmpty
          ? const Center(child: Text("Tidak ada siswa di kelas ini"))
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    Colors.grey.shade200,
                  ),
                  columnSpacing: 20,
                  border: TableBorder.all(color: Colors.grey.shade300),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'No',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Nama Siswa',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Tugas',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'UH',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'UTS',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'UAS',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Praktik',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'N.Akhir',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Sikap',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: List<DataRow>.generate(_rekapList.length, (index) {
                    final item = _rekapList[index];
                    final siswa = item['siswa'];
                    final nilai = item['nilai']; // Bisa null

                    // Helper ambil nilai (handle null)
                    String val(String key) =>
                        nilai != null && nilai[key] != null
                        ? nilai[key].toString()
                        : '-';

                    // Cek Nilai Akhir untuk pewarnaan
                    double nAkhir =
                        nilai != null && nilai['nilai_akhir'] != null
                        ? (nilai['nilai_akhir'] as num).toDouble()
                        : 0;
                    bool isRemedial = nAkhir < 70 && nilai != null;

                    return DataRow(
                      cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(
                          Text(
                            siswa['nama_lengkap'],
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        DataCell(Text(val('nilai_tugas'))),
                        DataCell(Text(val('nilai_uh'))),
                        DataCell(Text(val('nilai_uts'))),
                        DataCell(Text(val('nilai_uas'))),
                        DataCell(Text(val('nilai_praktik'))),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isRemedial
                                  ? Colors.red.shade100
                                  : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              val('nilai_akhir'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isRemedial
                                    ? Colors.red.shade800
                                    : Colors.green.shade800,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(val('nilai_sikap'))),
                      ],
                    );
                  }),
                ),
              ),
            ),
    );
  }
}
