//C:\Users\MSITHIN\monitoring_akademik\lib\presentation\screens\admin\siswa\siswa_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monitoring_akademik/core/constants/color_constants.dart';
import 'package:monitoring_akademik/presentation/providers/siswa_provider.dart';
import 'package:monitoring_akademik/presentation/screens/admin/siswa/siswa_add_screen.dart';
import 'package:monitoring_akademik/presentation/screens/admin/siswa/siswa_edit_screen.dart';

class SiswaListScreen extends StatefulWidget {
  const SiswaListScreen({super.key});

  @override
  State<SiswaListScreen> createState() => _SiswaListScreenState();
}

class _SiswaListScreenState extends State<SiswaListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Siswa'),
        actions: [
          // Filter Button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SiswaAddScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Siswa'),
      ),
      body: Consumer<SiswaProvider>(
        builder: (context, siswaProvider, child) {
          final siswaList = siswaProvider.siswaList;

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari siswa (nama, NIS, NISN)...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              siswaProvider.setSearchQuery('');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    siswaProvider.setSearchQuery(value);
                  },
                ),
              ),

              // Filter Chips
              if (siswaProvider.filterKelas != 'Semua' ||
                  siswaProvider.filterStatus != 'Semua')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      if (siswaProvider.filterKelas != 'Semua')
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text('Kelas: ${siswaProvider.filterKelas}'),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () => siswaProvider.setFilterKelas('Semua'),
                          ),
                        ),
                      if (siswaProvider.filterStatus != 'Semua')
                        Chip(
                          label: Text('Status: ${siswaProvider.filterStatus}'),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => siswaProvider.setFilterStatus('Semua'),
                        ),
                      const Spacer(),
                      if (siswaProvider.filterKelas != 'Semua' ||
                          siswaProvider.filterStatus != 'Semua')
                        TextButton(
                          onPressed: () => siswaProvider.clearFilters(),
                          child: const Text('Reset Filter'),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // Siswa List
              Expanded(
                child: siswaList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 80,
                              color: AppColors.grey.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada data siswa',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tambahkan siswa baru dengan menekan tombol +',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: siswaList.length,
                        itemBuilder: (context, index) {
                          final siswa = siswaList[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: CircleAvatar(
                                radius: 28,
                                backgroundColor: siswa.jenisKelamin == 'L'
                                    ? AppColors.primary.withOpacity(0.1)
                                    : AppColors.secondary.withOpacity(0.1),
                                child: Icon(
                                  siswa.jenisKelamin == 'L'
                                      ? Icons.boy
                                      : Icons.girl,
                                  color: siswa.jenisKelamin == 'L'
                                      ? AppColors.primary
                                      : AppColors.secondary,
                                  size: 28,
                                ),
                              ),
                              title: Text(
                                siswa.nama,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('NIS: ${siswa.nis} | NISN: ${siswa.nisn}'),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.info.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Kelas ${siswa.kelas}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.info,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(siswa.status)
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          siswa.status,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _getStatusColor(siswa.status),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton(
                                icon: const Icon(Icons.more_vert),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'detail',
                                    child: Row(
                                      children: [
                                        Icon(Icons.visibility, size: 20),
                                        SizedBox(width: 8),
                                        Text('Detail'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 20, color: AppColors.error),
                                        SizedBox(width: 8),
                                        Text(
                                          'Hapus',
                                          style: TextStyle(color: AppColors.error),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'detail') {
                                    _showDetailDialog(context, siswa);
                                  } else if (value == 'edit') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SiswaEditScreen(siswa: siswa),
                                      ),
                                    );
                                  } else if (value == 'delete') {
                                    _showDeleteDialog(context, siswa.id, siswa.nama);
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Aktif':
        return AppColors.success;
      case 'Lulus':
        return AppColors.info;
      case 'Mutasi Keluar':
        return AppColors.warning;
      default:
        return AppColors.grey;
    }
  }

  void _showFilterDialog(BuildContext context) {
    final siswaProvider = Provider.of<SiswaProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Siswa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kelas:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                'Semua',
                '7A',
                '7B',
                '7C',
                '8A',
                '8B',
                '8C',
                '9A',
                '9B',
                '9C'
              ]
                  .map(
                    (kelas) => FilterChip(
                      label: Text(kelas),
                      selected: siswaProvider.filterKelas == kelas,
                      onSelected: (selected) {
                        siswaProvider.setFilterKelas(kelas);
                        Navigator.pop(context);
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text('Status:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Semua', 'Aktif', 'Lulus', 'Mutasi Keluar']
                  .map(
                    (status) => FilterChip(
                      label: Text(status),
                      selected: siswaProvider.filterStatus == status,
                      onSelected: (selected) {
                        siswaProvider.setFilterStatus(status);
                        Navigator.pop(context);
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              siswaProvider.clearFilters();
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(BuildContext context, siswa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(siswa.nama),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('NIS', siswa.nis),
              _buildDetailRow('NISN', siswa.nisn),
              _buildDetailRow('Jenis Kelamin', siswa.jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan'),
              _buildDetailRow('Tempat, Tanggal Lahir', '${siswa.tempatLahir}, ${siswa.tanggalLahirFormatted}'),
              _buildDetailRow('Umur', '${siswa.umur} tahun'),
              _buildDetailRow('Agama', siswa.agama),
              _buildDetailRow('Alamat', siswa.alamat),
              _buildDetailRow('Nama Ayah', siswa.namaAyah),
              _buildDetailRow('Nama Ibu', siswa.namaIbu),
              _buildDetailRow('No. Telp Orang Tua', siswa.noTelpOrangTua),
              _buildDetailRow('Kelas', siswa.kelas),
              _buildDetailRow('Tahun Masuk', siswa.tahunMasuk),
              _buildDetailRow('Status', siswa.status),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String id, String nama) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus siswa "$nama"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              final siswaProvider = Provider.of<SiswaProvider>(context, listen: false);
              final success = await siswaProvider.deleteSiswa(id);
              
              if (!context.mounted) return;
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Siswa berhasil dihapus'
                        : siswaProvider.errorMessage ?? 'Gagal menghapus siswa',
                  ),
                  backgroundColor: success ? AppColors.success : AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}