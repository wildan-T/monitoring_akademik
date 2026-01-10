//C:\Users\MSITHIN\monitoring_akademik\lib\presentation\screens\admin\admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/constants/route_constants.dart';
import '../../../presentation/providers/auth_provider.dart';
import 'siswa/siswa_list_screen.dart';
import 'siswa/siswa_import_screen.dart'; // ✅ TAMBAH INI
import 'guru/guru_list_screen.dart';
import 'sekolah/sekolah_view_screen.dart';
import 'kelola_user_screen.dart';
import 'nilai/nilai_list_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Konfirmasi logout
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
                        foregroundColor: Colors.white,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary,
                      child: const Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.white,
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
                            'Admin',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
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
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                // ✅ MENU KELOLA USER
                // _buildMenuCard(
                //   context,
                //   title: 'Kelola User',
                //   icon: Icons.people,
                //   color: AppColors.error,
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => const KelolaUserScreen(),
                //       ),
                //     );
                //   },
                // ),

                // ✅ MENU KELOLA SISWA (UPDATED DENGAN BOTTOM SHEET)
                _buildMenuCard(
                  context,
                  title: 'Kelola Siswa',
                  icon: Icons.school,
                  color: AppColors.success,
                  onTap: () => _showSiswaOptionsMenu(context),
                ),

                // ✅ MENU KELOLA GURU
                _buildMenuCard(
                  context,
                  title: 'Kelola Guru',
                  icon: Icons.person_outline,
                  color: AppColors.warning,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GuruListScreen(),
                      ),
                    );
                  },
                ),

                // ✅ MENU DATA SEKOLAH
                _buildMenuCard(
                  context,
                  title: 'Data Sekolah',
                  icon: Icons.business,
                  color: AppColors.info,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SekolahViewScreen(),
                      ),
                    );
                  },
                ),

                // ✅ MENU LIHAT NILAI
                _buildMenuCard(
                  context,
                  title: 'Lihat Nilai',
                  icon: Icons.assessment,
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NilaiListScreen(),
                      ),
                    );
                  },
                ),

                // ✅ MENU IMPORT DATA (SHORTCUT KE IMPORT SISWA)
                // _buildMenuCard(
                //   context,
                //   title: 'Import Data',
                //   icon: Icons.upload_file,
                //   color: AppColors.primaryDark,
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => const SiswaImportScreen(),
                //       ),
                //     );
                //   },
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ BUILD MENU CARD
  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
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
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ SHOW SISWA OPTIONS MENU (BOTTOM SHEET)
  void _showSiswaOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            const Text(
              'Kelola Data Siswa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ✅ OPTION 1: Import Data Siswa
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.upload_file, color: Colors.green),
              ),
              title: const Text('Import Data Siswa'),
              subtitle: const Text('Import dari file Excel'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context); // Close bottom sheet
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SiswaImportScreen(),
                  ),
                );
              },
            ),

            const Divider(),

            // ✅ OPTION 2: Lihat & Kelola Data
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.list, color: Colors.blue),
              ),
              title: const Text('Lihat & Kelola Data'),
              subtitle: const Text('Lihat, tambah, edit, hapus siswa'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context); // Close bottom sheet
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SiswaListScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
