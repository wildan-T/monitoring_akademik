import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart'; // Wajib untuk fitur print

// --- IMPORTS INTERNAL ---
import '../../../../core/constants/color_constants.dart';
import '../../../../data/models/siswa_model.dart';
import '../../../../data/services/rapor_pdf_service.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/guru_provider.dart';
import '../../../providers/kelas_provider.dart';
import '../../../providers/siswa_provider.dart';
import '../../../providers/tahun_pelajaran_provider.dart';
// Import Layar Detail Rekap
import '../rekap/guru_rekap_detail_screen.dart';

class GuruKelaskuScreen extends StatefulWidget {
  const GuruKelaskuScreen({super.key});

  @override
  State<GuruKelaskuScreen> createState() => _GuruKelaskuScreenState();
}

class _GuruKelaskuScreenState extends State<GuruKelaskuScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isInit = true;

  // State untuk Tab Rekap Nilai
  List<Map<String, dynamic>> _listMapelKelas = [];
  bool _isLoadingMapel = false;

  @override
  void initState() {
    super.initState();
    // ✅ HANYA 2 TAB: Siswa & Rekap
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authProv = context.read<AuthProvider>();
    final kelasProv = context.read<KelasProvider>();
    final siswaProv = context.read<SiswaProvider>();
    final tahunProv = context.read<TahunPelajaranProvider>();

    try {
      if (authProv.currentUser != null) {
        // 1. Pastikan Tahun Ajaran terload
        if (tahunProv.tahunList.isEmpty) await tahunProv.fetchTahunPelajaran();

        // 2. Cari Kelas milik Guru ini (Wali Kelas)
        await kelasProv.fetchMyKelas(authProv.currentUser!.id);

        // 3. Jika ketemu kelasnya, ambil daftar siswanya & daftar mapel
        if (kelasProv.myKelas != null) {
          await siswaProv.fetchSiswaByKelas(kelasProv.myKelas!.id);

          // Load Mapel untuk Tab Rekap
          _loadMapelKelas(kelasProv.myKelas!.id);
        }
      }
    } catch (e) {
      debugPrint("Error loading data kelasku: $e");
    } finally {
      if (mounted) setState(() => _isInit = false);
    }
  }

  // Load Daftar Mapel yang ada di kelas ini
  Future<void> _loadMapelKelas(String kelasId) async {
    setState(() => _isLoadingMapel = true);
    final tahunProv = context.read<TahunPelajaranProvider>();
    final tahunAktif = tahunProv.tahunList.firstWhere((t) => t.isActive);

    final data = await SupabaseService().getMapelDiKelas(
      kelasId,
      tahunAktif.id,
    );

    if (mounted) {
      setState(() {
        _listMapelKelas = data;
        _isLoadingMapel = false;
      });
    }
  }

  // ==========================================
  // 🖨️ FITUR CETAK RAPOR
  // ==========================================
  void _printRapor(SiswaModel siswa) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final supabase = SupabaseService();
      final tahunProv = context.read<TahunPelajaranProvider>();
      final kelasProv = context.read<KelasProvider>();
      final guruProv = context.read<GuruProvider>();

      final tahunAktif = tahunProv.tahunList.firstWhere(
        (t) => t.isActive,
        orElse: () => tahunProv.tahunList.first,
      );

      // Ambil Data Nilai Lengkap
      final dataNilai = await supabase.getNilaiRaporSiswa(
        siswa.id,
        tahunAktif.id,
      );

      // Generate PDF
      final pdfBytes = await RaporPdfService().generateRapor(
        siswa: siswa,
        namaKelas: kelasProv.myKelas?.namaKelas ?? '-',
        tahunAjaran: tahunAktif.tahun.toString(),
        semester: tahunAktif.semester.toString(),
        namaWaliKelas: guruProv.currentGuru?.nama ?? 'Wali Kelas',
        nipWaliKelas: guruProv.currentGuru?.nip ?? '...............',
        listNilaiRaw: dataNilai,
      );

      if (mounted) {
        Navigator.pop(context); // Tutup Loading

        await Printing.layoutPdf(
          onLayout: (format) async => pdfBytes,
          name: 'Rapor-${siswa.nama}.pdf',
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Tutup Loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal print rapor: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kelasProv = context.watch<KelasProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kelasku'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Daftar Siswa', icon: Icon(Icons.people)),
            Tab(text: 'Rekap Nilai', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: _isInit
          ? const Center(child: CircularProgressIndicator())
          : kelasProv.myKelas == null
          ? _buildNoClassView()
          : TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: DAFTAR SISWA
                _buildSiswaList(),

                // TAB 2: REKAP NILAI
                _buildRekapTab(),
              ],
            ),
    );
  }

  // --- WIDGETS ---

  Widget _buildNoClassView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.class_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Anda belum terdaftar sebagai Wali Kelas',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // TAB 1: SISWA & PRINT RAPOR
  Widget _buildSiswaList() {
    return Consumer<SiswaProvider>(
      builder: (context, siswaProv, _) {
        if (siswaProv.isLoading)
          return const Center(child: CircularProgressIndicator());

        if (siswaProv.siswaList.isEmpty) {
          return const Center(child: Text('Belum ada siswa di kelas ini'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: siswaProv.siswaList.length,
          itemBuilder: (context, index) {
            final siswa = siswaProv.siswaList[index];
            final isLaki = siswa.jenisKelamin == 'L';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: isLaki
                      ? Colors.blue.shade50
                      : Colors.pink.shade50,
                  child: Text(
                    siswa.nama.isNotEmpty ? siswa.nama[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: isLaki ? Colors.blue : Colors.pink,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                title: Text(
                  siswa.nama,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('NISN: ${siswa.nisn}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // TOMBOL PRINT RAPOR
                    IconButton(
                      icon: const Icon(Icons.print, color: Colors.green),
                      tooltip: 'Cetak Rapor',
                      onPressed: () => _printRapor(siswa),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.blue),
                      tooltip: 'Detail Siswa',
                      onPressed: () => _showSiswaDetail(siswa),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // TAB 2: REKAP NILAI (Pilih Mapel)
  Widget _buildRekapTab() {
    if (_isLoadingMapel)
      return const Center(child: CircularProgressIndicator());

    if (_listMapelKelas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.event_busy, size: 60, color: Colors.grey),
            SizedBox(height: 10),
            Text("Tidak ada jadwal pelajaran di kelas ini."),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _listMapelKelas.length,
      itemBuilder: (context, index) {
        final mapel = _listMapelKelas[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.grading, color: Colors.purple),
            ),
            title: Text(
              mapel['nama_mapel'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigasi ke Detail Rekap
              final kelasProv = context.read<KelasProvider>();
              final tahunProv = context.read<TahunPelajaranProvider>();
              final tahunAktif = tahunProv.tahunList.firstWhere(
                (t) => t.isActive,
              );

              if (kelasProv.myKelas != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GuruRekapDetailScreen(
                      kelasId: kelasProv.myKelas!.id,
                      mapelId: mapel['id'],
                      namaKelas: kelasProv.myKelas!.namaKelas,
                      namaMapel: mapel['nama_mapel'],
                      tahunId: tahunAktif.id,
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  void _showSiswaDetail(SiswaModel siswa) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
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
                  const SizedBox(height: 20),
                  _detailRow(Icons.badge, 'NISN', siswa.nisn),
                  _detailRow(
                    Icons.person,
                    'Jenis Kelamin',
                    siswa.jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan',
                  ),
                  _detailRow(
                    Icons.place,
                    'Tempat Lahir',
                    siswa.tempatLahir ?? '-',
                  ),
                  const Divider(height: 30),
                  const Text(
                    'Data Wali',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _detailRow(
                    Icons.family_restroom,
                    'Nama Wali',
                    siswa.namaWali ?? '-',
                  ),
                  _detailRow(Icons.phone, 'No. Telepon', siswa.noHpWali ?? '-'),
                  _detailRow(Icons.email, 'Email', siswa.emailWali ?? '-'),
                  _detailRow(Icons.home, 'Alamat', siswa.alamat ?? '-'),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
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
