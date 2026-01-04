import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/absensi_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../../data/models/absensi_model.dart';

class AbsensiRekapScreen extends StatefulWidget {
  const AbsensiRekapScreen({super.key});

  @override
  State<AbsensiRekapScreen> createState() => _AbsensiRekapScreenState();
}

class _AbsensiRekapScreenState extends State<AbsensiRekapScreen> {
  String? _selectedKelas;
  String? _selectedMataPelajaran;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAbsensi();
    });
  }

  Future<void> _loadAbsensi() async {
    if (_selectedKelas == null || _selectedMataPelajaran == null) return;

    final absensiProvider = Provider.of<AbsensiProvider>(context, listen: false);
    
    // Get kelas ID and mapel ID (dalam real app, ambil dari database)
    final kelasId = _selectedKelas ?? '';
    final mataPelajaranId = _selectedMataPelajaran ?? '';

    await absensiProvider.fetchAbsensiByKelasMapel(
      kelasId: kelasId,
      mataPelajaranId: mataPelajaranId,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadAbsensi();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap Absensi'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
            tooltip: 'Filter Tanggal',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
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
                      .map((kelas) => DropdownMenuItem(
                            value: kelas,
                            child: Text(kelas),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedKelas = value;
                      _loadAbsensi();
                    });
                  },
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
                  items: [
                    'Matematika',
                    'Bahasa Indonesia',
                    'IPA',
                    'IPS',
                    'Bahasa Inggris'
                  ]
                      .map((mapel) => DropdownMenuItem(
                            value: mapel,
                            child: Text(mapel),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMataPelajaran = value;
                      _loadAbsensi();
                    });
                  },
                ),

                // Date Range Display
                if (_startDate != null && _endDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '${DateFormat('dd MMM yyyy').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _startDate = null;
                                _endDate = null;
                              });
                              _loadAbsensi();
                            },
                            child: const Icon(Icons.close, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Statistik Section
          Consumer<AbsensiProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                );
              }

              final stats = provider.statistikKehadiran;

              return Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildStatCard('Hadir', stats['hadir'] ?? 0, Colors.green),
                    const SizedBox(width: 8),
                    _buildStatCard('Izin', stats['izin'] ?? 0, Colors.blue),
                    const SizedBox(width: 8),
                    _buildStatCard('Sakit', stats['sakit'] ?? 0, Colors.orange),
                    const SizedBox(width: 8),
                    _buildStatCard('Alpha', stats['alpha'] ?? 0, Colors.red),
                  ],
                ),
              );
            },
          ),

          // List Absensi
          Expanded(
            child: Consumer<AbsensiProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.absensiList.isEmpty) {
                  return const Center(
                    child: Text('Belum ada data absensi'),
                  );
                }

                // Group by siswa
                final Map<String, List<AbsensiModel>> groupedBySiswa = {};
                for (var absensi in provider.absensiList) {
                  final siswaId = absensi.siswaId;
                  if (!groupedBySiswa.containsKey(siswaId)) {
                    groupedBySiswa[siswaId] = [];
                  }
                  groupedBySiswa[siswaId]!.add(absensi);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: groupedBySiswa.length,
                  itemBuilder: (context, index) {
                    final siswaId = groupedBySiswa.keys.elementAt(index);
                    final absensiList = groupedBySiswa[siswaId]!;
                    final firstAbsensi = absensiList.first;

                    // Calculate stats for this siswa
                    final hadir = absensiList.where((a) => a.status == 'hadir').length;
                    final izin = absensiList.where((a) => a.status == 'izin').length;
                    final sakit = absensiList.where((a) => a.status == 'sakit').length;
                    final alpha = absensiList.where((a) => a.status == 'alpha').length;
                    final total = absensiList.length;
                    final persentase = total > 0 ? (hadir / total * 100).toStringAsFixed(1) : '0';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text(
                          firstAbsensi.siswa.nama ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'NIS: ${firstAbsensi.siswa.nis ?? '-'} • Kehadiran: $persentase%',
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Mini Stats
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildMiniStat('H', hadir, Colors.green),
                                    _buildMiniStat('I', izin, Colors.blue),
                                    _buildMiniStat('S', sakit, Colors.orange),
                                    _buildMiniStat('A', alpha, Colors.red),
                                  ],
                                ),
                                const Divider(height: 24),

                                // Detail List
                                ...absensiList.map((absensi) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Pertemuan ${absensi.pertemuan}',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            DateFormat('dd MMM yyyy').format(absensi.tanggal),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const Spacer(),
                                          _buildStatusChip(absensi.status),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'hadir':
        color = Colors.green;
        break;
      case 'izin':
        color = Colors.blue;
        break;
      case 'sakit':
        color = Colors.orange;
        break;
      case 'alpha':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}