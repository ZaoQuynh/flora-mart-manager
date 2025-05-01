import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/shared_pref_helper.dart';

class ProductService {
  static const String baseUrl = 'http://192.168.1.165:8080/api/v1/product';

  // Lấy danh sách tất cả sản phẩm
  static Future<List<dynamic>?> getProducts() async {
    try {
      final token = await SharedPrefHelper.getToken();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Get products response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Get products error: $e');
    }
    return null;
  }

  // Thêm sản phẩm mới
  static Future<Map<String, dynamic>?> addProduct(Map<String, dynamic> productData) async {
    try {
      final token = await SharedPrefHelper.getToken();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(productData),
      );

      debugPrint('Add product response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Add product error: $e');
    }
    return null;
  }

  // Tìm 10 sản phẩm tương tự theo ID
  static Future<List<dynamic>?> getSimilarProducts(int productId) async {
    try {
      final token = await SharedPrefHelper.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/similar/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Get similar products response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Get similar products error: $e');
    }
    return null;
  }

  // Lấy danh sách sản phẩm theo danh sách ID
  static Future<List<dynamic>?> getProductsByIds(List<int> ids) async {
    try {
      final token = await SharedPrefHelper.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/get-by-ids'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'ids': ids}),
      );

      debugPrint('Get products by IDs response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Get products by IDs error: $e');
    }
    return null;
  }
}
