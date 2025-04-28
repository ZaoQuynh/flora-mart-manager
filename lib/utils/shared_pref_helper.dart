// lib/utils/shared_pref_helper.dart

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static const String _tokenKey = 'auth_token';
  static const String _userInfoKey = 'user_info';
  
  // Lưu token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }
  
  // Lấy token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  // Xóa token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Lưu thông tin người dùng
  static Future<void> saveUserInfo(String userInfoJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userInfoKey, userInfoJson);
  }
  
  // Lấy thông tin người dùng
  static Future<String?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userInfoKey);
  }
  
  // Xóa thông tin người dùng
  static Future<void> clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userInfoKey);
  }
}