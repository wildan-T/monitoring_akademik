import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../providers/tahun_pelajaran_provider.dart';

class WaliAbsensiScreen extends StatefulWidget {
  final String siswaId;
  const WaliAbsensiScreen({super.key, required this.siswaId});

  @override
  State<WaliAbsensiScreen> createState() => _WaliAbsensiScreenState();
}

class _WaliAbsensiScreenState extends State<WaliAbsensiScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _absensiList = [];
  Map<String, int> _summary = {'H': 0, 'S': 0, 'I': 0, 'A': 0};

  @override
  void initState() {
    super.initState();
    _loadAbsen();
  }

  Future<void> _loadAbsen() async {
    final tahunProv = context.read<TahunPelajaranProvider>();
    final tahunAktif = tahunProv.tahunList.firstWhere((t) => t.isActive);
    final data = await SupabaseService().getAbsensiSiswa(
      widget.siswaId,
      tahunAktif.id,
    );

    // Hitung Summary
    for (var item in data) {
      final status = item['status'] ?? 'A';
      if (_summary.containsKey(status)) {
        _summary[status] = (_summary[status] ?? 0) + 1;
      }
    }

    if (mounted)
      setState(() {
        _absensiList = data;
        _isLoading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Absensi"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // SUMMARY CARD
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statusBadge('Hadir', _summary['H']!, Colors.green),
                _statusBadge('Sakit', _summary['S']!, Colors.orange),
                _statusBadge('Izin', _summary['I']!, Colors.blue),
                _statusBadge('Alpha', _summary['A']!, Colors.red),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _absensiList.isEmpty
                ? const Center(child: Text("Belum ada data absensi"))
                : ListView.builder(
                    itemCount: _absensiList.length,
                    itemBuilder: (context, index) {
                      final item = _absensiList[index];
                      final status = item['status'];
                      Color color = status == 'H'
                          ? Colors.green
                          : status == 'S'
                          ? Colors.orange
                          : status == 'I'
                          ? Colors.blue
                          : Colors.red;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color,
                          radius: 15,
                          child: Text(
                            status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          item['mata_pelajaran']?['nama_mapel'] ?? 'Mapel Lain',
                        ),
                        subtitle: Text(item['tanggal']),
                        trailing: Text(
                          status == 'H'
                              ? 'Hadir'
                              : status == 'S'
                              ? 'Sakit'
                              : status == 'I'
                              ? 'Izin'
                              : 'Tanpa Ket.',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
