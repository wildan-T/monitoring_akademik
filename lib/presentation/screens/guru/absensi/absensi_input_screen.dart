import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/absensi_provider.dart';
import '../../../providers/siswa_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../../data/models/siswa_model.dart';

class AbsensiInputScreen extends StatefulWidget {
  const AbsensiInputScreen({super.key});

  @override
  State<AbsensiInputScreen> createState() => _AbsensiInputScreenState();
}

class _AbsensiInputScreenState extends State<AbsensiInputScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedKelas;
  String? _selectedMataPelajaran;
  DateTime _selectedDate = DateTime.now();
  int _pertemuan = 1;

  // Map untuk menyimpan status absensi setiap siswa
  Map<String, String> _absensiStatus = {};

  List<SiswaModel> _siswaList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    // Load siswa berdasarkan kelas yang dipilih
    if (_selectedKelas != null) {
      final siswaProvider = Provider.of<SiswaProvider>(context, listen: false);
      await siswaProvider.fetchAllSiswa();

      setState(() {
        // _siswaList =
        //     siswaProvider.siswaList
        //         .where((s) => s.kelas == _selectedKelas)
        //         .toList();

        // Initialize default status (hadir untuk semua siswa)
        for (var siswa in _siswaList) {
          _absensiStatus[siswa.id] = 'hadir';
        }
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveAbsensi() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedKelas == null || _selectedMataPelajaran == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kelas dan mata pelajaran terlebih dahulu'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final absensiProvider = Provider.of<AbsensiProvider>(
      context,
      listen: false,
    );

    // Get guru ID from current user
    final guruId = authProvider.currentUser?.id ?? '';

    // Get kelas ID and mapel ID (dalam real app, ambil dari database)
    // Sementara hardcode untuk demo
    final kelasId = _selectedKelas ?? '';
    final mataPelajaranId = _selectedMataPelajaran ?? '';

    final success = await absensiProvider.saveAbsensi(
      kelasId: kelasId,
      mataPelajaranId: mataPelajaranId,
      guruId: guruId,
      pertemuan: _pertemuan,
      tanggal: _selectedDate,
      absensiData: _absensiStatus,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Absensi berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${absensiProvider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Input Absensi'), elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  // Header Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Column(
                      children: [
                        // Kelas Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedKelas,
                          decoration: const InputDecoration(
                            labelText: 'Kelas',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: ['7A', '7B', '8A', '8B', '9A', '9B']
                              .map(
                                (kelas) => DropdownMenuItem(
                                  value: kelas,
                                  child: Text(kelas),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedKelas = value;
                              _loadInitialData();
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Pilih kelas' : null,
                        ),
                        const SizedBox(height: 12),

                        // Mata Pelajaran Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedMataPelajaran,
                          decoration: const InputDecoration(
                            labelText: 'Mata Pelajaran',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items:
                              [
                                    'Matematika',
                                    'Bahasa Indonesia',
                                    'IPA',
                                    'IPS',
                                    'Bahasa Inggris',
                                  ]
                                  .map(
                                    (mapel) => DropdownMenuItem(
                                      value: mapel,
                                      child: Text(mapel),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() => _selectedMataPelajaran = value);
                          },
                          validator: (value) =>
                              value == null ? 'Pilih mata pelajaran' : null,
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            // Tanggal
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectDate(context),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Tanggal',
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormat(
                                          'dd MMM yyyy',
                                          'id_ID',
                                        ).format(_selectedDate),
                                      ),
                                      const Icon(Icons.calendar_today),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Pertemuan
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                initialValue: _pertemuan.toString(),
                                decoration: const InputDecoration(
                                  labelText: 'Pertemuan',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    _pertemuan = int.tryParse(value) ?? 1;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Daftar Siswa
                  Expanded(
                    child: _siswaList.isEmpty
                        ? const Center(
                            child: Text('Pilih kelas untuk menampilkan siswa'),
                          )
                        : ListView.builder(
                            itemCount: _siswaList.length,
                            padding: const EdgeInsets.all(16),
                            itemBuilder: (context, index) {
                              final siswa = _siswaList[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            child: Text('${index + 1}'),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  siswa.nama,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Text(
                                                  'NIS: ${siswa.nis}',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          _buildStatusButton(
                                            siswa.id,
                                            'hadir',
                                            'Hadir',
                                            Colors.green,
                                          ),
                                          const SizedBox(width: 8),
                                          _buildStatusButton(
                                            siswa.id,
                                            'izin',
                                            'Izin',
                                            Colors.blue,
                                          ),
                                          const SizedBox(width: 8),
                                          _buildStatusButton(
                                            siswa.id,
                                            'sakit',
                                            'Sakit',
                                            Colors.orange,
                                          ),
                                          const SizedBox(width: 8),
                                          _buildStatusButton(
                                            siswa.id,
                                            'alpha',
                                            'Alpha',
                                            Colors.red,
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

                  // Bottom Button
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveAbsensi,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Simpan Absensi',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusButton(
    String siswaId,
    String status,
    String label,
    Color color,
  ) {
    final isSelected = _absensiStatus[siswaId] == status;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _absensiStatus[siswaId] = status;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
