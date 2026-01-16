import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Import Intl
import '../../../../core/constants/color_constants.dart';
import '../../../../data/models/guru_model.dart';
import '../../../providers/guru_provider.dart';

class GuruEditScreen extends StatefulWidget {
  final GuruModel guru;

  const GuruEditScreen({super.key, required this.guru});

  @override
  State<GuruEditScreen> createState() => _GuruEditScreenState();
}

class _GuruEditScreenState extends State<GuruEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nuptkController;
  late TextEditingController _nipController;
  late TextEditingController _namaController;
  late TextEditingController _emailController;
  late TextEditingController _noTelpController;
  late TextEditingController _alamatController;

  // ✅ Controllers Tambahan
  late TextEditingController _tempatLahirController;
  late TextEditingController _pendidikanController;

  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedStatus;
  String? _selectedAgama;

  // Daftar Pilihan Agama
  final List<String> _agamaOptions = [
    'Islam',
    'Kristen Protestan',
    'Katolik',
    'Hindu',
    'Buddha',
    'Khonghucu',
    'Lainnya',
  ];

  final List<String> _pendidikanOptions = ['D3', 'S1', 'S2', 'S3', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    // Initialize Controllers
    _nuptkController = TextEditingController(text: widget.guru.nuptk);
    _nipController = TextEditingController(text: widget.guru.nip);
    _namaController = TextEditingController(text: widget.guru.nama);
    _emailController = TextEditingController(text: widget.guru.email);
    _noTelpController = TextEditingController(text: widget.guru.noTelp);
    _alamatController = TextEditingController(text: widget.guru.alamat);

    // ✅ Load Data Tambahan
    _tempatLahirController = TextEditingController(
      text: widget.guru.tempatLahir,
    );
    _pendidikanController = TextEditingController(
      text: widget.guru.pendidikanTerakhir,
    );

    if (_agamaOptions.contains(widget.guru.agama)) {
      _selectedAgama = widget.guru.agama;
    } else {
      _selectedAgama = null; // Atau handle custom
    }
    _selectedDate = widget.guru.tanggalLahir;
    _selectedGender = widget.guru.jenisKelamin;
    _selectedStatus = widget.guru.status;
  }

  @override
  void dispose() {
    _nuptkController.dispose();
    _nipController.dispose();
    _namaController.dispose();
    _emailController.dispose();
    _noTelpController.dispose();
    _alamatController.dispose();
    _tempatLahirController.dispose();
    _pendidikanController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _updateData() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<GuruProvider>();

    // Update Objek dengan copyWith
    final updatedGuru = widget.guru.copyWith(
      nuptk: _nuptkController.text.trim(),
      nip: _nipController.text.trim(),
      nama: _namaController.text.trim(),
      email: _emailController.text.trim(),
      noTelp: _noTelpController.text.trim(),
      alamat: _alamatController.text.trim(),
      jenisKelamin: _selectedGender,
      status: _selectedStatus,

      // ✅ Field Tambahan
      tempatLahir: _tempatLahirController.text.trim(),
      tanggalLahir: _selectedDate,
      agama: _selectedAgama,
      pendidikanTerakhir: _pendidikanController.text.trim(),
    );

    final success = await provider.updateGuru(updatedGuru);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil update data guru'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Gagal update data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Data Guru'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Data Utama ---
              const Text(
                'Data Utama',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nuptkController,
                decoration: const InputDecoration(
                  labelText: 'NUPTK',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'NUPTK wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nipController,
                decoration: const InputDecoration(
                  labelText: 'NIP',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'NIP wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Nama wajib diisi' : null,
              ),
              // const SizedBox(height: 16),

              // TextFormField(
              //   controller: _emailController,
              //   decoration: const InputDecoration(
              //     labelText: 'Email',
              //     border: OutlineInputBorder(),
              //   ),
              // ),
              const SizedBox(height: 24),

              // --- Biodata Lengkap ---
              const Text(
                'Biodata Lengkap',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tempatLahirController,
                      decoration: const InputDecoration(
                        labelText: 'Tempat Lahir',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Lahir',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today, size: 18),
                        ),
                        child: Text(
                          _selectedDate != null
                              ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                              : 'Pilih',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Jenis Kelamin',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                  DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                ],
                onChanged: (val) => setState(() => _selectedGender = val),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedAgama, // Nilai yang dipilih
                decoration: const InputDecoration(
                  labelText: 'Agama',
                  border: OutlineInputBorder(),
                ),
                items: _agamaOptions.map((agama) {
                  return DropdownMenuItem(value: agama, child: Text(agama));
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedAgama = val;
                  });
                },
                validator: (val) => val == null ? 'Agama wajib dipilih' : null,
              ),
              const SizedBox(height: 16),

              // TextFormField(
              //   controller: _noTelpController,
              //   decoration: const InputDecoration(
              //     labelText: 'No. Telepon',
              //     border: OutlineInputBorder(),
              //   ),
              //   keyboardType: TextInputType.phone,
              // ),
              // const SizedBox(height: 16),
              TextFormField(
                controller: _alamatController,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // --- Kepegawaian ---
              const Text(
                'Kepegawaian',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _pendidikanOptions.contains(_pendidikanController.text)
                    ? _pendidikanController.text
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Pendidikan Terakhir',
                  border: OutlineInputBorder(),
                ),
                items: _pendidikanOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) _pendidikanController.text = val;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status Kepegawaian',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'PNS', child: Text('PNS')),
                  DropdownMenuItem(value: 'PPPK', child: Text('PPPK')),
                  DropdownMenuItem(value: 'Honorer', child: Text('Honorer')),
                  DropdownMenuItem(
                    value: 'Tetap Yayasan',
                    child: Text('Tetap Yayasan'),
                  ),
                ],
                onChanged: (val) => setState(() => _selectedStatus = val),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: Consumer<GuruProvider>(
                  builder: (context, provider, _) {
                    return ElevatedButton(
                      onPressed: provider.isLoading ? null : _updateData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: provider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'UPDATE DATA',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
