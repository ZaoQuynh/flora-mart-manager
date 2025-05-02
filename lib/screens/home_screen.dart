import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../utils/shared_pref_helper.dart';
import '../services/order_service.dart';
import '../services/product_service.dart';
import '../widgets/user_header_widget.dart';
import '../widgets/dashboard_cards_widget.dart';
import '../widgets/recent_orders_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoadingOrders = true;
  bool _isLoadingProducts = true;
  List<dynamic> _orders = [];
  List<dynamic> _products = [];
  String? _ordersError;
  double _totalRevenue = 0;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _fetchProducts();
  }

  Future<void> _fetchOrders() async {
    try {
      setState(() {
        _isLoadingOrders = true;
        _ordersError = null;
      });

      final orders = await OrderService.getAllOrders();
      
      if (orders != null) {
        // Calculate total revenue from orders
        double totalRevenue = 0;
        for (var order in orders) {
          // Assuming each order has a 'totalPrice' or similar field
          if (order['totalPrice'] != null) {
            totalRevenue += (order['totalPrice'] as num).toDouble();
          }
        }

        setState(() {
          _orders = orders;
          _totalRevenue = totalRevenue;
          _isLoadingOrders = false;
        });
      } else {
        setState(() {
          _ordersError = 'Không thể tải dữ liệu đơn hàng';
          _isLoadingOrders = false;
        });
      }
    } catch (e) {
      setState(() {
        _ordersError = 'Đã xảy ra lỗi: $e';
        _isLoadingOrders = false;
      });
    }
  }

  Future<void> _fetchProducts() async {
    try {
      setState(() {
        _isLoadingProducts = true;
      });

      final products = await ProductService.getAllProducts();
      
      if (products != null) {
        setState(() {
          _products = products;
          _isLoadingProducts = false;
        });
      } else {
        setState(() {
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingProducts = false;
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
      body: _buildHomeContent(),
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          _fetchOrders(),
          _fetchProducts(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            UserHeaderWidget(
              onAddNewPlant: () {
                // Xử lý khi nhấn nút thêm cây mới
              }, userName: 'John Doe',
            ),
            const SizedBox(height: 24),
            DashboardCardsWidget(
              isLoading: _isLoadingOrders || _isLoadingProducts,
              orderCount: _orders.length,
              productCount: _products.length,
              customerCount: _getUniqueCustomerCount(),
              totalRevenue: _totalRevenue,
            ),
            const SizedBox(height: 24),
            RecentOrdersWidget(
              orders: _orders,
              isLoading: _isLoadingOrders,
              error: _ordersError,
              onRetry: _fetchOrders,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get unique customer count from orders
  int _getUniqueCustomerCount() {
    if (_orders.isEmpty) return 0;
    
    // Extract unique customer IDs from orders
    final Set<dynamic> uniqueCustomerIds = {};
    
    for (var order in _orders) {
      if (order['customerId'] != null) {
        uniqueCustomerIds.add(order['customerId']);
      }
    }
    
    return uniqueCustomerIds.length;
  }
}