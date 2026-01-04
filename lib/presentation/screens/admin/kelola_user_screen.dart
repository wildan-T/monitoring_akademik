//C:\Users\MSITHIN\monitoring_akademik\lib\presentation\screens\admin\kelola_user_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/user_provider.dart';
import '../../widgets/user_card.dart';
import 'form_user_screen.dart';

class KelolaUserScreen extends StatefulWidget {
  const KelolaUserScreen({super.key});

  @override
  State<KelolaUserScreen> createState() => _KelolaUserScreenState();
}

class _KelolaUserScreenState extends State<KelolaUserScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String userId,
    String userName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus user "$userName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final userProvider = Provider.of<UserProvider>(
                context,
                listen: false,
              );
              final success = await userProvider.deleteUser(userId);

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'User berhasil dihapus'
                        : userProvider.error ?? 'Gagal menghapus user',
                  ),
                  backgroundColor: success
                      ? AppColors.success
                      : AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola User'), elevation: 0),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading && userProvider.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final displayedUsers = userProvider.filteredUsers;

          return Column(
            children: [
              // Header Stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari user...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                    });
                                    userProvider.searchUser('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          userProvider.searchUser(value);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total User',
                            userProvider.getTotalByRole('all').toString(),
                            Icons.people,
                            AppColors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Admin',
                            userProvider
                                .getTotalByRole(AppConstants.roleAdmin)
                                .toString(),
                            Icons.admin_panel_settings,
                            AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Guru',
                            userProvider
                                .getTotalByRole(AppConstants.roleGuru)
                                .toString(),
                            Icons.school,
                            AppColors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Wali Murid',
                            userProvider
                                .getTotalByRole(AppConstants.roleWali)
                                .toString(),
                            Icons.family_restroom,
                            AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Filter Chips
              Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        'Semua',
                        'all',
                        userProvider.selectedRole == 'all',
                        userProvider,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Admin',
                        AppConstants.roleAdmin,
                        userProvider.selectedRole == AppConstants.roleAdmin,
                        userProvider,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Guru',
                        AppConstants.roleGuru,
                        userProvider.selectedRole == AppConstants.roleGuru,
                        userProvider,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Wali Murid',
                        AppConstants.roleWali,
                        userProvider.selectedRole == AppConstants.roleWali,
                        userProvider,
                      ),
                    ],
                  ),
                ),
              ),

              // User List
              Expanded(
                child: displayedUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 80,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'Tidak ada hasil pencarian'
                                  : 'Tidak ada user',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => userProvider.fetchUsers(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: displayedUsers.length,
                          itemBuilder: (context, index) {
                            final user = displayedUsers[index];
                            return UserCard(
                              user: user , // ✅ FIXED: Use 'userEntity' parameter name
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FormUserScreen(userId: user.id),
                                  ),
                                );

                                if (result == true && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('User berhasil diupdate'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              },
                              onDelete: () {
                                _showDeleteConfirmation(
                                  context,
                                  user.id,
                                  user.name,
                                );
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormUserScreen()),
          );

          if (result == true && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User berhasil ditambahkan'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah User'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: textColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: textColor.withValues(alpha: 0.9),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    bool isSelected,
    UserProvider provider,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        provider.filterByRole(value);
      },
      backgroundColor: AppColors.white,
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? AppColors.primary
              : AppColors.textSecondary.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
