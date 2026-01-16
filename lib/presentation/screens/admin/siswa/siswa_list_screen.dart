import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../providers/siswa_provider.dart';
import '../../../../data/models/siswa_model.dart';
import 'siswa_add_screen.dart';
import 'siswa_edit_screen.dart';

class SiswaListScreen extends StatefulWidget {
  const SiswaListScreen({super.key});

  @override
  State<SiswaListScreen> createState() => _SiswaListScreenState();
}

class _SiswaListScreenState extends State<SiswaListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load data siswa saat layar dibuka
    Future.microtask(() => context.read<SiswaProvider>().fetchAllSiswa());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Dialog Konfirmasi Hapus
  // void _confirmDelete(BuildContext context, SiswaModel siswa) {
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: const Text('Hapus Data Siswa?'),
  //       content: Text('Apakah Anda yakin ingin menghapus siswa ${siswa.nama}? Data yang dihapus tidak dapat dikembalikan.'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(ctx),
  //           child: const Text('Batal'),
  //         ),
  //         ElevatedButton(
  //           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  //           onPressed: () async {
  //             Navigator.pop(ctx);
  //             final success = await context.read<SiswaProvider>().deleteSiswa(siswa.id); // Pastikan ada method deleteSiswa di Provider

  //             if (mounted) {
  //               if (success) {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   const SnackBar(content: Text('Data siswa berhasil dihapus'), backgroundColor: Colors.green),
  //                 );
  //               } else {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(content: Text(context.read<SiswaProvider>().errorMessage ?? 'Gagal hapus'), backgroundColor: Colors.red),
  //                 );
  //               }
  //             }
  //           },
  //           child: const Text('Hapus', style: TextStyle(color: Colors.white)),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Siswa'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SiswaAddScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // --- Search Bar ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Nama atau NISN...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {}); // Trigger rebuild untuk reset list
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (val) {
                setState(() {}); // Rebuild saat ketik
              },
            ),
          ),

          // --- List View ---
          Expanded(
            child: Consumer<SiswaProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Ambil list hasil pencarian
                final siswaList = provider.searchSiswa(_searchController.text);

                if (siswaList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Data siswa tidak ditemukan',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await provider.fetchAllSiswa();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: siswaList.length,
                    itemBuilder: (context, index) {
                      final siswa = siswaList[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: siswa.jenisKelamin == 'P'
                                ? Colors.pink.shade50
                                : Colors.blue.shade50,
                            child: Text(
                              siswa.nama.isNotEmpty
                                  ? siswa.nama[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: siswa.jenisKelamin == 'P'
                                    ? Colors.pink
                                    : Colors.blue,
                              ),
                            ),
                          ),
                          title: Text(
                            siswa.nama,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: Colors.orange.shade200,
                                      ),
                                    ),
                                    child: Text(
                                      siswa.namaKelas ?? 'Belum ada kelas',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange.shade800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'NISN: ${siswa.nisn}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              if (siswa.namaWali != null &&
                                  siswa.namaWali != '-')
                                Row(
                                  children: [
                                    Icon(
                                      Icons.family_restroom,
                                      size: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Wali: ${siswa.namaWali}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            onSelected: (value) {
                              if (value == 'edit') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        SiswaEditScreen(siswa: siswa),
                                  ),
                                );
                              }
                              // else if (value == 'delete') {
                              //   _confirmDelete(context, siswa);
                              // }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              // const PopupMenuItem(
                              //   value: 'delete',
                              //   child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))])
                              // ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
