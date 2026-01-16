import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../data/models/siswa_model.dart';
import '../../../providers/absensi_provider.dart';

class SiswaDetailScreen extends StatelessWidget {
  final SiswaModel siswa;

  const SiswaDetailScreen({super.key, required this.siswa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Siswa'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(
                      siswa.nama.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    siswa.nama,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'NISN: ${siswa.nisn}',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    // child: Text(
                    //   'Kelas ${siswa.kelas}',
                    //   style: const TextStyle(
                    //     fontSize: 14,
                    //     color: Colors.white,
                    //     fontWeight: FontWeight.w600,
                    //   ),
                    // ),
                  ),
                ],
              ),
            ),

            // Info Detail
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Informasi Pribadi'),
                  const SizedBox(height: 12),

                  // _buildInfoCard([
                  //   _buildInfoRow('NIS', siswa.nis),
                  //   _buildInfoRow('NISN', siswa.nisn),
                  //   _buildInfoRow('Nama Lengkap', siswa.nama),
                  //   _buildInfoRow('Jenis Kelamin', siswa.jenisKelamin),
                  //   _buildInfoRow('Tempat Lahir', siswa.tempatLahir),
                  //   _buildInfoRow(
                  //     'Tanggal Lahir',
                  //     DateFormat(
                  //       'dd MMMM yyyy',
                  //       'id_ID',
                  //     ).format(siswa.tanggalLahir),
                  //   ),
                  //   _buildInfoRow('Agama', siswa.agama),
                  //   _buildInfoRow('Alamat', siswa.alamat),
                  // ]),

                  // const SizedBox(height: 24),

                  // _buildSectionTitle('Informasi Akademik'),
                  // const SizedBox(height: 12),
                  // _buildInfoCard([
                  //   _buildInfoRow('Kelas', siswa.kelas),
                  //   _buildInfoRow('Tahun Masuk', siswa.tahunMasuk),
                  //   _buildInfoRow('Status', siswa.status),
                  // ]),

                  // const SizedBox(height: 24),

                  // _buildSectionTitle('Informasi Orang Tua'),
                  // const SizedBox(height: 12),
                  // _buildInfoCard([
                  //   _buildInfoRow('Nama Ayah', siswa.namaAyah),
                  //   _buildInfoRow('Nama Ibu', siswa.namaIbu),
                  //   _buildInfoRow('No. Telepon', siswa.noTelpOrangTua),
                  // ]),
                  const SizedBox(height: 24),

                  // Rekap Absensi Bulan Ini
                  _buildSectionTitle('Rekap Absensi Bulan Ini'),
                  const SizedBox(height: 12),
                  // ✅ FIX: Gunakan FutureBuilder karena getRekapAbsensiSiswa mengembalikan Future
                  FutureBuilder<Map<String, int>>(
                    future: Provider.of<AbsensiProvider>(context, listen: false)
                        .getRekapAbsensiSiswa(
                          siswa.id,
                        ), // Hapus parameter month/year
                    builder: (context, snapshot) {
                      final rekap =
                          snapshot.data ??
                          {'hadir': 0, 'izin': 0, 'sakit': 0, 'alpha': 0};
                      final total = rekap.values.fold(
                        0,
                        (sum, val) => sum + val,
                      );
                      final persentase = total > 0
                          ? (rekap['hadir']! / total * 100)
                          : 0.0;

                      return Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Persentase Kehadiran
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Persentase Kehadiran',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${persentase.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: persentase >= 80
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Rekap Detail
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildAbsensiStat(
                                    'Hadir',
                                    rekap['hadir'] ?? 0,
                                    AppColors.success,
                                  ),
                                  _buildAbsensiStat(
                                    'Izin',
                                    rekap['izin'] ?? 0,
                                    Colors.orange,
                                  ),
                                  _buildAbsensiStat(
                                    'Sakit',
                                    rekap['sakit'] ?? 0,
                                    Colors.blue,
                                  ),
                                  _buildAbsensiStat(
                                    'Alpha',
                                    rekap['alpha'] ?? 0,
                                    AppColors.error,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsensiStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
