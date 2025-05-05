import 'dart:convert';
import 'package:flora_manager/services/plant_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/shared_pref_helper.dart';

class ProductService {
  static const String baseUrl = 'http://192.168.1.165:8080/api/v1/product';
  
  // Thêm sản phẩm mới với hai bước: (1) tạo Plant, (2) tạo Product
  static Future<Map<String, dynamic>?> addProduct(Map<String, dynamic> productData) async {
    try {
      // Bước 1: Tạo Plant trước
      Map<String, dynamic>? plantData = productData['plant'];
      if (plantData == null) {
        debugPrint('Plant data is missing');
        return null;
      }
      
      // Gọi API tạo Plant
      final createdPlant = await PlantService.addPlant(plantData);
      if (createdPlant == null) {
        debugPrint('Failed to create plant');
        return null;
      }
      
      // Bước 2: Tạo Product với ID của Plant đã tạo
      final productToCreate = {...productData};
      productToCreate['plant'] = {'id': createdPlant['id']};
      
      final token = await SharedPrefHelper.getToken();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(productToCreate),
      );

      debugPrint('Add product response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Failed to create product, status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        
        // Nếu tạo Product thất bại, xóa Plant đã tạo (cleanup)
        if (createdPlant['id'] != null) {
          await PlantService.deletePlant(createdPlant['id']);
          debugPrint('Deleted plant due to product creation failure');
        }
      }
    } catch (e) {
      debugPrint('Add product error: $e');
    }
    return null;
  }

  // Cập nhật sản phẩm với hai bước: (1) cập nhật Plant, (2) cập nhật Product
  static Future<Map<String, dynamic>?> updateProduct(dynamic productId, Map<String, dynamic> productData) async {
    try {
      // Bước 1: Cập nhật Plant trước
      Map<String, dynamic>? plantData = productData['plant'];
      if (plantData == null || plantData['id'] == null) {
        debugPrint('Plant data or Plant ID is missing');
        return null;
      }
      
      // Gọi API cập nhật Plant
      final updatedPlant = await PlantService.updatePlant(
        plantData['id'], 
        plantData
      );
      
      if (updatedPlant == null) {
        debugPrint('Failed to update plant');
        return null;
      }
      
      // Bước 2: Cập nhật Product với ID của Plant đã cập nhật
      final productToUpdate = {...productData};
      productToUpdate['plant'] = {'id': updatedPlant['id']};
      
      final token = await SharedPrefHelper.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(productToUpdate),
      );

      debugPrint('Update product response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Failed to update product, status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Update product error: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getProductById(dynamic productId) async {
    try {
      final token = await SharedPrefHelper.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Get product by ID response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Get product by ID error: $e');
    }
    return null;
  }

  static Future<List<dynamic>?> getAllProducts() async {
    try {
      final token = await SharedPrefHelper.getToken();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Get all products response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Get all products error: $e');
    }
    return null;
  }

  static Future<bool> deleteProduct(dynamic productId) async {
    try {
      final token = await SharedPrefHelper.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Delete product response: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Delete product error: $e');
      return false;
    }
  }
}