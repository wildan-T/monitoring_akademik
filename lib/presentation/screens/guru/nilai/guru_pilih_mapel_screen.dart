import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/guru_provider.dart';
import '../../../providers/tahun_pelajaran_provider.dart';
import '../../../../data/services/supabase_service.dart';
import 'nilai_input_screen.dart'; // Import screen input nilai yang tadi dibuat

class GuruPilihMapelScreen extends StatefulWidget {
  const GuruPilihMapelScreen({super.key});

  @override
  State<GuruPilihMapelScreen> createState() => _GuruPilihMapelScreenState();
}

class _GuruPilihMapelScreenState extends State<GuruPilihMapelScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _listJadwal = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      final authProv = context.read<AuthProvider>();
      final guruProv = context.read<GuruProvider>();
      final tahunProv = context.read<TahunPelajaranProvider>();

      // 1. Pastikan Tahun Ajaran Aktif
      if (tahunProv.tahunList.isEmpty) await tahunProv.fetchTahunPelajaran();
      final tahunAktif = tahunProv.tahunList.firstWhere(
        (t) => t.isActive,
        orElse: () => tahunProv.tahunList.first,
      );

      // 2. Pastikan Data Guru Ada
      final guruId = guruProv.currentGuru?.id ?? '';
      if (guruId.isEmpty) {
        throw Exception("Data guru tidak ditemukan");
      }

      // 3. Ambil Jadwal Mapel
      final data = await SupabaseService().getJadwalMapelGuru(
        guruId,
        tahunAktif.id,
      );

      if (mounted) {
        setState(() {
          _listJadwal = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Kelas & Mapel'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text('Error: $_errorMessage'))
          : _listJadwal.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _listJadwal.length,
              itemBuilder: (context, index) {
                final item = _listJadwal[index];
                return _buildItemCard(item);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Anda tidak memiliki jadwal mengajar aktif',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // NAVIGASI KE INPUT NILAI
          // Kita butuh Tahun ID lagi untuk dikirim
          final tahunProv = context.read<TahunPelajaranProvider>();
          final tahunAktif = tahunProv.tahunList.firstWhere((t) => t.isActive);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GuruNilaiInputScreen(
                kelasId: item['kelas_id'],
                mapelId: item['mapel_id'],
                mapelNama: item['nama_mapel'],
                tahunId: tahunAktif.id,
                kategoriMapel: item['kategori'],
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.book, color: Colors.orange),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['nama_mapel'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Text(
                        'Kelas ${item['nama_kelas']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
