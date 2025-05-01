import 'dart:convert';

import 'package:flora_manager/utils/shared_pref_helper.dart';
import 'package:flutter/material.dart';
import '../app_colors.dart';

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = "Người dùng";
  String? _avatarUrl;
  String _email = "";
  String _phoneNumber = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Lấy thông tin người dùng từ SharedPreferences
      final userJson = await SharedPrefHelper.getUserInfo();
      if (userJson != null) {
        final userData = jsonDecode(userJson);
        setState(() {
          _userName = userData['fullName'] ?? "Người dùng";
          _avatarUrl = userData['avatar'];
          _email = userData['email'] ?? "";
          _phoneNumber = userData['phoneNumber'] ?? "";
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    // Hiển thị dialog xác nhận
    final confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Đăng xuất'),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      await SharedPrefHelper.clearToken();
      await SharedPrefHelper.clearUserInfo();
      
      // Điều hướng về màn hình đăng nhập
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Tài khoản của tôi',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.primary),
            onPressed: _handleLogout,
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _avatarUrl != null
                        ? NetworkImage(_avatarUrl!)
                        : null,
                    child: _avatarUrl == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  if (_phoneNumber.isNotEmpty)
                    Text(
                      _phoneNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  const SizedBox(height: 32),
                  _buildProfileMenuItems(),
                ],
              ),
            ),
    );
  }
  
  Widget _buildProfileMenuItems() {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.edit,
          title: 'Chỉnh sửa thông tin',
          onTap: () {
            // Mở trang chỉnh sửa thông tin
          },
        ),
        _buildMenuItem(
          icon: Icons.settings,
          title: 'Cài đặt',
          onTap: () {
            // Mở trang cài đặt
          },
        ),
        _buildMenuItem(
          icon: Icons.support,
          title: 'Trợ giúp & Hỗ trợ',
          onTap: () {
            // Mở trang trợ giúp
          },
        ),
        _buildMenuItem(
          icon: Icons.info_outline,
          title: 'Về Flora Manager',
          onTap: () {
            // Hiển thị thông tin ứng dụng
          },
        ),
      ],
    );
  }
  
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}