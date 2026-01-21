import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_constants.dart';
import '../../providers/guru_provider.dart';

class GuruProfileScreen extends StatefulWidget {
  const GuruProfileScreen({super.key});

  @override
  State<GuruProfileScreen> createState() => _GuruProfileScreenState();
}

class _GuruProfileScreenState extends State<GuruProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  // Controllers
  late TextEditingController _namaController;
  late TextEditingController _nipController;
  late TextEditingController _nuptkController;
  late TextEditingController _tempatLahirController;
  late TextEditingController _tanggalLahirController;
  late TextEditingController _alamatController;
  late TextEditingController _noTelpController;

  // Dropdown Values
  String? _selectedGender;
  String? _selectedAgama;
  String? _selectedPendidikan;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final guru = context.read<GuruProvider>().currentGuru;

    _namaController = TextEditingController(text: guru?.nama ?? '');
    _nipController = TextEditingController(text: guru?.nip ?? '');
    _nuptkController = TextEditingController(text: guru?.nuptk ?? '');
    _tempatLahirController = TextEditingController(
      text: guru?.tempatLahir ?? '',
    );
    _tanggalLahirController = TextEditingController(
      text: guru?.tanggalLahir != null
          ? DateFormat('yyyy-MM-dd').format(guru!.tanggalLahir!)
          : '',
    );
    _alamatController = TextEditingController(text: guru?.alamat ?? '');
    // Asumsi di model ada noTelepon/noHp
    _noTelpController = TextEditingController(text: '');

    _selectedGender = guru?.jenisKelamin;
    _selectedAgama = guru?.agama;
    _selectedPendidikan = guru?.pendidikanTerakhir;
    _selectedStatus = guru?.status;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nipController.dispose();
    _nuptkController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _alamatController.dispose();
    _noTelpController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    if (!_isEditing) return;
    DateTime initial = DateTime.now();
    try {
      if (_tanggalLahirController.text.isNotEmpty) {
        initial = DateFormat('yyyy-MM-dd').parse(_tanggalLahirController.text);
      }
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _tanggalLahirController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    final guruProv = context.read<GuruProvider>();
    final currentGuru = guruProv.currentGuru;

    if (currentGuru == null) return;

    final success = await guruProv.updateGuruProfile(
      guruId: currentGuru.id,
      nuptk: _nuptkController.text,
      nama: _namaController.text,
      nip: _nipController.text,
      alamat: _alamatController.text,
      pendidikanTerakhir: _selectedPendidikan,
      jenisKelamin: _selectedGender,
      tempatLahir: _tempatLahirController.text,
      tanggalLahir: _tanggalLahirController.text.isNotEmpty
          ? DateFormat('yyyy-MM-dd').parse(_tanggalLahirController.text)
          : null,
      agama: _selectedAgama,
      statusKepegawaian: _selectedStatus,
    );

    if (mounted) {
      if (success) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil berhasil diperbarui"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(guruProv.errorMessage ?? "Gagal update"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final guruProv = context.watch<GuruProvider>();
    final guru = guruProv.currentGuru;

    if (guru == null)
      return const Scaffold(body: Center(child: Text("Data tidak ditemukan")));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Saya"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER PROFILE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              color: AppColors.primary,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Text(
                      guru.nama.isNotEmpty ? guru.nama[0] : '?',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    guru.nama,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "NIP: ${(guru.nip ?? '').isEmpty ? '-' : guru.nip}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            // FORM
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Data Pribadi"),
                    _buildTextField(
                      "Nama Lengkap",
                      _namaController,
                      enabled: _isEditing,
                    ),
                    _buildTextField("NIP", _nipController, enabled: _isEditing),
                    _buildTextField(
                      "NUPTK",
                      _nuptkController,
                      enabled: _isEditing,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            "Tempat Lahir",
                            _tempatLahirController,
                            enabled: _isEditing,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: _pickDate,
                            child: AbsorbPointer(
                              child: _buildTextField(
                                "Tanggal Lahir",
                                _tanggalLahirController,
                                enabled: _isEditing,
                                icon: Icons.calendar_today,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    _buildDropdown(
                      "Jenis Kelamin",
                      _selectedGender,
                      ['L', 'P'],
                      (val) => setState(() => _selectedGender = val),
                    ),
                    _buildDropdown(
                      "Agama",
                      _selectedAgama,
                      [
                        'Islam',
                        'Kristen',
                        'Katolik',
                        'Hindu',
                        'Buddha',
                        'Konghucu',
                      ],
                      (val) => setState(() => _selectedAgama = val),
                    ),

                    _buildTextField(
                      "Alamat",
                      _alamatController,
                      maxLines: 2,
                      enabled: _isEditing,
                    ),

                    const SizedBox(height: 20),
                    _buildSectionTitle("Kepegawaian & Kontak"),

                    _buildDropdown(
                      "Pendidikan Terakhir",
                      _selectedPendidikan,
                      ['SMA', 'D3', 'S1', 'S2', 'S3'],
                      (val) => setState(() => _selectedPendidikan = val),
                    ),
                    _buildDropdown(
                      "Status Kepegawaian",
                      _selectedStatus,
                      ['PNS', 'PPPK', 'GTY', 'GTT'],
                      (val) => setState(() => _selectedStatus = val),
                    ),

                    const SizedBox(height: 30),

                    if (_isEditing)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  _initData(); // Reset form
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text("Batal"),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: guruProv.isLoading ? null : _saveData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: guruProv.isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "Simpan",
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 40),
                  ],
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
    int maxLines = 1,
    IconData? icon,
    TextInputType inputType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        keyboardType: inputType,
        validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: !enabled,
          fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: !_isEditing,
          fillColor: Colors.grey.shade100,
        ),
        value: items.contains(value) ? value : null,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: _isEditing ? onChanged : null,
      ),
    );
  }
}
