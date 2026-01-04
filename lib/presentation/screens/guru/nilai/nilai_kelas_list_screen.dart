//C:\Users\MSITHIN\monitoring_akademik\lib\presentation\screens\guru\nilai\nilai_kelas_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/nilai_provider.dart';
import '../../../../data/models/kelas_mapel_model.dart';
import 'nilai_siswa_list_screen.dart';
import 'nilai_rekap_screen.dart'; // ✅ TAMBAHKAN

class NilaiKelasListScreen extends StatelessWidget {
  const NilaiKelasListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final nilaiProvider = Provider.of<NilaiProvider>(context);

    // Ambil data kelas & mapel yang diajar guru ini
    final kelasMapelList = nilaiProvider.getKelasMapelByGuruId(
      authProvider.currentUser?.id ?? '',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Kelas & Mata Pelajaran'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: kelasMapelList.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: kelasMapelList.length,
              itemBuilder: (context, index) {
                final kelasMapel = kelasMapelList[index];
                return _buildKelasMapelCard(context, kelasMapel, nilaiProvider);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.class_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada kelas yang diajar',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKelasMapelCard(
    BuildContext context,
    KelasMapelModel kelasMapel,
    NilaiProvider nilaiProvider,
  ) {
    // Ambil statistik nilai untuk kelas & mapel ini
    final statistik = nilaiProvider.getStatistik(
      kelas: kelasMapel.kelas,
      mataPelajaran: kelasMapel.mataPelajaran,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // ✅ CARD UTAMA (KLIK UNTUK MASUK LIST SISWA)
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NilaiSiswaListScreen(
                    kelas: kelasMapel.kelas,
                    mataPelajaran: kelasMapel.mataPelajaran,
                  ),
                ),
              );
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.class_,
                          color: Colors.blue,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kelas ${kelasMapel.kelas}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              kelasMapel.mataPelajaran,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Total Siswa',
                          statistik['total_siswa'].toString(),
                          Icons.people,
                          Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Sudah Dinilai',
                          statistik['sudah_dinilai'].toString(),
                          Icons.check_circle,
                          Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Belum Dinilai',
                          statistik['belum_dinilai'].toString(),
                          Icons.pending,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // ✅ TOMBOL REKAP NILAI (BARU!)
          const Divider(height: 1),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NilaiRekapScreen(
                    kelas: kelasMapel.kelas,
                    mataPelajaran: kelasMapel.mataPelajaran,
                  ),
                ),
              );
            },
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assessment,
                    size: 20,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lihat Rekap Nilai',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}