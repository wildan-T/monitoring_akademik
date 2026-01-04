//C:\Users\MSITHIN\monitoring_akademik\lib\presentation\screens\guru\guru_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/guru_provider.dart';
//import '../../../core/constants/app_constants.dart';

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
    _checkProfileStatus();
  }

  Future<void> _checkProfileStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final guruProvider = Provider.of<GuruProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      // Not logged in, redirect to login
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    // ✅ Check if profile is incomplete
    if (!authProvider.currentUser!.isActive) {
      print('⚠️ Profil guru belum lengkap, redirect ke lengkapi profil');
      setState(() {
        _needsProfileCompletion = true;
        _isLoading = false;
      });
      
      // Redirect to lengkapi profil
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/lengkapi-profil-guru');
      }
      return;
    }

    // ✅ Load guru data
    await guruProvider.fetchGuruByProfileId(authProvider.currentUser!.id);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_needsProfileCompletion) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Consumer2<AuthProvider, GuruProvider>(
      builder: (context, authProvider, guruProvider, child) {
        final currentUser = authProvider.currentUser;
        final currentGuru = guruProvider.currentGuru;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard Guru'),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // TODO: Notifikasi
                },
              ),
            ],
          ),
          drawer: _buildDrawer(context, authProvider, currentUser?.name ?? 'Guru'),
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
                              child: Text(
                                currentUser?.name.substring(0, 1).toUpperCase() ?? 'G',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
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
                                  Text(
                                    currentUser?.name ?? 'Guru',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (currentGuru != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'NIP: ${currentGuru.nip ?? '-'}',
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
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.class_outlined, color: Colors.green.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  'Wali Kelas',
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
                  children: [
                    _buildMenuCard(
                      icon: Icons.people_outline,
                      title: 'Data Siswa',
                      subtitle: 'Lihat data siswa',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pushNamed(context, '/guru-siswa-list');
                      },
                    ),
                    _buildMenuCard(
                      icon: Icons.grade_outlined,
                      title: 'Input Nilai',
                      subtitle: 'Input nilai siswa',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pushNamed(context, '/guru-nilai-input');
                      },
                    ),
                    _buildMenuCard(
                      icon: Icons.checklist_outlined,
                      title: 'Absensi',
                      subtitle: 'Input absensi',
                      color: Colors.green,
                      onTap: () {
                        Navigator.pushNamed(context, '/guru-absensi-input');
                      },
                    ),
                    _buildMenuCard(
                      icon: Icons.assessment_outlined,
                      title: 'Rekap Nilai',
                      subtitle: 'Lihat rekap nilai',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.pushNamed(context, '/guru-nilai-rekap');
                      },
                    ),
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
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthProvider authProvider, String userName) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    userName.substring(0, 1).toUpperCase(),
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
                ),
                const Text(
                  'Guru',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profil Saya'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to profile
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Pengaturan'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to settings
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

              if (confirm == true && mounted) {
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