import 'package:flutter/material.dart';
import 'package:monitoring_akademik/presentation/screens/guru/nilai/finalisasi_nilai_screen.dart';
import 'package:monitoring_akademik/presentation/screens/guru/nilai/nilai_input_screen.dart';
import 'package:monitoring_akademik/presentation/screens/guru/nilai/nilai_rekap_screen.dart';
import 'package:provider/provider.dart';
import '../../../providers/nilai_provider.dart';
import '../../../providers/auth_provider.dart';

class NilaiListScreen extends StatefulWidget {
  const NilaiListScreen({super.key});

  @override
  State<NilaiListScreen> createState() => _NilaiListScreenState();
}

class _NilaiListScreenState extends State<NilaiListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadKelasMapel();
    });
  }

  Future<void> _loadKelasMapel() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final nilaiProvider = Provider.of<NilaiProvider>(context, listen: false);
    
    final guruId = authProvider.currentUser?.id ?? '';
    if (guruId.isNotEmpty) {
      await nilaiProvider.getKelasMapelByGuruId(guruId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Nilai'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FinalisasiNilaiScreen(),
                ),
              );
            },
            tooltip: 'Finalisasi Nilai',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadKelasMapel,
        child: Consumer<NilaiProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.kelasMapelList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada kelas yang diampu',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hubungi admin untuk penugasan kelas',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.kelasMapelList.length,
              itemBuilder: (context, index) {
                final kelasMapel = provider.kelasMapelList[index];
                
                // Extract data from map
                final kelas = kelasMapel['kelas'] ?? 'Unknown';
                final mataPelajaran = kelasMapel['mata_pelajaran'] ?? 'Unknown';
                final kelasId = kelasMapel['kelas_id'] ?? '';
                final mataPelajaranId = kelasMapel['mata_pelajaran_id'] ?? '';
                final jumlahSiswa = kelasMapel['jumlah_siswa'] ?? 0;
                final nilaiTerisi = kelasMapel['nilai_terisi'] ?? 0;
                final statusFinalisasi = kelasMapel['status'] ?? 'draft';

                final progress = jumlahSiswa > 0 
                    ? (nilaiTerisi / jumlahSiswa * 100).toStringAsFixed(0)
                    : '0';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      _showMenuOptions(
                        context,
                        kelas,
                        mataPelajaran,
                        kelasId,
                        mataPelajaranId,
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.book,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mataPelajaran,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.class_,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Kelas $kelas',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (statusFinalisasi == 'final')
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 14,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Final',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Progress Nilai',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: jumlahSiswa > 0 
                                                  ? nilaiTerisi / jumlahSiswa
                                                  : 0,
                                              backgroundColor: Colors.grey[200],
                                              minHeight: 8,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '$progress%',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Siswa',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '$nilaiTerisi/$jumlahSiswa',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showMenuOptions(
    BuildContext context,
    String kelas,
    String mataPelajaran,
    String kelasId,
    String mataPelajaranId,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Input Nilai'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Get siswa list for this kelas
                // For now, passing empty list
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NilaiInputScreen(
                      guruId: Provider.of<AuthProvider>(context, listen: false)
                          .currentUser?.id ?? '',
                      kelas: kelas,
                      mataPelajaran: mataPelajaran,
                      siswa: const [], // Should fetch from SiswaProvider
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Lihat Rekap'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NilaiRekapScreen(
                      kelas: kelas,
                      mataPelajaran: mataPelajaran,
                    ),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Batal'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}