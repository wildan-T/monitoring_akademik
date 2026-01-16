import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../providers/guru_provider.dart';
import '../../../providers/tahun_pelajaran_provider.dart';
import 'guru_input_absensi_screen.dart';

class GuruAbsensiMenuScreen extends StatefulWidget {
  const GuruAbsensiMenuScreen({super.key});

  @override
  State<GuruAbsensiMenuScreen> createState() => _GuruAbsensiMenuScreenState();
}

class _GuruAbsensiMenuScreenState extends State<GuruAbsensiMenuScreen> {
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

      // Menggunakan fungsi yang sama dengan Input Nilai (Reuse Code)
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
      print("Error load menu absensi: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Kelas untuk Absensi'),
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
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade50,
                      child: const Icon(Icons.class_, color: Colors.orange),
                    ),
                    title: Text(
                      item['nama_mapel'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Kelas ${item['nama_kelas']}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // BUKA INPUT ABSENSI
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GuruInputAbsensiScreen(
                            kelasId: item['kelas_id'],
                            mapelId: item['mapel_id'], // ✅ Kirim Mapel ID
                            namaKelas: item['nama_kelas'],
                            namaMapel: item['nama_mapel'],
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
