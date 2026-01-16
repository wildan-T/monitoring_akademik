//C:\Users\MSITHIN\monitoring_akademik\lib\presentation\screens\guru\guru_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:monitoring_akademik/presentation/screens/guru/absensi/guru_absensi_menu_screen.dart';
import 'package:monitoring_akademik/presentation/screens/guru/kelas/guru_kelasku_screen.dart';
import 'package:monitoring_akademik/presentation/screens/guru/nilai/guru_pilih_mapel_screen.dart';
import 'package:monitoring_akademik/presentation/screens/guru/rekap/guru_rekap_menu_screen.dart';
import 'package:monitoring_akademik/presentation/screens/guru/siswa/guru_siswa_list_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/guru_provider.dart';
import '../../../../core/constants/color_constants.dart'; // Pastikan import ini ada

class GuruDashboardScreen extends StatefulWidget {
  const GuruDashboardScreen({Key? key}) : super(key: key);

  @override
  State<GuruDashboardScreen> createState() => _GuruDashboardScreenState();
}

class _GuruDashboardScreenState extends State<GuruDashboardScreen> {
  bool _isLoading = true;
  bool _needsProfileCompletion = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkProfileStatus();
    });
  }

  Future<void> _checkProfileStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final guruProvider = Provider.of<GuruProvider>(context, listen: false);

    // 1. Tunggu Auth siap
    if (authProvider.isLoading) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (authProvider.currentUser == null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    // 2. Cek Profil Lengkap
    if (!authProvider.currentUser!.isActive) {
      setState(() {
        _needsProfileCompletion = true;
        _isLoading = false;
      });
      if (mounted)
        Navigator.pushReplacementNamed(context, '/lengkapi-profil-guru');
      return;
    }

    // 3. Load Data Detail Guru (Nama Asli ada di sini)
    await guruProvider.fetchGuruByProfileId(authProvider.currentUser!.id);

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_needsProfileCompletion) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Consumer2<AuthProvider, GuruProvider>(
      builder: (context, authProvider, guruProvider, child) {
        final currentUser = authProvider.currentUser;
        final currentGuru = guruProvider.currentGuru;

        // ✅ LOGIC PERBAIKAN NAMA:
        // Prioritaskan nama dari tabel Guru,
        // Jika belum ada, baru pakai nama dari Auth (Guru)
        String displayName = 'Guru';
        if (currentGuru != null &&
            currentGuru.nama.isNotEmpty &&
            currentGuru.nama != 'Tanpa Nama') {
          displayName = currentGuru.nama;
        } else if (currentUser != null && currentUser.name.isNotEmpty) {
          displayName = currentUser.name;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard Guru'),
            backgroundColor: AppColors.primary, // Sesuaikan warna
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          drawer: _buildDrawer(
            context,
            authProvider,
            displayName, // ✅ Kirim nama yang sudah diperbaiki
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await _checkProfileStatus();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ✅ Welcome Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.blue.shade100,
                              backgroundImage: (currentGuru?.fotoProfil != null)
                                  ? NetworkImage(currentGuru!.fotoProfil!)
                                  : null,
                              child: (currentGuru?.fotoProfil == null)
                                  ? Text(
                                      displayName.substring(0, 1).toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selamat Datang,',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // ✅ TAMPILKAN NAMA YANG BENAR DI SINI
                                  Text(
                                    displayName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (currentGuru != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'NIP: ${currentGuru.nip}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (currentGuru?.isWaliKelas == true) ...[
                          const Divider(height: 24),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.class_outlined,
                                  color: Colors.green.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Wali Kelas ${currentGuru?.waliKelas ?? ""}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ✅ Menu Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  // Angka < 1.0 membuat kartu lebih tinggi (Potrait)
                  // Angka > 1.0 membuat kartu lebih lebar (Landscape)
                  childAspectRatio: 0.85,
                  children: [
                    // MENU WALI KELAS
                    if (currentGuru?.isWaliKelas == true) ...[
                      // _buildMenuCard(
                      //   icon: Icons.people_outline,
                      //   title: 'Kelola Kelasku',
                      //   subtitle: 'Siswa kelas ${currentGuru?.waliKelas ?? ""}',
                      //   color: Colors.blue,
                      //   onTap: () {
                      //     Navigator.pushNamed(
                      //       context,
                      //       '/guru-siswa-list',
                      //       arguments: currentGuru?.waliKelas,
                      //     );
                      //   },
                      // ),
                      _buildMenuCard(
                        icon: Icons.assessment_outlined,
                        title: 'Nilai Kelasku',
                        subtitle: 'Leger nilai kelas',
                        color: Colors.red,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GuruKelaskuScreen(),
                            ),
                          );
                        },
                      ),
                    ],

                    // MENU UMUM
                    _buildMenuCard(
                      icon: Icons.groups_outlined,
                      title: 'Data Siswa',
                      subtitle: 'Lihat siswa yang saya ajar',
                      color: Colors.indigo,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GuruSiswaListScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      icon: Icons.grade_outlined,
                      title: 'Input Nilai',
                      subtitle: 'Input nilai siswa',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GuruPilihMapelScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      icon: Icons.summarize_outlined,
                      title: 'Rekap Nilai',
                      subtitle: 'Lihat rekap nilai',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GuruRekapMenuScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      icon: Icons.schedule,
                      title: 'Jadwal',
                      subtitle: 'Lihat Jadwal',
                      color: Colors.green,
                      onTap: () {
                        Navigator.pushNamed(context, '/guru-jadwal');
                      },
                    ),
                    _buildMenuCard(
                      icon: Icons.fact_check_outlined,
                      title: 'Input Absensi',
                      subtitle: 'Absensi harian',
                      color: Colors.teal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GuruAbsensiMenuScreen(),
                          ),
                        );
                      },
                    ),
                    // _buildMenuCard(
                    //   icon: Icons.history_edu_outlined,
                    //   title: 'Rekap Absensi',
                    //   subtitle: 'Riwayat absensi',
                    //   color: Colors.teal,
                    //   onTap: () {
                    //     Navigator.pushNamed(context, '/guru-absensi-rekap');
                    //   },
                    // ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    AuthProvider authProvider,
    String userName,
  ) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    userName.isNotEmpty
                        ? userName.substring(0, 1).toUpperCase()
                        : 'G',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Guru',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profil Saya'),
            onTap: () {
              Navigator.pop(context);
              // Tambahkan navigasi ke profil
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Konfirmasi Logout'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await authProvider.logout();
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
    );
  }
}
