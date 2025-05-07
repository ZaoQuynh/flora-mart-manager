// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/order_management_screen.dart';
import 'screens/product_screen.dart';
import 'screens/profile_screen.dart';
import 'app_colors.dart';
import 'services/auth_service.dart';
import 'screens/statistics_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Cố định hướng màn hình (tùy chọn)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flora Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.text,
          elevation: 0,
        ),
        fontFamily: 'Roboto',
      ),
      home: const AuthCheckScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) {
          // Check if there's a tab index passed as an argument
          final args = ModalRoute.of(context)?.settings.arguments;
          return MainScreen(initialTabIndex: args is int ? args : 0);
        },
      },
    );
  }
}

// Màn hình chính điều khiển bottom navigation
class MainScreen extends StatefulWidget {
  final int initialTabIndex;

  const MainScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();

  // Static method to access the state
  static void navigateToTab(BuildContext context, int tabIndex) {
    final navigatorState = Navigator.of(context);
    // Check if already on MainScreen
    if (context.findAncestorWidgetOfExactType<MainScreen>() != null) {
      // Get the state using GlobalKey
      final mainScreenState =
          context.findRootAncestorStateOfType<_MainScreenState>();
      if (mainScreenState != null) {
        mainScreenState.changeTab(tabIndex);
      }
    } else {
      // Navigate to MainScreen with the specified tab
      navigatorState.pushNamedAndRemoveUntil(
        '/main',
        (route) => false,
        arguments: tabIndex,
      );
    }
  }
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  // Danh sách các màn hình tương ứng với các tab
  final List<Widget> _screens = [
    const HomeScreen(),
    const ProductScreen(), // Tạo file này nếu chưa có
    const StatisticsScreen(), // Tạo file này nếu chưa có
    const OrderManagementScreen(orders: [], shouldFetchOrders: true),
    const ProfileScreen(), // Tạo file này nếu chưa có
  ];

  // Phương thức để các widget con có thể kích hoạt chuyển tab
  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
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
            icon: Icon(Icons.bar_chart),
            label: 'Thống kê',
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
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// Màn hình kiểm tra trạng thái đăng nhập
class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    // Kiểm tra xem đã đăng nhập chưa
    final isLoggedIn = await AuthService.isLoggedIn();

    // Điều hướng dựa trên trạng thái đăng nhập
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              isLoggedIn ? const MainScreen() : const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
