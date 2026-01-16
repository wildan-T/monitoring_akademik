import 'package:flutter/material.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../data/services/supabase_service.dart';

class AdminNilaiDetailScreen extends StatefulWidget {
  final String kelasId;
  final String mapelId;
  final String namaKelas;
  final String namaMapel;
  final String tahunId;

  const AdminNilaiDetailScreen({
    super.key,
    required this.kelasId,
    required this.mapelId,
    required this.namaKelas,
    required this.namaMapel,
    required this.tahunId,
  });

  @override
  State<AdminNilaiDetailScreen> createState() => _AdminNilaiDetailScreenState();
}

class _AdminNilaiDetailScreenState extends State<AdminNilaiDetailScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _rekapList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    try {
      final data = await SupabaseService().getAdminRekapNilai(
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
            const Text('Rekap Nilai Siswa'),
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
          ? const Center(child: Text("Tidak ada data siswa"))
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
                        'NISN',
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
                        'Predikat',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: List<DataRow>.generate(_rekapList.length, (index) {
                    final item = _rekapList[index];
                    final siswa = item['siswa'];
                    final nilai = item['nilai'];

                    String val(String key) =>
                        nilai != null && nilai[key] != null
                        ? nilai[key].toString()
                        : '-';

                    double nAkhir =
                        nilai != null && nilai['nilai_akhir'] != null
                        ? (nilai['nilai_akhir'] as num).toDouble()
                        : 0;

                    // Hitung Predikat Simple
                    String predikat = 'E';
                    if (nAkhir >= 90)
                      predikat = 'A';
                    else if (nAkhir >= 80)
                      predikat = 'B';
                    else if (nAkhir >= 70)
                      predikat = 'C';
                    else if (nAkhir >= 60)
                      predikat = 'D';

                    return DataRow(
                      cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(Text(siswa['nisn'] ?? '-')),
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
                              color: nAkhir >= 70
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              val('nilai_akhir'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Text(
                              nilai == null ? '-' : predikat,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
    );
  }
}
