// lib/presentation/screens/admin/akademik/tahun_pelajaran_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Jangan lupa: flutter pub add intl
import '../../../../data/models/tahun_pelajaran_model.dart';
import '../../../providers/tahun_pelajaran_provider.dart';
import '../../../../core/constants/color_constants.dart';

class TahunPelajaranScreen extends StatefulWidget {
  const TahunPelajaranScreen({super.key});

  @override
  State<TahunPelajaranScreen> createState() => _TahunPelajaranScreenState();
}

class _TahunPelajaranScreenState extends State<TahunPelajaranScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<TahunPelajaranProvider>().fetchTahunPelajaran(),
    );
  }

  // Fungsi Pilih Tanggal
  Future<DateTime?> _pickDate(
    BuildContext context,
    DateTime? initialDate,
  ) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
  }

  void _showFormDialog(
    BuildContext parentContext, {
    TahunPelajaranModel? data,
  }) {
    final isEdit = data != null;
    final tahunController = TextEditingController(text: data?.tahun ?? '');
    int selectedSemester = data?.semester ?? 1;
    bool isActive = data?.isActive ?? false;
    DateTime? tglMulai = data?.tanggalMulai;
    DateTime? tglSelesai = data?.tanggalSelesai;

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Tahun Ajaran' : 'Tambah Tahun Ajaran'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Input Tahun
                    TextField(
                      controller: tahunController,
                      decoration: const InputDecoration(
                        labelText: 'Tahun Pelajaran',
                        hintText: 'Contoh: 2024/2025',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dropdown Semester
                    DropdownButtonFormField<int>(
                      value: selectedSemester,
                      decoration: const InputDecoration(
                        labelText: 'Semester',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 1,
                          child: Text('Semester 1 (Ganjil)'),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text('Semester 2 (Genap)'),
                        ),
                      ],
                      onChanged: (val) =>
                          setState(() => selectedSemester = val!),
                    ),
                    const SizedBox(height: 16),

                    // Date Pickers
                    InkWell(
                      onTap: () async {
                        final picked = await _pickDate(context, tglMulai);
                        if (picked != null) setState(() => tglMulai = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Mulai',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today, size: 18),
                        ),
                        child: Text(
                          tglMulai != null
                              ? DateFormat('dd/MM/yyyy').format(tglMulai!)
                              : 'Pilih',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final picked = await _pickDate(context, tglSelesai);
                        if (picked != null) setState(() => tglSelesai = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Selesai',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.event, size: 18),
                        ),
                        child: Text(
                          tglSelesai != null
                              ? DateFormat('dd/MM/yyyy').format(tglSelesai!)
                              : 'Pilih',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Switch Active
                    SwitchListTile(
                      title: const Text('Status Aktif'),
                      subtitle: const Text(
                        'Hanya satu tahun ajaran yang boleh aktif',
                      ),
                      value: isActive,
                      activeColor: Colors.green,
                      onChanged: (val) => setState(() => isActive = val),
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
                    if (tahunController.text.isEmpty ||
                        tglMulai == null ||
                        tglSelesai == null) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(content: Text('Lengkapi semua data!')),
                      );
                      return;
                    }
                    if (tglSelesai!.isBefore(tglMulai!)) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Tanggal selesai tidak boleh sebelum tanggal mulai',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(dialogContext); // Tutup dialog

                    final provider = parentContext
                        .read<TahunPelajaranProvider>();
                    final success = await provider.saveTahunPelajaran(
                      id: isEdit ? data.id : null,
                      tahun: tahunController.text.trim(),
                      semester: selectedSemester,
                      isActive: isActive,
                      tanggalMulai: tglMulai!,
                      tanggalSelesai: tglSelesai!,
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
        title: const Text('Hapus Data?'),
        content: const Text('Data yang dihapus tidak bisa dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await parentContext
                  .read<TahunPelajaranProvider>()
                  .deleteTahunPelajaran(id);
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
        title: const Text('Tahun Pelajaran'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<TahunPelajaranProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.tahunList.isEmpty) {
            return const Center(child: Text('Belum ada data tahun pelajaran'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.tahunList.length,
            itemBuilder: (context, index) {
              final data = provider.tahunList[index];
              final dateFormat = DateFormat('dd MMM yyyy');

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: data.isActive
                      ? const BorderSide(color: Colors.green, width: 2)
                      : BorderSide.none,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Row(
                    children: [
                      // ✅ FIX 1: Bungkus Text Judul dengan Expanded
                      Expanded(
                        child: Text(
                          '${data.tahun} - ${data.semesterLabel}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (data.isActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'AKTIF',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          // ✅ FIX 2: Bungkus Text Tanggal dengan Expanded
                          Expanded(
                            child: Text(
                              '${dateFormat.format(data.tanggalMulai)} s/d ${dateFormat.format(data.tanggalSelesai)}',
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showFormDialog(context, data: data),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, data.id),
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
