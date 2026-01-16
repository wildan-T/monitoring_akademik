import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../../../core/constants/color_constants.dart';
import 'form_user_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<UserProvider>().fetchUsers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Akun'),
        backgroundColor: AppColors.primary,
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading)
            return const Center(child: CircularProgressIndicator());

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.userList.length,
            itemBuilder: (context, index) {
              final user = provider.userList[index];
              final role = user['role'] ?? 'user';
              final isActive = user['is_active'] ?? false;

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getRoleColor(role).withOpacity(0.2),
                    child: Icon(_getRoleIcon(role), color: _getRoleColor(role)),
                  ),
                  title: Text(
                    user['email'] ?? 'No Email',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Role: ${role.toUpperCase()} | Aktif: ${isActive ? "Ya" : "Tidak"}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserEditScreen(userProfile: user),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getRoleColor(String role) {
    if (role == 'admin') return Colors.red;
    if (role == 'guru') return Colors.blue;
    if (role == 'wali_murid') return Colors.green;
    return Colors.grey;
  }

  IconData _getRoleIcon(String role) {
    if (role == 'admin') return Icons.admin_panel_settings;
    if (role == 'guru') return Icons.school;
    if (role == 'wali_murid') return Icons.family_restroom;
    return Icons.person;
  }
}
