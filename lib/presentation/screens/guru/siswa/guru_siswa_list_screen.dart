import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/guru_provider.dart';
import '../../../providers/kelas_provider.dart';
import '../../../providers/siswa_provider.dart';
import '../../../providers/tahun_pelajaran_provider.dart';

class GuruSiswaListScreen extends StatefulWidget {
  const GuruSiswaListScreen({super.key});

  @override
  State<GuruSiswaListScreen> createState() => _GuruSiswaListScreenState();
}

class _GuruSiswaListScreenState extends State<GuruSiswaListScreen> {
  String? _selectedKelasId;
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final guruProv = context.read<GuruProvider>();
    final kelasProv = context.read<KelasProvider>();
    final tahunProv = context.read<TahunPelajaranProvider>();

    // 1. Pastikan Tahun Ajaran Aktif Ada
    if (tahunProv.tahunList.isEmpty) await tahunProv.fetchTahunPelajaran();
    final tahunAktif = tahunProv.tahunList.firstWhere(
      (t) => t.isActive,
      orElse: () => tahunProv.tahunList.first,
    );

    // 2. Ambil List Kelas Mengajar
    if (guruProv.currentGuru != null) {
      await kelasProv.fetchKelasMengajar(
        guruProv.currentGuru!.id,
        tahunAktif.id,
      );

      // Auto-select kelas pertama jika ada
      if (kelasProv.kelasMengajarList.isNotEmpty) {
        _selectedKelasId = kelasProv.kelasMengajarList.first.id;
        // Langsung load siswa kelas pertama
        await context.read<SiswaProvider>().fetchSiswaByKelas(
          _selectedKelasId!,
        );
      }
    }

    if (mounted) setState(() => _isInit = false);
  }

  void _onKelasChanged(String? kelasId) {
    if (kelasId == null) return;
    setState(() => _selectedKelasId = kelasId);
    context.read<SiswaProvider>().fetchSiswaByKelas(kelasId);
  }

  @override
  Widget build(BuildContext context) {
    final kelasProv = context.watch<KelasProvider>();
    final siswaProv = context.watch<SiswaProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Siswa Ajar'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isInit
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 1. HEADER: PILIH KELAS
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pilih Kelas Ajar:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (kelasProv.kelasMengajarList.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Anda tidak memiliki jadwal mengajar di tahun aktif ini.',
                          ),
                        )
                      else
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: kelasProv.kelasMengajarList.map((kelas) {
                              final isSelected = _selectedKelasId == kelas.id;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(kelas.namaKelas),
                                  selected: isSelected,
                                  selectedColor: AppColors.primary.withOpacity(
                                    0.2,
                                  ),
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.black,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  onSelected: (bool selected) {
                                    if (selected) _onKelasChanged(kelas.id);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // 2. LIST SISWA
                Expanded(
                  child: _selectedKelasId == null
                      ? const Center(child: Text('Pilih kelas terlebih dahulu'))
                      : siswaProv.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : siswaProv.siswaList.isEmpty
                      ? const Center(
                          child: Text('Belum ada data siswa di kelas ini'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: siswaProv.siswaList.length,
                          itemBuilder: (context, index) {
                            final siswa = siswaProv.siswaList[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: CircleAvatar(
                                  backgroundColor: siswa.jenisKelamin == 'P'
                                      ? Colors.pink.shade50
                                      : Colors.blue.shade50,
                                  child: Text(
                                    siswa.nama.isNotEmpty ? siswa.nama[0] : '?',
                                    style: TextStyle(
                                      color: siswa.jenisKelamin == 'P'
                                          ? Colors.pink
                                          : Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  siswa.nama,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text('NISN: ${siswa.nisn}'),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.info_outline,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    _showDetail(context, siswa);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  void _showDetail(BuildContext context, dynamic siswa) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                siswa.nama,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _rowDetail(Icons.badge, 'NISN', siswa.nisn),
              _rowDetail(Icons.class_, 'Kelas', siswa.namaKelas ?? '-'),
              _rowDetail(
                Icons.person,
                'Jenis Kelamin',
                siswa.jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan',
              ),
              const Divider(),
              const Text(
                'Kontak Wali',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              _rowDetail(
                Icons.family_restroom,
                'Nama Wali',
                siswa.namaWali ?? '-',
              ),
              _rowDetail(Icons.phone, 'No. HP', siswa.noHpWali ?? '-'),
            ],
          ),
        );
      },
    );
  }

  Widget _rowDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
