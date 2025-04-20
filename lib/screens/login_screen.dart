import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final colors = {
    'primary': const Color(0xFF6A9B41),      // Xanh lá chính
    'secondary': const Color(0xFF212934),    // Xám đậm
    'accent': const Color(0xFFECF4E7),       // Xanh lá nhạt
    'text': const Color(0xFF212934),         // Màu chữ chính
    'textLight': const Color(0xFF6E7A8A),    // Màu chữ nhạt
    'background': Colors.white,              // Nền trắng
    'error': const Color(0xFFE53935),        // Đỏ lỗi
    'buttonText': Colors.white,              // Chữ nút
  };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors['background'],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                Center(
                  child: Container(
                    height: 72,
                    width: 72,
                    decoration: BoxDecoration(
                      color: colors['accent'],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.store_outlined,
                      color: colors['primary'],
                      size: 40,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                Text(
                  'Chào mừng trở lại',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colors['text'],
                    letterSpacing: -0.5,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Đăng nhập để quản lý cửa hàng của bạn',
                  style: TextStyle(
                    fontSize: 16,
                    color: colors['textLight'],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                _buildTextField(
                  controller: _emailController,
                  label: 'Email hoặc Tên đăng nhập',
                  icon: Icons.person_outline,
                ),
                
                const SizedBox(height: 16),
                
                _buildPasswordField(),
                
                const SizedBox(height: 12),
                
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Xử lý quên mật khẩu
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: colors['primary'],
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Quên mật khẩu?',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                _buildLoginButton(),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: colors['text']),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: colors['textLight']),
          prefixIcon: Icon(icon, color: colors['textLight']),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colors['primary']!, width: 1.5),
          ),
          fillColor: Colors.grey[100],
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: TextStyle(color: colors['text']),
        decoration: InputDecoration(
          labelText: 'Mật khẩu',
          labelStyle: TextStyle(color: colors['textLight']),
          prefixIcon: Icon(Icons.lock_outline, color: colors['textLight']),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: colors['textLight'],
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colors['primary']!, width: 1.5),
          ),
          fillColor: Colors.grey[100],
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          final username = _emailController.text;
          final password = _passwordController.text;
          
          print('Username: $username, Password: $password');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colors['primary'],
          foregroundColor: colors['buttonText'],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Đăng nhập',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color iconColor) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor),
        onPressed: () {
        },
      ),
    );
  }
}