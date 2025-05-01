import 'package:flutter/material.dart';
import '../../app_colors.dart';

class UserHeaderWidget extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final VoidCallback onAddNewPlant;

  const UserHeaderWidget({
    super.key,
    required this.userName,
    this.avatarUrl,
    required this.onAddNewPlant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào,',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: onAddNewPlant,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Thêm cây mới'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
        image: avatarUrl != null && avatarUrl!.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(avatarUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: avatarUrl == null || avatarUrl!.isEmpty
          ? const Icon(
              Icons.person,
              color: AppColors.primary,
              size: 30,
            )
          : null,
    );
  }
}