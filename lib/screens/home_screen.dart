import 'package:flutter/material.dart';
import 'dart:convert';
import '../app_colors.dart';
import '../utils/shared_pref_helper.dart';
import '../widgets/user_header_widget.dart';
import '../widgets/dashboard_cards_widget.dart';
import '../widgets/recent_orders_widget.dart';
import '../widgets/bottom_nav_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = "Người dùng";
  String? _avatarUrl;
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
          'Flora Manager',
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
          : _buildHomeContent(),
      bottomNavigationBar: const BottomNavBarWidget(currentIndex: 0),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          UserHeaderWidget(
            userName: _userName, 
            avatarUrl: _avatarUrl,
            onAddNewPlant: () {
              // Xử lý khi nhấn nút thêm cây mới
            },
          ),
          const SizedBox(height: 24),
          const DashboardCardsWidget(),
          const SizedBox(height: 24),
          const RecentOrdersWidget(),
        ],
      ),
    );
  }
}