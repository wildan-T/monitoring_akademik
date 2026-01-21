import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../providers/tahun_pelajaran_provider.dart';

class WaliJadwalScreen extends StatefulWidget {
  final String kelasId;
  const WaliJadwalScreen({super.key, required this.kelasId});

  @override
  State<WaliJadwalScreen> createState() => _WaliJadwalScreenState();
}

class _WaliJadwalScreenState extends State<WaliJadwalScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _jadwalList = [];

  @override
  void initState() {
    super.initState();
    _loadJadwal();
  }

  Future<void> _loadJadwal() async {
    final tahunProv = context.read<TahunPelajaranProvider>();
    final tahunAktif = tahunProv.tahunList.firstWhere((t) => t.isActive);
    final data = await SupabaseService().getJadwalSiswa(
      widget.kelasId,
      tahunAktif.id,
    );
    if (mounted)
      setState(() {
        _jadwalList = data;
        _isLoading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jadwal Pelajaran"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _jadwalList.isEmpty
          ? const Center(child: Text("Jadwal belum tersedia"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _jadwalList.length,
              itemBuilder: (context, index) {
                final item = _jadwalList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: Text(
                        item['hari'].toString().substring(0, 2).toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(item['mata_pelajaran']?['nama_mapel'] ?? '-'),
                    subtitle: Text(
                      "${item['hari']} | ${item['jam_mulai']} - ${item['jam_selesai']}",
                    ),
                    trailing: Text(
                      item['guru']?['nama_lengkap'] ?? 'Guru ?',
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
