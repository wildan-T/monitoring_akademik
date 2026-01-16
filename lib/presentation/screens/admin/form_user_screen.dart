import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../../../data/services/supabase_service.dart';

class UserEditScreen extends StatefulWidget {
  final Map<String, dynamic> userProfile;

  const UserEditScreen({super.key, required this.userProfile});

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Akun Controller
  late TextEditingController _emailController;
  final _passwordController = TextEditingController();
  late TextEditingController _phoneController;

  // Wali Murid Controller (Hanya muncul jika role wali)
  final _namaWaliController = TextEditingController();
  final _pekerjaanController = TextEditingController();
  final _alamatController = TextEditingController();

  bool _isLoadingData = false;
  String get _role => widget.userProfile['role'] ?? '';

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.userProfile['email']);
    _phoneController = TextEditingController(
      text: widget.userProfile['no_telepon'],
    );

    if (_role == 'wali_murid') {
      _loadWaliDetail();
    }
  }

  // Load Data Spesifik Wali dari tabel wali_murid
  Future<void> _loadWaliDetail() async {
    setState(() => _isLoadingData = true);
    final detail = await SupabaseService().getWaliDetail(
      widget.userProfile['id'],
    );
    if (detail != null) {
      _namaWaliController.text = detail['nama_lengkap'] ?? '';
      _pekerjaanController.text = detail['pekerjaan'] ?? '';
      _alamatController.text = detail['alamat'] ?? '';
    }
    setState(() => _isLoadingData = false);
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Siapkan Metadata
    Map<String, dynamic> metadata = {
      'no_telepon': _phoneController.text.trim(),
    };

    // Jika Wali Murid, masukkan data spesifik ke metadata untuk dihandle Edge Function
    if (_role == 'wali_murid') {
      metadata['nama_lengkap'] = _namaWaliController.text.trim();
      metadata['pekerjaan'] = _pekerjaanController.text.trim();
      metadata['alamat'] = _alamatController.text.trim();
    }

    final success = await context.read<UserProvider>().updateUser(
      widget.userProfile['id'],
      email: _emailController.text.trim(),
      pass: _passwordController.text.isNotEmpty
          ? _passwordController.text.trim()
          : null,
      meta: metadata,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Akun berhasil diupdate')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal update akun')));
      }
    }
  }

  void _delete() async {
    // Dialog Konfirmasi Hapus Total
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Permanen?'),
        content: const Text(
          'PERINGATAN: Menghapus akun ini akan menghapus DATA GURU/WALI dan SISWA terkait secara permanen!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('HAPUS TOTAL'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await context.read<UserProvider>().deleteUser(
        widget.userProfile['id'],
      );
      if (mounted && success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Akun ${_role.toUpperCase()}'),
        actions: [
          IconButton(
            onPressed: _delete,
            icon: const Icon(Icons.delete_forever, color: Colors.red),
          ),
        ],
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Login Info',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Login',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Wajib' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password Baru (Opsional)',
                        border: OutlineInputBorder(),
                        helperText:
                            'Kosongkan jika tidak ingin mengganti password',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'No. Telepon',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    // FIELD KHUSUS WALI MURID
                    if (_role == 'wali_murid') ...[
                      const Divider(height: 40, thickness: 2),
                      const Text(
                        'Data Wali Murid',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _namaWaliController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap Wali',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _pekerjaanController,
                        decoration: const InputDecoration(
                          labelText: 'Pekerjaan',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _alamatController,
                        decoration: const InputDecoration(
                          labelText: 'Alamat',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ],

                    // FIELD KHUSUS GURU
                    if (_role == 'guru') ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.blue.shade50,
                        child: const Text(
                          'Untuk mengedit data detail Guru (NIP, Pendidikan, dll), silakan gunakan menu "Data Guru". Menu ini hanya untuk Akun Login.',
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _save,
                        child: const Text('SIMPAN PERUBAHAN'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
