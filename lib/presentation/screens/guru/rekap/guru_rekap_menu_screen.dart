import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/guru_provider.dart';
import '../../../providers/tahun_pelajaran_provider.dart';
import '../../../../data/services/supabase_service.dart';
import 'guru_rekap_detail_screen.dart'; // Nanti kita buat di langkah 3

class GuruRekapMenuScreen extends StatefulWidget {
  const GuruRekapMenuScreen({super.key});

  @override
  State<GuruRekapMenuScreen> createState() => _GuruRekapMenuScreenState();
}

class _GuruRekapMenuScreenState extends State<GuruRekapMenuScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _listJadwal = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    try {
      final guruProv = context.read<GuruProvider>();
      final tahunProv = context.read<TahunPelajaranProvider>();

      if (tahunProv.tahunList.isEmpty) await tahunProv.fetchTahunPelajaran();
      final tahunAktif = tahunProv.tahunList.firstWhere((t) => t.isActive);

      final guruId = guruProv.currentGuru?.id ?? '';

      // Reuse fungsi getJadwalMapelGuru yg sudah ada
      final data = await SupabaseService().getJadwalMapelGuru(
        guruId,
        tahunAktif.id,
      );

      if (mounted)
        setState(() {
          _listJadwal = data;
          _isLoading = false;
        });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print("Error load menu rekap: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Kelas untuk Rekap'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _listJadwal.isEmpty
          ? const Center(child: Text("Tidak ada jadwal mengajar aktif"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _listJadwal.length,
              itemBuilder: (ctx, index) {
                final item = _listJadwal[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.table_chart, color: Colors.blue),
                    ),
                    title: Text(
                      item['nama_mapel'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Kelas ${item['nama_kelas']}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // NAVIGASI KE DETAIL REKAP
                      final tahunProv = context.read<TahunPelajaranProvider>();
                      final tahunAktif = tahunProv.tahunList.firstWhere(
                        (t) => t.isActive,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GuruRekapDetailScreen(
                            kelasId: item['kelas_id'],
                            mapelId: item['mapel_id'],
                            namaKelas: item['nama_kelas'],
                            namaMapel: item['nama_mapel'],
                            tahunId: tahunAktif.id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
