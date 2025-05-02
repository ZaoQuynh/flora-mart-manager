import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/shared_pref_helper.dart';

class PlantService {
  static const String baseUrl = 'http://192.168.1.165:8080/api/v1/plant';

  // Thêm cây mới
  static Future<Map<String, dynamic>?> addPlant(Map<String, dynamic> plantData) async {
    try {
      final token = await SharedPrefHelper.getToken();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(plantData),
      );

      debugPrint('Add plant response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Add plant error: $e');
    }
    return null;
  }

  // Lấy thông tin cây theo ID
  static Future<Map<String, dynamic>?> getPlantById(int plantId) async {
    try {
      final token = await SharedPrefHelper.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/$plantId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Plant by ID response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Get plant by ID error: $e');
    }
    return null;
  }

  // Cập nhật thông tin cây
  static Future<Map<String, dynamic>?> updatePlant(int plantId, Map<String, dynamic> plantData) async {
    try {
      final token = await SharedPrefHelper.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/$plantId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(plantData),
      );

      debugPrint('Update plant response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Update plant error: $e');
    }
    return null;
  }

  // Xóa cây
  static Future<bool> deletePlant(int plantId) async {
    try {
      final token = await SharedPrefHelper.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/$plantId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Delete plant response: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Delete plant error: $e');
      return false;
    }
  }

  // Lấy danh sách tất cả các cây
  static Future<List<dynamic>?> getAllPlants() async {
    try {
      final token = await SharedPrefHelper.getToken();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('All plants response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Get all plants error: $e');
    }
    return null;
  }
}