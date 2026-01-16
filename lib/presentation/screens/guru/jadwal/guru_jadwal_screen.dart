import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/jadwal_model.dart';
import '../../../providers/guru_provider.dart';
import '../../../providers/jadwal_provider.dart';
import '../../../providers/tahun_pelajaran_provider.dart';
import '../../../../core/constants/color_constants.dart';

class GuruJadwalScreen extends StatefulWidget {
  const GuruJadwalScreen({super.key});

  @override
  State<GuruJadwalScreen> createState() => _GuruJadwalScreenState();
}

class _GuruJadwalScreenState extends State<GuruJadwalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _days.length, vsync: this);

    // Auto fetch saat masuk layar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJadwal();
    });
  }

  Future<void> _loadJadwal() async {
    final guruProv = context.read<GuruProvider>();
    final tahunProv = context.read<TahunPelajaranProvider>();
    final jadwalProv = context.read<JadwalProvider>();

    // 1. Pastikan Tahun Ajaran & Guru Loaded
    if (tahunProv.tahunList.isEmpty) await tahunProv.fetchTahunPelajaran();

    // Cari Tahun Aktif
    String? tahunAktifId;
    try {
      tahunAktifId = tahunProv.tahunList.firstWhere((t) => t.isActive).id;
    } catch (_) {}

    if (guruProv.currentGuru != null && tahunAktifId != null) {
      await jadwalProv.fetchJadwalGuru(
        guruId: guruProv.currentGuru!.id,
        tahunPelajaranId: tahunAktifId,
      );
    }

    if (mounted) setState(() => _isInit = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Mengajar'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, // Agar tab bisa digeser jika layar kecil
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _days.map((day) => Tab(text: day)).toList(),
        ),
      ),
      body: _isInit
          ? const Center(child: CircularProgressIndicator())
          : Consumer<JadwalProvider>(
              builder: (context, jadwalProv, _) {
                if (jadwalProv.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Jika Jadwal Kosong Total
                if (jadwalProv.jadwalGuru.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text('Belum ada jadwal mengajar'),
                      ],
                    ),
                  );
                }

                return TabBarView(
                  controller: _tabController,
                  children: _days.map((day) {
                    return _buildJadwalList(day, jadwalProv.jadwalGuru);
                  }).toList(),
                );
              },
            ),
    );
  }

  Widget _buildJadwalList(String hari, List<JadwalModel> allJadwal) {
    // Filter jadwal hanya untuk hari tab ini
    final jadwalHariIni = allJadwal.where((j) => j.hari == hari).toList();

    if (jadwalHariIni.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada jadwal hari $hari',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jadwalHariIni.length,
      itemBuilder: (context, index) {
        final jadwal = jadwalHariIni[index];
        // Format jam HH:mm (hapus detik)
        final jamMulai = jadwal.jamMulai.length >= 5
            ? jadwal.jamMulai.substring(0, 5)
            : jadwal.jamMulai;
        final jamSelesai = jadwal.jamSelesai.length >= 5
            ? jadwal.jamSelesai.substring(0, 5)
            : jadwal.jamSelesai;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Kolom Jam (Kiri)
                Column(
                  children: [
                    Text(
                      jamMulai,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      height: 20,
                      width: 2,
                      color: Colors.grey.shade300,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                    Text(
                      jamSelesai,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Garis Vertikal Warna
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 16),

                // Info Mapel & Kelas
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jadwal.namaMapel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.class_outlined,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Kelas ${jadwal.namaKelas}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
