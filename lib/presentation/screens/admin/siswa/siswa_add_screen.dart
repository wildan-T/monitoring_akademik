// lib/presentation/screens/admin/siswa/siswa_add_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../providers/siswa_provider.dart';
import '../../../providers/kelas_provider.dart'; // Pastikan ada

class SiswaAddScreen extends StatefulWidget {
  const SiswaAddScreen({super.key});

  @override
  State<SiswaAddScreen> createState() => _SiswaAddScreenState();
}

class _SiswaAddScreenState extends State<SiswaAddScreen> {
  final _formKey = GlobalKey<FormState>();

  // -- Data Siswa --
  final _nisnController = TextEditingController();
  final _nisController = TextEditingController();
  final _namaController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _alamatController = TextEditingController();
  final _agamaController = TextEditingController();
  final _namaAyahController = TextEditingController();
  final _namaIbuController = TextEditingController();

  // -- Data Wali (Untuk Akun) --
  final _namaWaliController = TextEditingController();
  final _noHpWaliController = TextEditingController();
  final _emailWaliController = TextEditingController();
  final _pekerjaanWaliController = TextEditingController();

  String? _selectedKelasId;
  String? _selectedGender; // Siswa
  String? _selectedGenderWali;
  String? _selectedHubungan; // ayah/ibu/wali
  DateTime? _tanggalLahir;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<KelasProvider>().fetchAllKelas());
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedKelasId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih Kelas!')));
      return;
    }

    // Persiapan Payload ke Edge Function
    final payload = {
      // Data Siswa
      'nisn': _nisnController.text.trim(),
      'nis': _nisController.text.trim(),
      'nama_lengkap': _namaController.text.trim(),
      'jenis_kelamin': _selectedGender,
      'tempat_lahir': _tempatLahirController.text.trim(),
      'tanggal_lahir': _tanggalLahir?.toIso8601String(),
      'agama': _agamaController.text.trim(),
      'alamat': _alamatController.text.trim(),
      'nama_ayah': _namaAyahController.text.trim(),
      'nama_ibu': _namaIbuController.text.trim(),
      'kelas_id': _selectedKelasId,

      // Data Wali (Penting untuk Edge Function index.ts)
      'nama_wali': _namaWaliController.text.trim(),
      'jk_wali': _selectedGenderWali,
      'pekerjaan_wali': _pekerjaanWaliController.text.trim(),
      'alamat_wali': _alamatController.text.trim(), // Asumsi sama dgn siswa
      'hubungan_wali': _selectedHubungan,
      'email': _emailWaliController.text.trim().isNotEmpty
          ? _emailWaliController.text.trim()
          : '${_nisnController.text.trim()}@wali.sekolah.id', // Generate Default
      'no_telepon': _noHpWaliController.text.trim(),
    };

    final success = await context.read<SiswaProvider>().addSiswa(payload);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Siswa & Akun Wali Berhasil Dibuat'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<SiswaProvider>().errorMessage ?? 'Gagal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Siswa & Wali'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header('Data Siswa'),
              Row(
                children: [
                  Expanded(
                    child: _field(_nisnController, 'NISN', true, number: true),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _field(_nisController, 'NIS', false, number: true),
                  ),
                ],
              ),
              _field(_namaController, 'Nama Lengkap Siswa', true),

              // Dropdown Kelas
              Consumer<KelasProvider>(
                builder: (context, kProv, _) => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Kelas',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedKelasId,
                  items: kProv.kelasList
                      .map(
                        (k) => DropdownMenuItem(
                          value: k.id,
                          child: Text(k.namaKelas),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedKelasId = val),
                  validator: (val) => val == null ? 'Wajib pilih' : null,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _dropdown(
                      ['L', 'P'],
                      'Jenis Kelamin',
                      (v) => _selectedGender = v,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2010),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (d != null) setState(() => _tanggalLahir = d);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tgl Lahir',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _tanggalLahir == null
                              ? '-'
                              : DateFormat('dd/MM/yyyy').format(_tanggalLahir!),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _field(_tempatLahirController, 'Tempat Lahir', true),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Agama',
                  border: OutlineInputBorder(),
                ),
                items:
                    const [
                          'Islam',
                          'Kristen',
                          'Katolik',
                          'Hindu',
                          'Buddha',
                          'Konghucu',
                        ]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) => _agamaController.text = val ?? '',
                validator: (val) => val == null ? 'Agama wajib dipilih' : null,
              ),
              const SizedBox(height: 16),

              _field(_alamatController, 'Alamat', true, maxLines: 2),
              _field(_namaAyahController, 'Nama Ayah', false),
              _field(_namaIbuController, 'Nama Ibu', false),

              const SizedBox(height: 24),
              _header('Data Wali Murid (Otomatis Buat Akun)'),
              _field(_namaWaliController, 'Nama Wali', true),
              Row(
                children: [
                  Expanded(
                    child: _dropdown(
                      ['L', 'P'],
                      'Jenis Kelamin',
                      (v) => _selectedGenderWali = v,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _dropdown(
                      ['ayah', 'ibu', 'wali'],
                      'Hubungan',
                      (v) => _selectedHubungan = v,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _field(_pekerjaanWaliController, 'Pekerjaan', false),
              _field(_noHpWaliController, 'No HP / WA', true, number: true),
              _field(
                _emailWaliController,
                'Email Wali (Opsional - Default NISN)',
                false,
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Consumer<SiswaProvider>(
                  builder: (context, prov, _) => ElevatedButton(
                    onPressed: prov.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: prov.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'SIMPAN',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),
    ),
  );

  Widget _field(
    TextEditingController c,
    String label,
    bool req, {
    bool number = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: number ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        validator: req
            ? (v) => v == null || v.isEmpty ? '$label wajib' : null
            : null,
      ),
    );
  }

  Widget _dropdown(
    List<String> items,
    String label,
    Function(String?) onChange,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase())))
          .toList(),
      onChanged: onChange,
    );
  }
}
