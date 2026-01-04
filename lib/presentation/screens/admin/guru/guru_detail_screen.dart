//C:\Users\MSITHIN\monitoring_akademik\lib\presentation\screens\admin\guru\guru_detail_screen.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../domain/entities/guru_entity.dart';

class GuruDetailScreen extends StatelessWidget {
  final GuruEntity guru;

  const GuruDetailScreen({super.key, required this.guru});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(guru.nama),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        guru.nama.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guru.nama,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'NUPTK: ${guru.nuptk}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: guru.isWaliKelas 
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : AppColors.info.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              guru.isWaliKelas ? 'Wali Kelas' : 'Guru',
                              style: TextStyle(
                                color: guru.isWaliKelas 
                                    ? AppColors.success 
                                    : AppColors.info,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Data Pribadi
            const Text(
              'Data Pribadi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow('NUPTK', guru.nuptk),
                    const Divider(),
                    _buildDetailRow('NIP', guru.nip ?? '-'),
                    const Divider(),
                    _buildDetailRow('Email', guru.email ?? '-'),
                    const Divider(),
                    _buildDetailRow('No. Telepon', guru.noTelp ?? '-'),
                    const Divider(),
                    _buildDetailRow('Alamat', guru.alamat ?? '-'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Data Akademik
            const Text(
              'Data Akademik',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow(
                      'Pendidikan Terakhir',
                      guru.pendidikanTerakhir ?? '-',
                    ),
                    const Divider(),
                    _buildDetailRow(
                      'Status Wali Kelas',
                      guru.isWaliKelas ? 'Ya' : 'Tidak',
                    ),
                    if (guru.isWaliKelas && guru.waliKelas != null) ...[
                      const Divider(),
                      _buildDetailRow('Wali Kelas', guru.waliKelas!),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}