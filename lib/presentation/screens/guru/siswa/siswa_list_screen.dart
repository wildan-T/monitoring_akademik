//C:\Users\MSITHIN\monitoring_akademik\lib\presentation\screens\guru\siswa\siswa_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/guru_provider.dart';
import '../../../providers/siswa_provider.dart';
import '../../../providers/kelas_provider.dart';

class SiswaListScreen extends StatefulWidget {
  const SiswaListScreen({super.key});

  @override
  State<SiswaListScreen> createState() => _SiswaListScreenState();
}

class _SiswaListScreenState extends State<SiswaListScreen> {
  String? _selectedKelas;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final guruProvider = context.read<GuruProvider>();
    final kelasProvider = context.read<KelasProvider>();
    final siswaProvider = context.read<SiswaProvider>();

    // ✅ FIX: Use currentGuru (sync getter)
    final currentGuru = guruProvider.currentGuru;
    
    // Load kelas list
    await kelasProvider.fetchAllKelas();

    // ✅ FIX: Check currentGuru properly
    if (currentGuru != null && currentGuru.isWaliKelas) {
      // Auto-select wali kelas
      _selectedKelas = currentGuru.waliKelas;
      if (_selectedKelas != null) {
        await siswaProvider.fetchSiswaByKelas(_selectedKelas!);
      }
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Siswa'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          // Filter Kelas
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: Consumer2<KelasProvider, GuruProvider>(
              builder: (context, kelasProvider, guruProvider, child) {
                // ✅ FIX: Use currentGuru
                final currentGuru = guruProvider.currentGuru;
                final isWaliKelas = currentGuru?.isWaliKelas ?? false;
                final waliKelasName = currentGuru?.waliKelas;

                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Pilih Kelas',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  value: _selectedKelas,
                  items: kelasProvider.kelasList
                      .where((kelas) => !isWaliKelas || kelas.nama == waliKelasName)
                      .map((kelas) => DropdownMenuItem(
                            value: kelas.nama,
                            child: Text(kelas.nama),
                          ))
                      .toList(),
                  onChanged: (value) async {
                    if (value != null) {
                      setState(() => _selectedKelas = value);
                      final siswaProvider = context.read<SiswaProvider>();
                      await siswaProvider.fetchSiswaByKelas(value);
                    }
                  },
                );
              },
            ),
          ),

          // Siswa List
          Expanded(
            child: Consumer<SiswaProvider>(
              builder: (context, siswaProvider, child) {
                if (siswaProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (siswaProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${siswaProvider.errorMessage}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                if (_selectedKelas == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.class_outlined,
                          size: 64,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Pilih kelas untuk melihat daftar siswa',
                          style: TextStyle(
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final siswaList = siswaProvider.siswaList;

                if (siswaList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada siswa di kelas $_selectedKelas',
                          style: TextStyle(
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: siswaList.length,
                  itemBuilder: (context, index) {
                    final siswa = siswaList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: Text(
                            siswa.nama.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          siswa.nama,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('NIS: ${siswa.nis}'),
                            Text('Kelas: ${siswa.kelas}'),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/guru-siswa-detail',
                            arguments: siswa,
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}