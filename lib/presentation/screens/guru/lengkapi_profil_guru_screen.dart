import 'package:flutter/material.dart';
import 'package:monitoring_akademik/presentation/providers/auth_provider.dart';
import 'package:monitoring_akademik/presentation/providers/guru_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
//import '../../providers/auth_provider.dart';
//import '../../providers/guru_provider.dart';

class LengkapiProfilGuruScreen extends StatefulWidget {
  const LengkapiProfilGuruScreen({Key? key}) : super(key: key);

  @override
  State<LengkapiProfilGuruScreen> createState() =>
      _LengkapiProfilGuruScreenState();
}

class _LengkapiProfilGuruScreenState extends State<LengkapiProfilGuruScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nipController = TextEditingController();
  final _nuptkController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _alamatController = TextEditingController();

  String _selectedJenisKelamin = 'Laki-laki';
  String _selectedAgama = 'Islam';
  DateTime? _tanggalLahir;
  bool _isLoading = false;

  final List<String> _jenisKelaminOptions = ['Laki-laki', 'Perempuan'];
  final List<String> _agamaOptions = [
    'Islam',
    'Kristen',
    'Katolik',
    'Hindu',
    'Buddha',
    'Konghucu',
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _tanggalLahir = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_tanggalLahir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Tanggal lahir wajib diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final guruProvider = Provider.of<GuruProvider>(context, listen: false);

    // Get current guru data
    await guruProvider.fetchGuruByProfileId(authProvider.currentUser!.id);

    if (guruProvider.currentGuru == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Data guru tidak ditemukan'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    // Update profil
    final success = await guruProvider.updateGuruProfile(
      guruId: guruProvider.currentGuru!.id,
      nama: guruProvider.currentGuru!.nama,
      nip: _nipController.text.trim(),
      nuptk: _nuptkController.text.trim(),
      jenisKelamin: _selectedJenisKelamin,
      tempatLahir: _tempatLahirController.text.trim(),
      tanggalLahir: _tanggalLahir,
      agama: _selectedAgama,
      alamat: _alamatController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      // Refresh user data
      await authProvider.refreshUser();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Profil berhasil dilengkapi!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to dashboard
      Navigator.pushReplacementNamed(context, '/guru-dashboard');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            guruProvider.errorMessage ?? '❌ Gagal melengkapi profil',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lengkapi Profil Guru'),
        automaticallyImplyLeading: false, // No back button
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ✅ INFO CARD
                    Card(
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Silakan lengkapi profil Anda untuk dapat mengakses dashboard guru.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ✅ NIP
                    TextFormField(
                      controller: _nipController,
                      decoration: const InputDecoration(
                        labelText: 'NIP *',
                        hintText: 'Contoh: 197001012000122001',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'NIP wajib diisi';
                        }
                        if (value.length < 18) {
                          return 'NIP harus 18 digit';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ✅ NUPTK
                    TextFormField(
                      controller: _nuptkController,
                      decoration: const InputDecoration(
                        labelText: 'NUPTK *',
                        hintText: 'Contoh: 1234567890123456',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.credit_card_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'NUPTK wajib diisi';
                        }
                        if (value.length < 16) {
                          return 'NUPTK harus 16 digit';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ✅ Jenis Kelamin
                    DropdownButtonFormField<String>(
                      value: _selectedJenisKelamin,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Kelamin *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      items:
                          _jenisKelaminOptions.map((jk) {
                            return DropdownMenuItem(value: jk, child: Text(jk));
                          }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedJenisKelamin = value!);
                      },
                    ),
                    const SizedBox(height: 16),

                    // ✅ Tempat Lahir
                    TextFormField(
                      controller: _tempatLahirController,
                      decoration: const InputDecoration(
                        labelText: 'Tempat Lahir *',
                        hintText: 'Contoh: Tangerang',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city_outlined),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tempat lahir wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ✅ Tanggal Lahir
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Lahir *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        child: Text(
                          _tanggalLahir == null
                              ? 'Pilih tanggal lahir'
                              : DateFormat(
                                'dd MMMM yyyy',
                                'id_ID',
                              ).format(_tanggalLahir!),
                          style: TextStyle(
                            color:
                                _tanggalLahir == null
                                    ? Colors.grey
                                    : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ✅ Agama
                    DropdownButtonFormField<String>(
                      value: _selectedAgama,
                      decoration: const InputDecoration(
                        labelText: 'Agama *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.mosque_outlined),
                      ),
                      items:
                          _agamaOptions.map((agama) {
                            return DropdownMenuItem(
                              value: agama,
                              child: Text(agama),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedAgama = value!);
                      },
                    ),
                    const SizedBox(height: 16),

                    // ✅ Alamat
                    TextFormField(
                      controller: _alamatController,
                      decoration: const InputDecoration(
                        labelText: 'Alamat *',
                        hintText: 'Contoh: Jl. Merdeka No. 123, Tangerang',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.home_outlined),
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat wajib diisi';
                        }
                        if (value.length < 10) {
                          return 'Alamat minimal 10 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // ✅ Submit Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _submit,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text(
                          'Simpan & Lanjutkan',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  @override
  void dispose() {
    _nipController.dispose();
    _nuptkController.dispose();
    _tempatLahirController.dispose();
    _alamatController.dispose();
    super.dispose();
  }
}
