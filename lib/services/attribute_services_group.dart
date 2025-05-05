import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/shared_pref_helper.dart';

class AttributeGroupService {
  static const String baseUrl = 'http://192.168.1.165:8080/api/v1/attribute-group';

  // Lấy danh sách nhóm thuộc tính
  static Future<List<dynamic>?> getAttributeGroups() async {
    try {
      final token = await SharedPrefHelper.getToken();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Attribute groups response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Get attribute groups error: $e');
    }
    return null;
  }

  // Thêm nhóm thuộc tính
  static Future<Map<String, dynamic>?> addAttributeGroup(Map<String, dynamic> groupData) async {
    try {
      final token = await SharedPrefHelper.getToken();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(groupData),
      );

      debugPrint('Add attribute group response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Add attribute group error: $e');
    }
    return null;
  }
}
