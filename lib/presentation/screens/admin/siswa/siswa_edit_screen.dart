import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../data/models/siswa_model.dart';
import '../../../providers/siswa_provider.dart';
import '../../../providers/kelas_provider.dart';

class SiswaEditScreen extends StatefulWidget {
  final SiswaModel siswa; // Data siswa yang akan diedit

  const SiswaEditScreen({super.key, required this.siswa});

  @override
  State<SiswaEditScreen> createState() => _SiswaEditScreenState();
}

class _SiswaEditScreenState extends State<SiswaEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nisnController;
  late TextEditingController _nisController;
  late TextEditingController _namaController;
  late TextEditingController _tempatLahirController;
  late TextEditingController _alamatController;
  late TextEditingController _agamaController;
  late TextEditingController _namaAyahController;
  late TextEditingController _namaIbuController;

  // State Variables
  String? _selectedKelasId;
  String? _selectedGender;
  String? _selectedStatus;
  DateTime? _tanggalLahir;

  // Opsi Status (Sesuai Check Constraint DB)
  final List<String> _statusOptions = ['aktif', 'lulus', 'pindah', 'keluar'];

  @override
  void initState() {
    super.initState();
    final s = widget.siswa;

    // Load data kelas agar dropdown terisi
    Future.microtask(() => context.read<KelasProvider>().fetchAllKelas());

    // Isi form dengan data lama
    _nisnController = TextEditingController(text: s.nisn);
    _nisController = TextEditingController(text: s.nis);
    _namaController = TextEditingController(text: s.nama);
    _tempatLahirController = TextEditingController(text: s.tempatLahir);
    _alamatController = TextEditingController(text: s.alamat);
    _agamaController = TextEditingController(text: s.agama);
    _namaAyahController = TextEditingController(text: s.namaAyah);
    _namaIbuController = TextEditingController(text: s.namaIbu);

    _selectedKelasId = s.kelasId;
    _selectedGender = s.jenisKelamin;
    _selectedStatus = s.status;
    _tanggalLahir = s.tanggalLahir;
  }

  @override
  void dispose() {
    _nisnController.dispose();
    _nisController.dispose();
    _namaController.dispose();
    _tempatLahirController.dispose();
    _alamatController.dispose();
    _agamaController.dispose();
    _namaAyahController.dispose();
    _namaIbuController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedKelasId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kelas wajib dipilih!')));
      return;
    }

    // Buat objek SiswaModel baru dengan data update
    // Kita gunakan model, nanti Provider akan panggil .toJson()
    final updatedSiswa = SiswaModel(
      id: widget.siswa.id, // ID Tetap
      nisn: _nisnController.text.trim(),
      nis: _nisController.text.trim(),
      nama: _namaController.text.trim(),
      jenisKelamin: _selectedGender,
      kelasId: _selectedKelasId,
      tempatLahir: _tempatLahirController.text.trim(),
      tanggalLahir: _tanggalLahir,
      agama: _agamaController.text.trim(),
      alamat: _alamatController.text.trim(),
      namaAyah: _namaAyahController.text.trim(),
      namaIbu: _namaIbuController.text.trim(),
      status: _selectedStatus ?? 'aktif',
      // Field Wali tidak diedit dari sini (karena beda tabel)
      waliMuridId: widget.siswa.waliMuridId,
    );

    final provider = context.read<SiswaProvider>();
    // Panggil fungsi update di Provider
    // Perhatikan: Provider Anda menerima (String id, SiswaModel siswa)
    final success = await provider.updateSiswa(widget.siswa.id, updatedSiswa);

    if (mounted) {
      if (success) {
        Navigator.pop(context); // Kembali ke list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data siswa berhasil diperbarui'),
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
        title: const Text('Edit Data Siswa'),
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
              _buildSectionTitle('Data Akademik'),
              _buildTextField(
                _nisnController,
                'NISN',
                true,
                isNumber: true,
                minLength: 10,
                maxLength: 10,
              ),
              _buildTextField(
                _nisController,
                'NIS',
                true,
                isNumber: true,
                minLength: 10,
                maxLength: 18,
              ),

              // Dropdown Kelas
              Consumer<KelasProvider>(
                builder: (context, kelasProv, _) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Kelas',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedKelasId,
                      // Pastikan ID kelas yang lama masih ada di list kelas, kalau tidak reset null
                      items: kelasProv.kelasList.map((k) {
                        return DropdownMenuItem(
                          value: k.id,
                          child: Text(k.namaKelas),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _selectedKelasId = val),
                      validator: (val) =>
                          val == null ? 'Wajib pilih kelas' : null,
                    ),
                  );
                },
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Status Siswa',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedStatus,
                  items: _statusOptions.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(
                        s.toUpperCase(),
                        style: TextStyle(
                          color: s == 'aktif' ? Colors.green : Colors.red,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedStatus = val),
                ),
              ),

              const SizedBox(height: 16),
              _buildSectionTitle('Identitas Pribadi'),
              _buildTextField(_namaController, 'Nama Lengkap', true),

              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Jenis Kelamin',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedGender,
                        items: const [
                          DropdownMenuItem(
                            value: 'L',
                            child: Text('Laki-laki'),
                          ),
                          DropdownMenuItem(
                            value: 'P',
                            child: Text('Perempuan'),
                          ),
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedGender = val),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _tanggalLahir ?? DateTime(2010),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => _tanggalLahir = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Lahir',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today, size: 18),
                          ),
                          child: Text(
                            _tanggalLahir != null
                                ? DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(_tanggalLahir!)
                                : '-',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              _buildTextField(_tempatLahirController, 'Tempat Lahir', true),

              // Dropdown Agama
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Agama',
                    border: OutlineInputBorder(),
                  ),
                  value:
                      [
                        'Islam',
                        'Kristen Protestan',
                        'Katolik',
                        'Hindu',
                        'Buddha',
                        'Khonghucu',
                        'Lainnya',
                      ].contains(_agamaController.text)
                      ? _agamaController.text
                      : null, // Handle jika data lama typo/null
                  items:
                      [
                            'Islam',
                            'Kristen Protestan',
                            'Katolik',
                            'Hindu',
                            'Buddha',
                            'Khonghucu',
                            'Lainnya',
                          ]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (val) {
                    if (val != null) _agamaController.text = val;
                  },
                ),
              ),

              _buildTextField(_alamatController, 'Alamat', true, maxLines: 2),

              const SizedBox(height: 16),
              _buildSectionTitle('Data Orang Tua (Arsip)'),
              _buildTextField(_namaAyahController, 'Nama Ayah Kandung', true),
              _buildTextField(_namaIbuController, 'Nama Ibu Kandung', true),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Wali Murid saat ini: ${widget.siswa.namaWali ?? '-'}\n(Data wali tidak dapat diedit dari menu ini)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Consumer<SiswaProvider>(
                  builder: (context, provider, _) {
                    return ElevatedButton(
                      onPressed: provider.isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: provider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'UPDATE DATA SISWA',
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    bool required, {
    bool isNumber = false,
    int maxLines = 1,
    int? minLength,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          counterText: "",
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        maxLength: maxLength,
        validator: (val) {
          if (required && (val == null || val.isEmpty)) {
            return '$label wajib diisi';
          }
          if (val != null && val.isNotEmpty) {
            if (minLength != null && val.length < minLength) {
              return '$label minimal $minLength karakter';
            }
          }
          return null;
        },
      ),
    );
  }
}
