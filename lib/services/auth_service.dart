import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/auth_reponse.dart';
import '../utils/shared_pref_helper.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:8080/api/v1/auth';

  // Đăng nhập
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      debugPrint('Login response: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
          if(authResponse.accessToken.isEmpty) {
            return {'success': false, 'message': 'Không nhận được access token.'};
          }

          if (authResponse.user.role != "ADMIN") {
            return {'success': false, 'message': 'Tài khoản không có quyền ADMIN.'};
          }

          await SharedPrefHelper.saveToken(authResponse.accessToken);
          await SharedPrefHelper.saveUserInfo(jsonEncode(response.body));

          return {'success': true, 'message': 'Đăng nhập thành công!'};
        } catch (e) {
          return {'success': false, 'message': 'Lỗi xử lý dữ liệu từ server.'};
        }
      } else {
        return {'success': false, 'message': 'Sai email hoặc mật khẩu.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ.'};
    }
  }


  // Đăng ký
  static Future<bool> register(Map<String, String> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      debugPrint('Register response: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Register error: $e');
      return false;
    }
  }

  // Xác thực tài khoản
  static Future<bool> verifyAccount(String email) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      debugPrint('Verify response: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Verify error: $e');
      return false;
    }
  }

  // Kiểm tra email đã tồn tại
  static Future<bool> checkEmailExists(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/check-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      debugPrint('Check email response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as bool;
      }
      return false;
    } catch (e) {
      debugPrint('Check email error: $e');
      return false;
    }
  }

  // Kiểm tra username đã tồn tại
  static Future<bool> checkUsernameExists(String username) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/check-username'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      debugPrint('Check username response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as bool;
      }
      return false;
    } catch (e) {
      debugPrint('Check username error: $e');
      return false;
    }
  }

  // Đặt lại mật khẩu
  static Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'newPassword': newPassword,
        }),
      );

      debugPrint('Reset password response: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Reset password error: $e');
      return false;
    }
  }

  // Đăng xuất
  static Future<bool> logout() async {
    try {
      // Xóa token và thông tin người dùng
      await SharedPrefHelper.clearToken();
      await SharedPrefHelper.clearUserInfo();
      return true;
    } catch (e) {
      debugPrint('Logout error: $e');
      return false;
    }
  }
  
  // Kiểm tra đã đăng nhập
  static Future<bool> isLoggedIn() async {
    final token = await SharedPrefHelper.getToken();
    return token != null && token.isNotEmpty;
  }
}