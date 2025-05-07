import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/shared_pref_helper.dart';

class DescriptionGroupService {
  static const String baseUrl = 'http://localhost:8080/api/v1/description-group';

  // Lấy danh sách nhóm mô tả
  static Future<List<dynamic>?> getDescriptionGroups() async {
    try {
      final token = await SharedPrefHelper.getToken();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Description groups response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Get description groups error: $e');
    }
    return null;
  }
}
