import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../data/models/sekolah_model.dart';
import '../../../../presentation/providers/sekolah_provider.dart';

class SekolahEditScreen extends StatefulWidget {
  const SekolahEditScreen({super.key});

  @override
  State<SekolahEditScreen> createState() => _SekolahEditScreenState();
}

class _SekolahEditScreenState extends State<SekolahEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaSekolahController;
  late TextEditingController _npsnController;
  late TextEditingController _alamatController;
  late TextEditingController _kotaController;
  late TextEditingController _provinsiController;
  late TextEditingController _kodePosController;
  late TextEditingController _noTelpController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  late TextEditingController _namaKepsekController;
  late TextEditingController _nipKepsekController;

  String? _akreditasi;
  String? _statusSekolah;
  bool _isLoading = false;

  final List<String> _daftarAkreditasi = ['A', 'B', 'C', 'Belum Terakreditasi'];
  final List<String> _daftarStatus = ['Negeri', 'Swasta'];

  @override
  void initState() {
    super.initState();
    // Ambil data sekolah dari provider
    final sekolah = context.read<SekolahProvider>().sekolahData;

    // Initialize controllers dengan data existing
    _namaSekolahController = TextEditingController(text: sekolah?.namaSekolah);
    _npsnController = TextEditingController(text: sekolah?.npsn);
    _alamatController = TextEditingController(text: sekolah?.alamat);
    _kotaController = TextEditingController(text: sekolah?.kota);
    _provinsiController = TextEditingController(text: sekolah?.provinsi);
    _kodePosController = TextEditingController(text: sekolah?.kodePos);
    _noTelpController = TextEditingController(text: sekolah?.noTelp);
    _emailController = TextEditingController(text: sekolah?.email);
    _websiteController = TextEditingController(text: sekolah?.website);
    _namaKepsekController = TextEditingController(
      text: sekolah?.namaKepalaSekolah,
    );
    _nipKepsekController = TextEditingController(
      text: sekolah?.nipKepalaSekolah,
    );

    _akreditasi = sekolah?.akreditasi;
    _statusSekolah = sekolah?.statusSekolah;
  }

  @override
  void dispose() {
    _namaSekolahController.dispose();
    _npsnController.dispose();
    _alamatController.dispose();
    _kotaController.dispose();
    _provinsiController.dispose();
    _kodePosController.dispose();
    _noTelpController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _namaKepsekController.dispose();
    _nipKepsekController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Data Sekolah')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Perubahan data akan mempengaruhi seluruh sistem',
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section 1: Informasi Umum
            _buildSectionTitle('Informasi Umum'),
            _buildTextField(
              controller: _namaSekolahController,
              label: 'Nama Sekolah',
              hint: 'Masukkan nama sekolah',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama sekolah wajib diisi';
                }
                return null;
              },
            ),
            _buildTextField(
              controller: _npsnController,
              label: 'NPSN',
              hint: 'Masukkan NPSN',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'NPSN wajib diisi';
                }
                return null;
              },
            ),
            _buildDropdown(
              label: 'Akreditasi',
              value: _akreditasi,
              items: _daftarAkreditasi,
              onChanged: (value) {
                setState(() {
                  _akreditasi = value!;
                });
              },
            ),
            _buildDropdown(
              label: 'Status Sekolah',
              value: _statusSekolah,
              items: _daftarStatus,
              onChanged: (value) {
                setState(() {
                  _statusSekolah = value!;
                });
              },
            ),

            const SizedBox(height: 24),

            // Section 2: Alamat
            _buildSectionTitle('Alamat'),
            _buildTextField(
              controller: _alamatController,
              label: 'Alamat Lengkap',
              hint: 'Masukkan alamat lengkap',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Alamat wajib diisi';
                }
                return null;
              },
            ),
            _buildTextField(
              controller: _kotaController,
              label: 'Kota/Kabupaten',
              hint: 'Masukkan kota/kabupaten',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kota/Kabupaten wajib diisi';
                }
                return null;
              },
            ),
            _buildTextField(
              controller: _provinsiController,
              label: 'Provinsi',
              hint: 'Masukkan provinsi',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Provinsi wajib diisi';
                }
                return null;
              },
            ),
            _buildTextField(
              controller: _kodePosController,
              label: 'Kode Pos',
              hint: 'Masukkan kode pos',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kode pos wajib diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Section 3: Kontak
            _buildSectionTitle('Informasi Kontak'),
            _buildTextField(
              controller: _noTelpController,
              label: 'No. Telepon',
              hint: 'Masukkan nomor telepon',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'No. telepon wajib diisi';
                }
                return null;
              },
            ),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'Masukkan alamat email',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email wajib diisi';
                }
                if (!value.contains('@')) {
                  return 'Email tidak valid';
                }
                return null;
              },
            ),
            _buildTextField(
              controller: _websiteController,
              label: 'Website',
              hint: 'Masukkan website sekolah',
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Website wajib diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Section 4: Kepala Sekolah
            _buildSectionTitle('Kepala Sekolah'),
            _buildTextField(
              controller: _namaKepsekController,
              label: 'Nama Kepala Sekolah',
              hint: 'Masukkan nama kepala sekolah',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama kepala sekolah wajib diisi';
                }
                return null;
              },
            ),
            _buildTextField(
              controller: _nipKepsekController,
              label: 'NIP Kepala Sekolah',
              hint: 'Masukkan NIP kepala sekolah',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'NIP kepala sekolah wajib diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Button Submit
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'SIMPAN PERUBAHAN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Button Batal
            SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'BATAL',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final currentSekolah = context.read<SekolahProvider>().sekolahData;

    final updatedSekolah = SekolahModel(
      id: currentSekolah?.id ?? '',
      namaSekolah: _namaSekolahController.text,
      npsn: _npsnController.text,
      alamat: _alamatController.text,
      kota: _kotaController.text,
      provinsi: _provinsiController.text,
      kodePos: _kodePosController.text,
      noTelp: _noTelpController.text,
      email: _emailController.text,
      website: _websiteController.text,
      namaKepalaSekolah: _namaKepsekController.text,
      nipKepalaSekolah: _nipKepsekController.text,
      akreditasi: _akreditasi ?? '',
      statusSekolah: _statusSekolah ?? '',
      // logoPath: currentSekolah?.logoPath,
      createdAt: currentSekolah?.createdAt,
    );

    final success = await context.read<SekolahProvider>().updateSekolah(
      updatedSekolah,
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data sekolah berhasil diupdate'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        final errorMessage = context.read<SekolahProvider>().errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'Gagal mengupdate data sekolah'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
