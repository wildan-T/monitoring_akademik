//C:\Users\MSITHIN\monitoring_akademik\lib\presentation\screens\admin\akademik\jadwal_manager_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/jadwal_model.dart';
import '../../../providers/jadwal_provider.dart';
import '../../../providers/guru_provider.dart';
import '../../../providers/kelas_provider.dart';
import '../../../providers/mata_pelajaran_provider.dart';
import '../../../providers/tahun_pelajaran_provider.dart';
import '../../../../core/constants/color_constants.dart';

class JadwalManagerScreen extends StatefulWidget {
  const JadwalManagerScreen({super.key});

  @override
  State<JadwalManagerScreen> createState() => _JadwalManagerScreenState();
}

class _JadwalManagerScreenState extends State<JadwalManagerScreen> {
  String? _selectedFilterKelasId;
  String? _activeTahunId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    // 1. Load Data Master untuk Dropdown
    await context.read<KelasProvider>().fetchAllKelas();
    await context.read<GuruProvider>().fetchAllGuru();
    await context.read<MataPelajaranProvider>().fetchMataPelajaran();
    await context.read<TahunPelajaranProvider>().fetchTahunPelajaran();

    // 2. Cari Tahun Aktif
    final tahunList = context.read<TahunPelajaranProvider>().tahunList;
    try {
      if (tahunList.isNotEmpty) {
        final activeTahun = tahunList.firstWhere(
          (t) => t.isActive,
          orElse: () => tahunList.first, // Fallback jika tidak ada yang aktif
        );
        setState(() {
          _activeTahunId = activeTahun.id;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal memuat tahun aktif')));
    }
  }

  Future<void> _loadJadwal() async {
    if (_activeTahunId != null && _selectedFilterKelasId != null) {
      await context.read<JadwalProvider>().fetchJadwal(
        tahunPelajaranId: _activeTahunId!,
        kelasId: _selectedFilterKelasId,
      );
    }
  }

  // Helper Time Picker
  Future<String?> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
    );
    if (picked != null) {
      // Format ke HH:mm:00
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      return '$hour:$minute:00';
    }
    return null;
  }

  void _showFormDialog(BuildContext parentContext) {
    if (_selectedFilterKelasId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih Kelas di filter atas terlebih dahulu'),
        ),
      );
      return;
    }

    final guruProvider = parentContext.read<GuruProvider>();
    final mapelProvider = parentContext.read<MataPelajaranProvider>();

    String? selectedGuruId;
    String? selectedMapelId;
    String selectedHari = 'Senin';
    String? jamMulai;
    String? jamSelesai;

    final hariOptions = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Tambah Jadwal'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Info Kelas
                    Text(
                      'Kelas: ${parentContext.read<KelasProvider>().kelasList.firstWhere((k) => k.id == _selectedFilterKelasId).namaKelas}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Divider(),

                    // ✅ FIX 1: Dropdown Mapel dengan isExpanded & TextOverflow
                    DropdownButtonFormField<String>(
                      isExpanded: true, // Agar dropdown mengisi lebar dialog
                      decoration: const InputDecoration(
                        labelText: 'Mata Pelajaran',
                      ),
                      items: mapelProvider.mapelList.map((m) {
                        return DropdownMenuItem(
                          value: m.id,
                          child: Text(
                            m.namaMapel,
                            overflow: TextOverflow
                                .ellipsis, // Potong jika terlalu panjang
                            maxLines: 1,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => selectedMapelId = val,
                    ),
                    const SizedBox(height: 16),

                    // ✅ FIX 2: Dropdown Guru dengan isExpanded & TextOverflow
                    DropdownButtonFormField<String>(
                      isExpanded: true, // Agar dropdown mengisi lebar dialog
                      decoration: const InputDecoration(
                        labelText: 'Guru Pengajar',
                      ),
                      items: guruProvider.guruList.map((g) {
                        return DropdownMenuItem(
                          value: g.id,
                          child: Text(
                            g.nama,
                            overflow: TextOverflow
                                .ellipsis, // Potong jika terlalu panjang
                            maxLines: 1,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => selectedGuruId = val,
                    ),
                    const SizedBox(height: 16),

                    // Dropdown Hari
                    DropdownButtonFormField<String>(
                      value: selectedHari,
                      decoration: const InputDecoration(labelText: 'Hari'),
                      items: hariOptions.map((h) {
                        return DropdownMenuItem(value: h, child: Text(h));
                      }).toList(),
                      onChanged: (val) => setState(() => selectedHari = val!),
                    ),

                    const SizedBox(height: 16),

                    // Jam Mulai & Selesai
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await _pickTime(context);
                              if (time != null) setState(() => jamMulai = time);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Jam Mulai',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(jamMulai ?? 'Pilih'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await _pickTime(context);
                              if (time != null)
                                setState(() => jamSelesai = time);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Jam Selesai',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(jamSelesai ?? 'Pilih'),
                            ),
                          ),
                        ),
                      ],
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
                    if (selectedGuruId == null ||
                        selectedMapelId == null ||
                        jamMulai == null ||
                        jamSelesai == null) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(content: Text('Lengkapi data')),
                      );
                      return;
                    }

                    Navigator.pop(dialogContext);

                    final success = await parentContext
                        .read<JadwalProvider>()
                        .addJadwal(
                          guruId: selectedGuruId!,
                          kelasId: _selectedFilterKelasId!,
                          mapelId: selectedMapelId!,
                          tahunPelajaranId: _activeTahunId!,
                          hari: selectedHari,
                          jamMulai: jamMulai!,
                          jamSelesai: jamSelesai!,
                        );

                    if (parentContext.mounted) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            success ? 'Jadwal ditambahkan' : 'Gagal',
                          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Jadwal'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: _selectedFilterKelasId != null
          ? FloatingActionButton(
              onPressed: () => _showFormDialog(context),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: Column(
        children: [
          // 1. Filter Section (Pilih Kelas)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Consumer<KelasProvider>(
              builder: (context, kelasProv, _) {
                return DropdownButtonFormField<String>(
                  isExpanded: true, // ✅ FIX: Tambahkan ini juga di filter
                  value: _selectedFilterKelasId,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Kelas untuk Melihat/Edit Jadwal',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.class_),
                  ),
                  items: kelasProv.kelasList.map((k) {
                    return DropdownMenuItem(
                      value: k.id,
                      child: Text(
                        k.namaKelas,
                        overflow: TextOverflow.ellipsis, // ✅ FIX
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedFilterKelasId = val;
                    });
                    _loadJadwal();
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),

          // 2. List Jadwal
          Expanded(
            child: Consumer<JadwalProvider>(
              builder: (context, jadwalProv, _) {
                if (_selectedFilterKelasId == null) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_upward, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Silakan pilih kelas terlebih dahulu'),
                      ],
                    ),
                  );
                }

                if (jadwalProv.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (jadwalProv.jadwalList.isEmpty) {
                  return const Center(
                    child: Text('Belum ada jadwal untuk kelas ini'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: jadwalProv.jadwalList.length,
                  itemBuilder: (context, index) {
                    final jadwal = jadwalProv.jadwalList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            jadwal.hari.length >= 2
                                ? jadwal.hari.substring(0, 2)
                                : jadwal.hari,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        title: Text(
                          jadwal.namaMapel,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Guru: ${jadwal.namaGuru}'),
                            Text(
                              'Jam: ${jadwal.jamMulai.substring(0, 5)} - ${jadwal.jamSelesai.substring(0, 5)}',
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Hapus Jadwal?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await context.read<JadwalProvider>().deleteJadwal(
                                jadwal.id,
                              );
                            }
                          },
                        ),
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
