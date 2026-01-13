//C:\Users\MSITHIN\monitoring_akademik\lib\presentation\screens\admin\guru\guru_add_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/guru_model.dart';
import '../../../providers/guru_provider.dart';

class GuruAddScreen extends StatefulWidget {
  const GuruAddScreen({super.key});

  @override
  State<GuruAddScreen> createState() => _GuruAddScreenState();
}

class _GuruAddScreenState extends State<GuruAddScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nipController = TextEditingController();
  final _nuptkController = TextEditingController();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noTelpController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _alamatController = TextEditingController();

  // State Variables
  String _selectedJenisKelamin = 'L';
  DateTime? _selectedTanggalLahir;
  String _selectedAgama = 'Islam';
  String _selectedPendidikan = 'S1';
  String _selectedStatus = 'PNS'; // Default

  // List Opsi
  final List<String> _agamaList = [
    'Islam',
    'Kristen',
    'Katolik',
    'Hindu',
    'Buddha',
    'Konghucu',
  ];
  final List<String> _statusList = ['PNS', 'PPPK', 'Honorer', 'Tetap Yayasan'];
  final List<String> _pendidikanList = ['SMA', 'D3', 'S1', 'S2', 'S3'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedTanggalLahir = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTanggalLahir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Mohon pilih tanggal lahir')),
      );
      return;
    }

    // Buat model guru baru
    final newGuru = GuruModel(
      id: '', // ID akan digenerate oleh Supabase Auth
      nuptk: _nuptkController.text.trim(),
      nip: _nipController.text.isEmpty ? null : _nipController.text.trim(),
      nama: _namaController.text.trim(),
      email: _emailController.text.trim(),
      noTelp: _noTelpController.text.trim(),
      jenisKelamin: _selectedJenisKelamin,
      tempatLahir: _tempatLahirController.text.trim(),
      tanggalLahir: _selectedTanggalLahir,
      agama: _selectedAgama,
      alamat: _alamatController.text.trim(),
      pendidikanTerakhir: _selectedPendidikan,
      status: _selectedStatus,
      createdAt: DateTime.now(),
    );

    try {
      // Panggil Provider
      final success = await context.read<GuruProvider>().addGuru(newGuru);

      if (!mounted) return;

      if (success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('✅ Berhasil'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  const Text('Data Guru dan Akun berhasil dibuat.'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kredensial Login:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        Text('Email: ${newGuru.email}'),
                        Text('Password: 123456'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mohon informasikan kepada guru untuk segera mengganti password saat login pertama kali.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx); // Tutup dialog
                  Navigator.pop(context); // Kembali ke list
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<GuruProvider>().errorMessage ??
                  'Gagal menyimpan data',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nipController.dispose();
    _nuptkController.dispose();
    _namaController.dispose();
    _emailController.dispose();
    _noTelpController.dispose();
    _tempatLahirController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<GuruProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Data Guru')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // === SECTION 1: IDENTITAS ===
                  _buildSectionTitle('Identitas & Akun'),

                  TextFormField(
                    controller: _namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap *',
                      hintText: 'Contoh: Budi Santoso, S.Pd.',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) => v!.isEmpty ? 'Nama Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nuptkController,
                    decoration: const InputDecoration(
                      labelText: 'NUPTK *',
                      hintText: 'Nomor Unik Pendidik',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'NUPTK Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nipController,
                    decoration: const InputDecoration(
                      labelText: 'NIP',
                      hintText: 'Nomor Induk Pegawai',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.card_membership),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),

                  // === SECTION 2: KONTAK ===
                  _buildSectionTitle('Kontak'),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'email@sekolah.sch.id',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _noTelpController,
                    decoration: const InputDecoration(
                      labelText: 'No. Telepon / WA',
                      hintText: '0812xxxxxxxx',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),

                  // === SECTION 3: DATA PRIBADI ===
                  _buildSectionTitle('Data Pribadi'),

                  DropdownButtonFormField<String>(
                    isExpanded: true, // ✅ FIX: Mencegah Overflow
                    value: _selectedJenisKelamin,
                    decoration: const InputDecoration(
                      labelText: 'Jenis Kelamin',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 15,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                      DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                    ],
                    onChanged: (v) =>
                        setState(() => _selectedJenisKelamin = v!),
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    isExpanded: true, // ✅ FIX: Mencegah Overflow
                    value: _selectedAgama,
                    decoration: const InputDecoration(
                      labelText: 'Agama',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 15,
                      ),
                    ),
                    items: _agamaList
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              overflow: TextOverflow.ellipsis,
                            ), // ✅ Safety text
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedAgama = v!),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _tempatLahirController,
                    decoration: const InputDecoration(
                      labelText: 'Tempat Lahir',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Lahir *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _selectedTanggalLahir == null
                            ? 'Pilih'
                            : DateFormat(
                                'dd-MM-yyyy',
                              ).format(_selectedTanggalLahir!),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _alamatController,
                    decoration: const InputDecoration(
                      labelText: 'Alamat Lengkap',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.home),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // === SECTION 4: KEPEGAWAIAN ===
                  _buildSectionTitle('Kepegawaian'),

                  DropdownButtonFormField<String>(
                    isExpanded: true, // ✅ FIX: Mencegah Overflow
                    value: _selectedPendidikan,
                    decoration: const InputDecoration(
                      labelText: 'Pendidikan Terakhir',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
                    ),
                    items: _pendidikanList
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedPendidikan = v!),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    isExpanded: true, // ✅ FIX: Mencegah Overflow
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status Kepegawaian',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.work),
                    ),
                    items: _statusList
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedStatus = v!),
                  ),
                  const SizedBox(height: 32),

                  // === BUTTON SUBMIT ===
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.save),
                      label: const Text(
                        'SIMPAN DATA & BUAT AKUN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const Divider(thickness: 1.5),
        const SizedBox(height: 16),
      ],
    );
  }
}
