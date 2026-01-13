import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/kelas_model.dart';
import '../../../providers/kelas_provider.dart';
import '../../../../core/constants/color_constants.dart';

class KelasManagerScreen extends StatefulWidget {
  const KelasManagerScreen({super.key});

  @override
  State<KelasManagerScreen> createState() => _KelasManagerScreenState();
}

class _KelasManagerScreenState extends State<KelasManagerScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<KelasProvider>().fetchAllKelas());
  }

  void _showFormDialog(BuildContext parentContext, {KelasModel? kelas}) {
    final isEdit = kelas != null;
    final namaController = TextEditingController(text: kelas?.namaKelas ?? '');
    int selectedTingkat = kelas?.tingkat ?? 7;
    // waliKelasId di sini adalah profile_id
    String? selectedWaliKelasId = kelas?.waliKelasId;

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Consumer<KelasProvider>(
              builder: (context, provider, _) {
                return AlertDialog(
                  title: Text(isEdit ? 'Edit Kelas' : 'Tambah Kelas Baru'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Input Nama Kelas
                        TextField(
                          controller: namaController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Kelas',
                            hintText: 'Contoh: 7A, 8B',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.class_),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Dropdown Tingkat
                        DropdownButtonFormField<int>(
                          value: selectedTingkat,
                          decoration: const InputDecoration(
                            labelText: 'Tingkat',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.show_chart),
                          ),
                          items: [7, 8, 9].map((val) {
                            return DropdownMenuItem(
                              value: val,
                              child: Text('Kelas $val'),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => selectedTingkat = val!),
                        ),
                        const SizedBox(height: 16),

                        // Dropdown Wali Kelas
                        DropdownButtonFormField<String>(
                          value: selectedWaliKelasId,
                          decoration: const InputDecoration(
                            labelText: 'Wali Kelas (Guru)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          isExpanded: true,
                          hint: const Text('Pilih Wali Kelas'),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Belum Ada'),
                            ),
                            ...provider.guruOptions.map((guru) {
                              return DropdownMenuItem<String>(
                                value: guru['profile_id'].toString(),
                                child: Text(
                                  guru['nama'],
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }),
                          ],
                          onChanged: (val) =>
                              setState(() => selectedWaliKelasId = val),
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
                        if (namaController.text.isEmpty) return;

                        Navigator.pop(dialogContext); // Tutup dialog

                        final success = await provider.saveKelas(
                          id: isEdit ? kelas.id : null,
                          namaKelas: namaController.text.trim(),
                          tingkat: selectedTingkat,
                          waliKelasId: selectedWaliKelasId,
                        );

                        if (parentContext.mounted) {
                          ScaffoldMessenger.of(parentContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Berhasil disimpan'
                                    : (provider.errorMessage ?? 'Gagal'),
                              ),
                              backgroundColor: success
                                  ? Colors.green
                                  : Colors.red,
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
      },
    );
  }

  void _confirmDelete(BuildContext parentContext, String id) {
    showDialog(
      context: parentContext,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kelas?'),
        content: const Text('Data yang dihapus tidak bisa dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await parentContext.read<KelasProvider>().deleteKelas(id);
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
        title: const Text('Kelola Data Kelas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<KelasProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.kelasList.isEmpty) {
            return const Center(child: Text('Belum ada data kelas'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.kelasList.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final kelas = provider.kelasList[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      kelas.tingkat.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  title: Text(
                    kelas.namaKelas,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          kelas.namaWali != null
                              ? 'Wali: ${kelas.namaWali}'
                              : 'Belum ada Wali Kelas',
                          style: TextStyle(
                            color: kelas.namaWali != null
                                ? Colors.black87
                                : Colors.redAccent,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showFormDialog(context, kelas: kelas),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, kelas.id),
                        tooltip: 'Hapus',
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
