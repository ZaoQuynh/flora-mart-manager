import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/shared_pref_helper.dart';

class OrderService {
  static const String baseUrl = 'http://192.168.1.165:8080/api/v1/order';

  // Lấy danh sách tất cả đơn hàng (ADMIN)
  static Future<List<dynamic>?> getAllOrders() async {
    try {
      final token = await SharedPrefHelper.getToken();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('All orders response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Get all orders error: $e');
    }
    return null;
  }

  // Lấy chi tiết đơn hàng theo ID
  static Future<Map<String, dynamic>?> getOrderById(int orderId) async {
    try {
      final token = await SharedPrefHelper.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Order by ID response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Get order by ID error: $e');
    }
    return null;
  }

  // Lấy danh sách đơn hàng của người dùng
  static Future<List<dynamic>?> getMyOrders() async {
    try {
      final token = await SharedPrefHelper.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/my-order'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('My orders response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Get my orders error: $e');
    }
    return null;
  }

  // Lấy thống kê dòng tiền từ đơn hàng của người dùng
  static Future<Map<String, dynamic>?> getMyOrderFlowStats() async {
    try {
      final token = await SharedPrefHelper.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/my-order-flow-stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('My order flow stats response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Get my order flow stats error: $e');
    }
    return null;
  }

  // Thêm đơn hàng mới
  static Future<Map<String, dynamic>?> addOrder(Map<String, dynamic> orderData) async {
    try {
      final token = await SharedPrefHelper.getToken();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(orderData),
      );

      debugPrint('Add order response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Add order error: $e');
    }
    return null;
  }

  // Hủy đơn hàng
  static Future<Map<String, dynamic>?> cancelOrder(int orderId) async {
    try {
      final token = await SharedPrefHelper.getToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/cancel/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Cancel order response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Cancel order error: $e');
    }
    return null;
  }

  // Xác nhận đã nhận hàng
  static Future<Map<String, dynamic>?> receiveOrder(int orderId) async {
    try {
      final token = await SharedPrefHelper.getToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/receive/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Receive order response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Receive order error: $e');
    }
    return null;
  }

   static Future<Map<String, dynamic>?> updateOrderStatus(int orderId) async {
    try {
      final token = await SharedPrefHelper.getToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/status/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Update order status response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Update order status failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Update order status error: $e');
    }
    return null;
  }
}
