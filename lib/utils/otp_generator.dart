import 'dart:math';

class OtpGenerator {
  // Tạo OTP với độ dài mặc định là 6 chữ số
  static String generateOtp({int length = 6}) {
    final random = Random();
    String otp = '';
    
    for (int i = 0; i < length; i++) {
      otp += random.nextInt(10).toString();
    }
    
    return otp;
  }
  
  // Kiểm tra xem OTP có hợp lệ không
  static bool verifyOtp(String enteredOtp, String generatedOtp) {
    return enteredOtp == generatedOtp;
  }
}