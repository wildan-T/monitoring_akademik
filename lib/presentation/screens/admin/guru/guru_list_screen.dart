//C:\Users\MSITHIN\monitoring_akademik\lib\presentation\screens\admin\guru\guru_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../providers/guru_provider.dart';

class GuruListScreen extends StatefulWidget {
  const GuruListScreen({super.key});

  @override
  State<GuruListScreen> createState() => _GuruListScreenState();
}

class _GuruListScreenState extends State<GuruListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuruProvider>().fetchAllGuru();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Guru'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Consumer<GuruProvider>(
        builder: (context, guruProvider, child) {
          if (guruProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ✅ FIX: error → errorMessage
          if (guruProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text('Error: ${guruProvider.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => guruProvider.fetchAllGuru(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final guruList = guruProvider.guruList;

          if (guruList.isEmpty) {
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
                    'Belum ada data guru',
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
            itemCount: guruList.length,
            itemBuilder: (context, index) {
              final guru = guruList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      guru.nama.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    guru.nama,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('NUPTK: ${guru.nuptk}'),
                      if (guru.email != null) Text('Email: ${guru.email}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (guru.isWaliKelas)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Wali Kelas',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/admin/guru-detail',
                      arguments: guru,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}