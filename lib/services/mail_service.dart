// lib/services/mail_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

enum MailType {
  registerOtp,
  updateInfoOtp,
  forgetPasswordOtp,
}

class MailService {
  static const String baseUrl = 'http://192.168.1.165:8080/api/v1/mail';

  // Lấy nội dung email dựa trên loại email và mã OTP
  Map<String, String> getEmailContent(MailType type, String otp) {
    switch (type) {
      case MailType.registerOtp:
        return {
          'subject': 'Chào mừng đến với Flora Mart! Đây là mã OTP của bạn',
          'body': 'Cảm ơn bạn đã đăng ký với Flora Mart. Mã OTP của bạn là: $otp. Vui lòng sử dụng mã này để hoàn tất đăng ký.'
        };
      case MailType.updateInfoOtp:
        return {
          'subject': 'Flora Mart: Mã OTP để cập nhật thông tin của bạn',
          'body': 'Bạn đã yêu cầu cập nhật thông tin trên Flora Mart. Mã OTP của bạn là: $otp. Vui lòng sử dụng mã này để tiếp tục.'
        };
      case MailType.forgetPasswordOtp:
        return {
          'subject': 'Flora Mart: Đặt lại mật khẩu của bạn',
          'body': 'Bạn đã yêu cầu đặt lại mật khẩu trên Flora Mart. Mã OTP của bạn là: $otp. Vui lòng sử dụng mã này để hoàn tất quá trình.'
        };
      default:
        throw Exception('Không xác định được loại email');
    }
  }

  // Gửi email
  Future<bool> sendEmail(String email, String subject, String body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'subject': subject,
          'body': body,
        }),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Send email failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Send email error: $e');
      return false;
    }
  }

  // Gửi OTP qua email
  Future<bool> sendOtpEmail(String email, MailType type, String otp) async {
    try {
      final content = getEmailContent(type, otp);
      return await sendEmail(email, content['subject']!, content['body']!);
    } catch (e) {
      debugPrint('Send OTP email error: $e');
      return false;
    }
  }
}