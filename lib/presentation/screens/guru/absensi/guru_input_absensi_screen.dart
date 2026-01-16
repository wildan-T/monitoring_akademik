import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/color_constants.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/guru_provider.dart';
import '../../../providers/siswa_provider.dart';
import '../../../providers/tahun_pelajaran_provider.dart';

class GuruInputAbsensiScreen extends StatefulWidget {
  final String kelasId;
  final String mapelId; // ✅ Parameter Baru
  final String namaKelas;
  final String namaMapel; // ✅ Parameter Baru

  const GuruInputAbsensiScreen({
    super.key,
    required this.kelasId,
    required this.mapelId,
    required this.namaKelas,
    required this.namaMapel,
  });

  @override
  State<GuruInputAbsensiScreen> createState() => _GuruInputAbsensiScreenState();
}

class _GuruInputAbsensiScreenState extends State<GuruInputAbsensiScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  bool _isSaving = false;
  final Map<String, String> _statusAbsensi = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final siswaProv = context.read<SiswaProvider>();
      await siswaProv.fetchSiswaByKelas(widget.kelasId);

      // Default Hadir
      for (var siswa in siswaProv.siswaList) {
        _statusAbsensi[siswa.id] = 'H';
      }

      await _fetchExistingAbsensi();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal load: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchExistingAbsensi() async {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    // ✅ Panggil fungsi yang sudah difilter Mapel ID
    final data = await SupabaseService().getAbsensiByMapelTanggal(
      widget.kelasId,
      widget.mapelId,
      dateStr,
    );

    if (data.isNotEmpty) {
      for (var item in data) {
        _statusAbsensi[item['siswa_id']] = item['status'];
      }
    } else {
      // Reset
      final siswaProv = context.read<SiswaProvider>();
      for (var siswa in siswaProv.siswaList) {
        _statusAbsensi[siswa.id] = 'H';
      }
    }
  }

  Future<void> _saveAbsensi() async {
    setState(() => _isSaving = true);
    final supabase = SupabaseService();
    final siswaProv = context.read<SiswaProvider>();
    final guruProv = context.read<GuruProvider>();
    final tahunProv = context.read<TahunPelajaranProvider>();

    try {
      // Ambil ID Guru
      String guruId = guruProv.currentGuru?.id ?? '';
      if (guruId.isEmpty) {
        final currentUser = context.read<AuthProvider>().currentUser;
        if (currentUser != null) {
          final guruData = await supabase.supabase
              .from('guru')
              .select('id')
              .eq('profile_id', currentUser.id)
              .maybeSingle();
          if (guruData != null) guruId = guruData['id'];
        }
      }
      if (guruId.isEmpty) throw "Data Guru tidak ditemukan";

      final tahunAktif = tahunProv.tahunList.firstWhere((t) => t.isActive);
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

      List<Map<String, dynamic>> batchData = [];
      for (var siswa in siswaProv.siswaList) {
        batchData.add({
          'siswa_id': siswa.id,
          'kelas_id': widget.kelasId,
          'guru_id': guruId,
          'mata_pelajaran_id': widget.mapelId, // ✅ Simpan Mapel ID
          'tahun_pelajaran_id': tahunAktif.id,
          'tanggal': dateStr,
          'status': _statusAbsensi[siswa.id] ?? 'H',
        });
      }

      await supabase.saveAbsensiBatch(batchData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Absensi berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal simpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _isLoading = true;
      });
      // Reload data absen untuk tanggal baru
      await _fetchExistingAbsensi();
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final siswaProv = context.watch<SiswaProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Input Absensi'),
            // Tampilkan Nama Mapel & Kelas
            Text(
              '${widget.namaMapel} - ${widget.namaKelas}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Tanggal
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat(
                    'EEEE, dd MMMM yyyy',
                    'id_ID',
                  ).format(_selectedDate),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Total Siswa: ${siswaProv.siswaList.length}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          // List Siswa
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: siswaProv.siswaList.length,
                    itemBuilder: (context, index) {
                      final siswa = siswaProv.siswaList[index];
                      final currentStatus = _statusAbsensi[siswa.id] ?? 'H';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                siswa.nama,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // PILIHAN STATUS
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatusOption(
                                    siswa.id,
                                    'H',
                                    'Hadir',
                                    Colors.green,
                                    currentStatus,
                                  ),
                                  _buildStatusOption(
                                    siswa.id,
                                    'I',
                                    'Izin',
                                    Colors.blue,
                                    currentStatus,
                                  ),
                                  _buildStatusOption(
                                    siswa.id,
                                    'S',
                                    'Sakit',
                                    Colors.orange,
                                    currentStatus,
                                  ),
                                  _buildStatusOption(
                                    siswa.id,
                                    'A',
                                    'Alpha',
                                    Colors.red,
                                    currentStatus,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 5,
              color: Colors.black12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading || _isSaving ? null : _saveAbsensi,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isSaving
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  "SIMPAN ABSENSI",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildStatusOption(
    String siswaId,
    String code,
    String label,
    Color color,
    String currentStatus,
  ) {
    final isSelected = code == currentStatus;

    return GestureDetector(
      onTap: () {
        setState(() {
          _statusAbsensi[siswaId] = code;
        });
      },
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              border: Border.all(
                color: isSelected ? color : Colors.grey.shade300,
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              code,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? color : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
