import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../data/models/kelas_model.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../providers/kelas_provider.dart';
import '../../../providers/tahun_pelajaran_provider.dart';
import 'admin_nilai_detail_screen.dart'; // Kita buat di langkah 3

class AdminNilaiMenuScreen extends StatefulWidget {
  const AdminNilaiMenuScreen({super.key});

  @override
  State<AdminNilaiMenuScreen> createState() => _AdminNilaiMenuScreenState();
}

class _AdminNilaiMenuScreenState extends State<AdminNilaiMenuScreen> {
  bool _isLoadingMapel = false;

  KelasModel? _selectedKelas;
  Map<String, dynamic>? _selectedMapel;
  List<Map<String, dynamic>> _listMapel = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final tahunProv = context.read<TahunPelajaranProvider>();
    final kelasProv = context.read<KelasProvider>();

    if (tahunProv.tahunList.isEmpty) await tahunProv.fetchTahunPelajaran();
    // Ambil SEMUA kelas (Admin mode)
    await kelasProv.fetchAllKelas();
  }

  // Load Mapel ketika Kelas dipilih
  Future<void> _loadMapelByKelas(String kelasId) async {
    setState(() {
      _isLoadingMapel = true;
      _selectedMapel = null;
      _listMapel = [];
    });

    try {
      final tahunProv = context.read<TahunPelajaranProvider>();
      final tahunAktif = tahunProv.tahunList.firstWhere((t) => t.isActive);

      // Gunakan service yang sudah ada
      final data = await SupabaseService().getMapelDiKelas(
        kelasId,
        tahunAktif.id,
      );

      setState(() => _listMapel = data);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoadingMapel = false);
    }
  }

  void _bukaRekapNilai() {
    if (_selectedKelas == null || _selectedMapel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon pilih Kelas dan Mata Pelajaran')),
      );
      return;
    }

    final tahunProv = context.read<TahunPelajaranProvider>();
    final tahunAktif = tahunProv.tahunList.firstWhere((t) => t.isActive);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminNilaiDetailScreen(
          kelasId: _selectedKelas!.id,
          mapelId: _selectedMapel!['id'],
          namaKelas: _selectedKelas!.namaKelas,
          namaMapel: _selectedMapel!['nama_mapel'],
          tahunId: tahunAktif.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kelasProv = context.watch<KelasProvider>();
    final tahunProv = context.watch<TahunPelajaranProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Nilai Siswa'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. INFO TAHUN AJARAN
            if (tahunProv.tahunList.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.blue),
                    const SizedBox(width: 10),
                    Text(
                      "Tahun Aktif: ${tahunProv.tahunList.firstWhere((t) => t.isActive).tahun} (Sem ${tahunProv.tahunList.firstWhere((t) => t.isActive).semester})",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

            // 2. PILIH KELAS
            const Text(
              "Pilih Kelas",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<KelasModel>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              value: _selectedKelas,
              hint: const Text("Pilih Kelas..."),
              items: kelasProv.kelasList.map((kelas) {
                return DropdownMenuItem(
                  value: kelas,
                  child: Text("Kelas ${kelas.namaKelas}"),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedKelas = val);
                  _loadMapelByKelas(val.id);
                }
              },
            ),
            const SizedBox(height: 20),

            // 3. PILIH MAPEL
            const Text(
              "Pilih Mata Pelajaran",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _isLoadingMapel
                ? const LinearProgressIndicator()
                : DropdownButtonFormField<Map<String, dynamic>>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    value: _selectedMapel,
                    hint: Text(
                      _selectedKelas == null
                          ? "Pilih kelas dulu"
                          : "Pilih Mapel...",
                    ),
                    items: _listMapel.map((mapel) {
                      return DropdownMenuItem(
                        value: mapel,
                        child: Text(mapel['nama_mapel']),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedMapel = val);
                    },
                  ),

            const Spacer(),

            // 4. TOMBOL LIHAT DATA
            ElevatedButton.icon(
              onPressed: _bukaRekapNilai,
              icon: const Icon(Icons.table_view),
              label: const Text("LIHAT DATA NILAI"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
