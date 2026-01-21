import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monitoring_akademik/core/constants/color_constants.dart';
import 'package:monitoring_akademik/core/constants/route_constants.dart';
import 'package:monitoring_akademik/presentation/providers/auth_provider.dart';
import 'package:monitoring_akademik/presentation/providers/tahun_pelajaran_provider.dart';
import '../../../../data/services/supabase_service.dart';

// Import Screen Fitur
import 'features/wali_profil_screen.dart';
import 'features/wali_nilai_screen.dart';
import 'features/wali_jadwal_screen.dart';
import 'features/wali_absensi_screen.dart';

class WaliMuridDashboardScreen extends StatefulWidget {
  const WaliMuridDashboardScreen({super.key});

  @override
  State<WaliMuridDashboardScreen> createState() =>
      _WaliMuridDashboardScreenState();
}

class _WaliMuridDashboardScreenState extends State<WaliMuridDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _siswaData; // Data anak yang terhubung

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDataAnak());
  }

  Future<void> _loadDataAnak() async {
    final authProv = context.read<AuthProvider>();
    final tahunProv = context.read<TahunPelajaranProvider>();

    try {
      // 1. Load Tahun Pelajaran jika belum
      if (tahunProv.tahunList.isEmpty) await tahunProv.fetchTahunPelajaran();

      // 2. Cari Siswa berdasarkan akun login
      if (authProv.currentUser != null) {
        final data = await SupabaseService().getSiswaByWaliId(
          authProv.currentUser!.id,
        );
        print('Data: $data');
        if (mounted) {
          setState(() {
            _siswaData = data;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print("Error dashboard wali: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Wali Murid'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Apakah Anda yakin ingin logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && context.mounted) {
                await authProvider.logout();
                Navigator.of(
                  context,
                ).pushReplacementNamed(RouteConstants.login);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _siswaData == null
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.secondary,
                            child: const Icon(
                              Icons.person,
                              size: 30,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selamat Datang,',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  authProvider.currentUser?.name ??
                                      'Wali Murid',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Orang Tua dari ${_siswaData!['nama_lengkap']}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  'Kelas ${_siswaData!['kelas'] != null ? _siswaData!['kelas']['nama_kelas'] : '-'}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Menu Grid
                  Text(
                    'Menu Utama',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildMenuCard(
                        context,
                        title: 'Nilai Anak',
                        icon: Icons.star,
                        color: AppColors.primary,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  WaliNilaiScreen(siswaData: _siswaData!),
                            ),
                          );
                        },
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Absensi',
                        icon: Icons.check_circle_outline,
                        color: AppColors.success,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  WaliAbsensiScreen(siswaId: _siswaData!['id']),
                            ),
                          );
                        },
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Jadwal',
                        icon: Icons.schedule,
                        color: AppColors.warning,
                        onTap: () {
                          if (_siswaData!['kelas_id'] != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WaliJadwalScreen(
                                  kelasId: _siswaData!['kelas_id'],
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Siswa belum masuk kelas"),
                              ),
                            );
                          }
                        },
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Profil Anak',
                        icon: Icons.account_circle,
                        color: AppColors.error,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  WaliProfilScreen(siswa: _siswaData!),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            const Text(
              "Data Siswa Tidak Ditemukan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Akun Anda belum terhubung dengan data siswa manapun. Harap hubungi Admin Sekolah untuk menghubungkan akun.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
