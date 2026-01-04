//=== FILE 6: form_user_screen.dart ===
//C:\Users\MSITHIN\monitoring_akademik\lib\presentation\screens\admin\form_user_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../../core/constants/app_constants.dart';

class FormUserScreen extends StatefulWidget {
  final String? userId; // null = tambah, ada value = edit
  
  const FormUserScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<FormUserScreen> createState() => _FormUserScreenState();
}

class _FormUserScreenState extends State<FormUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String _selectedRole = AppConstants.roleGuru;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _loadUserData();
    }
  }

  void _loadUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.users.firstWhere(
      (u) => u.id == widget.userId,
      orElse: () => throw Exception('User not found'),
    );

    _usernameController.text = user.username;
    _nameController.text = user.name;
    _emailController.text = user.email;
    _phoneController.text = user.phone ?? '';
    _selectedRole = user.role;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    bool success;
    if (widget.userId == null) {
      // Mode: Tambah user baru
      success = await userProvider.createUser(
        username: _usernameController.text.trim(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
        phone: _phoneController.text.trim().isEmpty 
            ? null 
            : _phoneController.text.trim(),
      );
    } else {
      // Mode: Edit user
      success = await userProvider.updateUser(
        userId: widget.userId!,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty 
            ? null 
            : _phoneController.text.trim(),
        role: _selectedRole,
      );
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.userId == null 
              ? '✅ User berhasil ditambahkan' 
              : '✅ User berhasil diupdate'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userProvider.error ?? '❌ Terjadi kesalahan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userId == null ? 'Tambah User' : 'Edit User'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ✅ INFO CARD
                  if (widget.userId == null)
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'User dengan role Guru akan otomatis dibuatkan profil guru yang dapat dilengkapi nanti.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // ✅ Username
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username *',
                      hintText: 'Contoh: heni.rizki',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    enabled: widget.userId == null, // Disable saat edit
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Username wajib diisi';
                      }
                      if (value.contains(' ')) {
                        return 'Username tidak boleh mengandung spasi';
                      }
                      if (value.length < 3) {
                        return 'Username minimal 3 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ✅ Nama Lengkap
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap *',
                      hintText: 'Contoh: Heni Rizki Amalia',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama wajib diisi';
                      }
                      if (value.length < 3) {
                        return 'Nama minimal 3 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ✅ Email (WAJIB)
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      hintText: 'Contoh: heni.rizki@smpn20.sch.id',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email wajib diisi';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ✅ Password (hanya untuk tambah user)
                  if (widget.userId == null) ...[
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password *',
                        hintText: 'Minimal 6 karakter',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password wajib diisi';
                        }
                        if (value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ✅ No Telepon (Optional)
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'No. Telepon (opsional)',
                      hintText: 'Contoh: 081234567890',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (value.length < 10) {
                          return 'No. telepon minimal 10 digit';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ✅ Role
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.verified_user_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: AppConstants.roleGuru,
                        child: Row(
                          children: [
                            Icon(Icons.school, size: 20),
                            SizedBox(width: 8),
                            Text('Guru'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: AppConstants.roleWali,
                        child: Row(
                          children: [
                            Icon(Icons.family_restroom, size: 20),
                            SizedBox(width: 8),
                            Text('Wali Murid'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: AppConstants.roleAdmin,
                        child: Row(
                          children: [
                            Icon(Icons.admin_panel_settings, size: 20),
                            SizedBox(width: 8),
                            Text('Super Admin'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedRole = value!);
                    },
                  ),
                  const SizedBox(height: 24),

                  // ✅ Submit Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submit,
                      icon: Icon(_isLoading 
                          ? Icons.hourglass_empty 
                          : (widget.userId == null ? Icons.add : Icons.save)),
                      label: Text(
                        widget.userId == null ? 'Tambah User' : 'Update User',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
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
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}