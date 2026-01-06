import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monitoring_akademik/core/constants/color_constants.dart';
import 'package:monitoring_akademik/data/models/siswa_model.dart';
import 'package:monitoring_akademik/presentation/providers/siswa_provider.dart';

class SiswaAddScreen extends StatefulWidget {
  const SiswaAddScreen({super.key});

  @override
  State<SiswaAddScreen> createState() => _SiswaAddScreenState();
}

class _SiswaAddScreenState extends State<SiswaAddScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nisController = TextEditingController();
  final _nisnController = TextEditingController();
  final _namaController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _alamatController = TextEditingController();
  final _namaAyahController = TextEditingController();
  final _namaIbuController = TextEditingController();
  final _noTelpController = TextEditingController();

  // Dropdown values
  String _jenisKelamin = 'L';
  String _agama = 'Islam';
  String _kelas = '7A';
  String _tahunMasuk = DateTime.now().year.toString();
  DateTime _tanggalLahir = DateTime(2010, 1, 1);

  @override
  void dispose() {
    _nisController.dispose();
    _nisnController.dispose();
    _namaController.dispose();
    _tempatLahirController.dispose();
    _alamatController.dispose();
    _namaAyahController.dispose();
    _namaIbuController.dispose();
    _noTelpController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalLahir,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _tanggalLahir) {
      setState(() {
        _tanggalLahir = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final siswaProvider = Provider.of<SiswaProvider>(context, listen: false);

      final newSiswa = SiswaModel(
        id: '', // ID akan di-generate di provider
        nis: _nisController.text.trim(),
        nisn: _nisnController.text.trim(),
        nama: _namaController.text.trim(),
        jenisKelamin: _jenisKelamin,
        tempatLahir: _tempatLahirController.text.trim(),
        tanggalLahir: _tanggalLahir,
        agama: _agama,
        alamat: _alamatController.text.trim(),
        namaAyah: _namaAyahController.text.trim(),
        namaIbu: _namaIbuController.text.trim(),
        noTelpOrangTua: _noTelpController.text.trim(),
        kelas: _kelas,
        tahunMasuk: _tahunMasuk,
        status: 'Aktif',
      );

      final success = await siswaProvider.createSiswa(newSiswa);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Siswa berhasil ditambahkan'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              siswaProvider.errorMessage ?? 'Gagal menambahkan siswa',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Siswa')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Section: Data Pribadi
            _buildSectionTitle('Data Pribadi'),
            const SizedBox(height: 16),

            // NIS
            TextFormField(
              controller: _nisController,
              decoration: const InputDecoration(
                labelText: 'NIS *',
                hintText: 'Masukkan NIS',
                prefixIcon: Icon(Icons.badge),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'NIS tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // NISN
            TextFormField(
              controller: _nisnController,
              decoration: const InputDecoration(
                labelText: 'NISN *',
                hintText: 'Masukkan NISN',
                prefixIcon: Icon(Icons.credit_card),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'NISN tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Nama
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap *',
                hintText: 'Masukkan nama lengkap',
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Jenis Kelamin
            DropdownButtonFormField<String>(
              value: _jenisKelamin,
              decoration: const InputDecoration(
                labelText: 'Jenis Kelamin *',
                prefixIcon: Icon(Icons.wc),
              ),
              items: const [
                DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                DropdownMenuItem(value: 'P', child: Text('Perempuan')),
              ],
              onChanged: (value) {
                setState(() {
                  _jenisKelamin = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Tempat Lahir
            TextFormField(
              controller: _tempatLahirController,
              decoration: const InputDecoration(
                labelText: 'Tempat Lahir *',
                hintText: 'Masukkan tempat lahir',
                prefixIcon: Icon(Icons.location_city),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tempat lahir tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Tanggal Lahir
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Tanggal Lahir *',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_tanggalLahir.day.toString().padLeft(2, '0')}-'
                      '${_tanggalLahir.month.toString().padLeft(2, '0')}-'
                      '${_tanggalLahir.year}',
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Agama
            DropdownButtonFormField<String>(
              value: _agama,
              decoration: const InputDecoration(
                labelText: 'Agama *',
                prefixIcon: Icon(Icons.mosque),
              ),
              items: const [
                DropdownMenuItem(value: 'Islam', child: Text('Islam')),
                DropdownMenuItem(value: 'Kristen', child: Text('Kristen')),
                DropdownMenuItem(value: 'Katolik', child: Text('Katolik')),
                DropdownMenuItem(value: 'Hindu', child: Text('Hindu')),
                DropdownMenuItem(value: 'Buddha', child: Text('Buddha')),
                DropdownMenuItem(value: 'Konghucu', child: Text('Konghucu')),
              ],
              onChanged: (value) {
                setState(() {
                  _agama = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Alamat
            TextFormField(
              controller: _alamatController,
              decoration: const InputDecoration(
                labelText: 'Alamat *',
                hintText: 'Masukkan alamat lengkap',
                prefixIcon: Icon(Icons.home),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Alamat tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Section: Data Orang Tua
            _buildSectionTitle('Data Orang Tua'),
            const SizedBox(height: 16),

            // Nama Ayah
            TextFormField(
              controller: _namaAyahController,
              decoration: const InputDecoration(
                labelText: 'Nama Ayah *',
                hintText: 'Masukkan nama ayah',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama ayah tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Nama Ibu
            TextFormField(
              controller: _namaIbuController,
              decoration: const InputDecoration(
                labelText: 'Nama Ibu *',
                hintText: 'Masukkan nama ibu',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama ibu tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // No Telp Orang Tua
            TextFormField(
              controller: _noTelpController,
              decoration: const InputDecoration(
                labelText: 'No. Telp Orang Tua *',
                hintText: 'Masukkan nomor telepon',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nomor telepon tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Section: Data Akademik
            _buildSectionTitle('Data Akademik'),
            const SizedBox(height: 16),

            // Kelas
            DropdownButtonFormField<String>(
              value: _kelas,
              decoration: const InputDecoration(
                labelText: 'Kelas *',
                prefixIcon: Icon(Icons.class_),
              ),
              items: [
                for (int i = 7; i <= 9; i++)
                  for (String huruf in [
                    'A',
                    'B',
                    'C',
                    'D',
                    'E',
                    'F',
                    'G',
                    'H',
                    'I',
                    'J',
                  ])
                    DropdownMenuItem(
                      value: '$i$huruf',
                      child: Text('Kelas $i$huruf'),
                    ),
              ],
              onChanged: (value) {
                setState(() {
                  _kelas = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Tahun Masuk
            DropdownButtonFormField<String>(
              value: _tahunMasuk,
              decoration: const InputDecoration(
                labelText: 'Tahun Masuk *',
                prefixIcon: Icon(Icons.calendar_month),
              ),
              items: List.generate(5, (index) {
                final year = DateTime.now().year - index;
                return DropdownMenuItem(
                  value: year.toString(),
                  child: Text(year.toString()),
                );
              }),
              onChanged: (value) {
                setState(() {
                  _tahunMasuk = value!;
                });
              },
            ),
            const SizedBox(height: 32),

            // Submit Button
            Consumer<SiswaProvider>(
              builder: (context, siswaProvider, child) {
                return SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: siswaProvider.isLoading ? null : _handleSubmit,
                    child:
                        siswaProvider.isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                              ),
                            )
                            : const Text('SIMPAN'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.primary, width: 2)),
      ),
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
}
