//C:\Users\MSITHIN\monitoring_akademik\lib\presentation\widgets\user_card.dart
import 'package:flutter/material.dart';
import 'package:monitoring_akademik/domain/entities/user_entity.dart';
//import '../../data/models/user_model.dart';
import '../../core/constants/color_constants.dart';
import '../../core/constants/app_constants.dart';

class UserCard extends StatelessWidget {
  //final UserModel user;
  final UserEntity user;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const UserCard({
    super.key,
    required this.user,
    required this.onTap,
    required this.onDelete,
  });

  Color _getRoleColor() {
    switch (user.role) {
      case AppConstants.roleAdmin:
        return AppColors.error;
      case AppConstants.roleGuru:
        return AppColors.primary;
      case AppConstants.roleWaliMurid:
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getRoleLabel() {
    switch (user.role) {
      case AppConstants.roleAdmin:
        return 'Admin';
      case AppConstants.roleGuru:
        return 'Guru';
      case AppConstants.roleWaliMurid:
        return 'Wali Murid';
      default:
        return 'Unknown';
    }
  }

  IconData _getRoleIcon() {
    switch (user.role) {
      case AppConstants.roleAdmin:
        return Icons.admin_panel_settings;
      case AppConstants.roleGuru:
        return Icons.school;
      case AppConstants.roleWaliMurid:
        return Icons.family_restroom;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getRoleColor().withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getRoleIcon(), color: _getRoleColor(), size: 28),
              ),
              const SizedBox(width: 16),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Email or Username
                    Text(
                      user.email.isNotEmpty ? user.email : '@${user.username}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getRoleColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getRoleLabel(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _getRoleColor(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  if (user.username != 'admin') // Tidak bisa hapus admin utama
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: AppColors.error),
                          SizedBox(width: 8),
                          Text(
                            'Hapus',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    onTap();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
