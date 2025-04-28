import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../utils/shared_pref_helper.dart';
import 'dart:convert';

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
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        _buildUserHeader(),
        const SizedBox(height: 24),
        _buildDashboardCards(),
        const SizedBox(height: 24),
        _buildRecentOrders(),
      ],
    );
  }

  Widget _buildUserHeader() {
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
                _userName,
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
            onPressed: () {
              // Xử lý khi nhấn nút thêm cây mới
            },
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
        image: _avatarUrl != null && _avatarUrl!.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(_avatarUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: _avatarUrl == null || _avatarUrl!.isEmpty
          ? const Icon(
              Icons.person,
              color: AppColors.primary,
              size: 30,
            )
          : null,
    );
  }

  Widget _buildDashboardCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng quan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                icon: Icons.shopping_bag,
                title: 'Tổng đơn hàng',
                value: '124',
                color: Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                icon: Icons.inventory_2,
                title: 'Loại cây',
                value: '45',
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                icon: Icons.people,
                title: 'Khách hàng',
                value: '86',
                color: Colors.orange,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                icon: Icons.money,
                title: 'Doanh thu',
                value: '14.5tr',
                color: Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Đơn hàng gần đây',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Xử lý khi nhấn nút xem tất cả
                },
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3, // Chỉ hiển thị 3 đơn hàng gần nhất
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return _buildOrderItem(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(int index) {
    // Dữ liệu mẫu
    final orders = [
      {
        'id': 'ĐH-001',
        'customer': 'Nguyễn Văn A',
        'date': '25/04/2025',
        'amount': '450.000đ',
        'status': 'Đã giao',
      },
      {
        'id': 'ĐH-002',
        'customer': 'Trần Thị B',
        'date': '24/04/2025',
        'amount': '780.000đ',
        'status': 'Đang giao',
      },
      {
        'id': 'ĐH-003',
        'customer': 'Lê Văn C',
        'date': '22/04/2025',
        'amount': '320.000đ',
        'status': 'Đã huỷ',
      },
    ];

    final order = orders[index];
    
    // Xác định màu trạng thái
    Color statusColor;
    switch (order['status']) {
      case 'Đã giao':
        statusColor = Colors.green;
        break;
      case 'Đang giao':
        statusColor = Colors.blue;
        break;
      case 'Đã huỷ':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.receipt,
          color: AppColors.primary,
          size: 24,
        ),
      ),
      title: Text(
        '${order['id']} - ${order['customer']}',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        '${order['date']} | ${order['amount']}',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          order['status']!,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
      onTap: () {
        // Xử lý khi nhấn vào đơn hàng
      },
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Sản phẩm',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Đơn hàng',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Cá nhân',
        ),
      ],
      onTap: (index) {
        // Xử lý khi chọn các tab khác nhau
      },
    );
  }
}