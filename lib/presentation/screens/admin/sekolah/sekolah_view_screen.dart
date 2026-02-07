import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../presentation/providers/sekolah_provider.dart';
import 'sekolah_edit_screen.dart';

class SekolahViewScreen extends StatefulWidget {
  const SekolahViewScreen({super.key});

  @override
  State<SekolahViewScreen> createState() => _SekolahViewScreenState();
}

class _SekolahViewScreenState extends State<SekolahViewScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SekolahProvider>().fetchSekolahData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Sekolah')),
      body: Consumer<SekolahProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }

          final sekolah = provider.sekolahData;

          if (sekolah == null) {
            return const Center(child: Text('Data sekolah belum tersedia'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo Sekolah
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                    ),
                    child: sekolah?.logoPath != null
                        ? ClipOval(
                            child: Image.network(
                              sekolah?.logoPath ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildDefaultLogo();
                              },
                            ),
                          )
                        : _buildDefaultLogo(),
                  ),
                ),

                const SizedBox(height: 24),

                // Nama Sekolah (Center & Bold)
                Center(
                  child: Text(
                    sekolah?.namaSekolah ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 8),

                // Akreditasi & Status
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBadge(
                        label: sekolah?.akreditasi ?? '',
                        color: _getAkreditasiColor(sekolah?.akreditasi ?? ''),
                      ),
                      const SizedBox(width: 8),
                      _buildBadge(
                        label: sekolah?.statusSekolah ?? '',
                        color: sekolah?.statusSekolah == 'Negeri'
                            ? Colors.blue
                            : Colors.green,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Informasi Umum
                _buildSectionTitle('Informasi Umum'),
                _buildInfoCard([
                  _buildInfoRow('NPSN', sekolah?.npsn ?? ''),
                  _buildInfoRow('Akreditasi', sekolah?.infoAkreditasi ?? ''),
                  _buildInfoRow('Status', sekolah?.statusSekolah ?? ''),
                ]),

                const SizedBox(height: 24),

                // Alamat
                _buildSectionTitle('Alamat'),
                _buildInfoCard([
                  _buildInfoRow('Jalan', sekolah?.alamat ?? ''),
                  _buildInfoRow('Kota/Kabupaten', sekolah?.kota ?? ''),
                  _buildInfoRow('Provinsi', sekolah?.provinsi ?? ''),
                  _buildInfoRow('Kode Pos', sekolah?.kodePos ?? ''),
                ]),

                const SizedBox(height: 24),

                // Kontak
                _buildSectionTitle('Informasi Kontak'),
                _buildInfoCard([
                  _buildInfoRow('No. Telepon', sekolah?.noTelp ?? ''),
                  _buildInfoRow('Email', sekolah?.email ?? ''),
                  _buildInfoRow('Website', sekolah?.website ?? ''),
                ]),

                const SizedBox(height: 24),

                // Kepala Sekolah
                _buildSectionTitle('Kepala Sekolah'),
                _buildInfoCard([
                  _buildInfoRow('Nama', sekolah?.namaKepalaSekolah ?? ''),
                  _buildInfoRow('NIP', sekolah?.nipKepalaSekolah ?? ''),
                ]),

                const SizedBox(height: 32),

                // Button Edit
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SekolahEditScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text(
                      'EDIT DATA SEKOLAH',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefaultLogo() {
    return const Icon(Icons.school, size: 60, color: AppColors.primary);
  }

  Widget _buildBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getAkreditasiColor(String akreditasi) {
    switch (akreditasi) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
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
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
