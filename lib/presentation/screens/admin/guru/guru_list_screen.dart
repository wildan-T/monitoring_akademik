//C:\Users\MSITHIN\monitoring_akademik\lib\presentation\screens\admin\guru\guru_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/guru_provider.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../data/models/guru_model.dart';
import 'guru_add_screen.dart';
import 'guru_edit_screen.dart';

class GuruListScreen extends StatefulWidget {
  const GuruListScreen({super.key});

  @override
  State<GuruListScreen> createState() => _GuruListScreenState();
}

class _GuruListScreenState extends State<GuruListScreen> {
  @override
  void initState() {
    super.initState();
    // Load data saat pertama kali buka
    Future.microtask(() => context.read<GuruProvider>().fetchAllGuru());
  }

  // ✅ Fix: Pastikan parameter menerima GuruModel
  void _confirmDelete(BuildContext context, GuruModel guru) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Data Guru?'),
        content: Text('Apakah Anda yakin ingin menghapus data ${guru.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Pastikan method deleteGuru ada di Provider
              // Jika belum ada, gunakan method removeWaliKelas atau buat method delete baru
              await context.read<GuruProvider>().deleteGuru(guru.id);
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(
              //     content: Text(
              //       'Fitur hapus belum diimplementasikan di Provider',
              //     ),
              //   ),
              // );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Guru'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GuruAddScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<GuruProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.guruList.isEmpty) {
            return const Center(child: Text('Belum ada data guru'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.guruList.length,
            itemBuilder: (context, index) {
              // ✅ FIX DISINI: Lakukan casting dari Entity ke Model
              final guru = provider.guruList[index] as GuruModel;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      guru.nama.isNotEmpty ? guru.nama[0].toUpperCase() : '?',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                  title: Text(
                    guru.nama,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NIP: ${guru.nip ?? '-'}'),
                      if (guru.isWaliKelas)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            'Wali Kelas ${guru.waliKelas}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GuruEditScreen(guru: guru),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  // trailing: PopupMenuButton(
                  //   onSelected: (value) {
                  //     if (value == 'edit') {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (_) => GuruEditScreen(guru: guru),
                  //         ),
                  //       );
                  //     } else if (value == 'delete') {
                  //       _confirmDelete(context, guru);
                  //     }
                  //   },
                  //   itemBuilder: (ctx) => [
                  //     const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  //     const PopupMenuItem(
                  //       value: 'delete',
                  //       child: Text(
                  //         'Hapus',
                  //         style: TextStyle(color: Colors.red),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  onTap: () {
                    // Detail Screen
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
