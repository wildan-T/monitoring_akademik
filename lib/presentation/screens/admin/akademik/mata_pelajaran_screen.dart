// lib/presentation/screens/admin/akademik/mata_pelajaran_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/mata_pelajaran_model.dart';
import '../../../providers/mata_pelajaran_provider.dart';
import '../../../../core/constants/color_constants.dart';

class MataPelajaranScreen extends StatefulWidget {
  const MataPelajaranScreen({super.key});

  @override
  State<MataPelajaranScreen> createState() => _MataPelajaranScreenState();
}

class _MataPelajaranScreenState extends State<MataPelajaranScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<MataPelajaranProvider>().fetchMataPelajaran(),
    );
  }

  // Form Dialog untuk Tambah/Edit
  void _showFormDialog(
    BuildContext parentContext, {
    MataPelajaranModel? mapel,
  }) {
    final isEdit = mapel != null;
    final kodeController = TextEditingController(text: mapel?.kodeMapel ?? '');
    final namaController = TextEditingController(text: mapel?.namaMapel ?? '');
    String selectedKategori = mapel?.kategori ?? 'Kelompok A'; // Default

    // Opsi Kategori
    final List<String> kategoriOptions = [
      'Kelompok A',
      'Kelompok B',
      'Ekstrakulikuler',
    ];

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Mapel' : 'Tambah Mapel'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: kodeController,
                      decoration: const InputDecoration(
                        labelText: 'Kode Mapel *',
                        hintText: 'Contoh: IPA, MAT',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Mata Pelajaran *',
                        hintText: 'Contoh: Ilmu Pengetahuan Alam',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedKategori,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                      ),
                      items: kategoriOptions
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => selectedKategori = val!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (kodeController.text.isEmpty ||
                        namaController.text.isEmpty) {
                      return;
                    }

                    Navigator.pop(dialogContext); // Tutup dialog

                    final provider = parentContext
                        .read<MataPelajaranProvider>();
                    final success = await provider.saveMataPelajaran(
                      id: isEdit ? mapel.id : null,
                      kodeMapel: kodeController.text.trim().toUpperCase(),
                      namaMapel: namaController.text.trim(),
                      kategori: selectedKategori,
                    );

                    if (parentContext.mounted) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Data tersimpan'
                                : (provider.errorMessage ?? 'Gagal'),
                          ),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext parentContext, String id) {
    showDialog(
      context: parentContext,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Mapel?'),
        content: const Text(
          'Pastikan mapel ini tidak digunakan di jadwal atau nilai.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await parentContext
                  .read<MataPelajaranProvider>()
                  .deleteMataPelajaran(id);
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
        title: const Text('Data Mata Pelajaran'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<MataPelajaranProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.mapelList.isEmpty) {
            return const Center(child: Text('Belum ada data mata pelajaran'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.mapelList.length,
            itemBuilder: (context, index) {
              final mapel = provider.mapelList[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      mapel.kodeMapel.length > 2
                          ? mapel.kodeMapel.substring(0, 2)
                          : mapel.kodeMapel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: Text(
                    mapel.namaMapel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Kategori: ${mapel.kategori ?? '-'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showFormDialog(context, mapel: mapel),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, mapel.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
