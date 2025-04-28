import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_colors.dart';
import '../services/auth_service.dart';
import '../services/mail_service.dart';
import '../utils/otp_generator.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final Map userData;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.userData,
  });

  @override
  State createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  late String _generatedOtp;
  bool _isVerifying = false;
  bool _isSendingOtp = false;
  String? _errorMessage;
  bool _otpSent = false;
  
  int _resendTime = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _generateAndSendOtp();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  // Tạo và gửi OTP
  Future<void> _generateAndSendOtp() async {
    setState(() {
      _isSendingOtp = true;
      _errorMessage = null;
    });

    try {
      // Tạo OTP
      _generatedOtp = OtpGenerator.generateOtp();
      debugPrint('Generated OTP: $_generatedOtp');

      // Gửi email
      final mailService = MailService();
      final result = await mailService.sendOtpEmail(
        widget.email,
        MailType.registerOtp,
        _generatedOtp,
      );
      
      if (result) {
        setState(() {
          _otpSent = true;
          _startResendTimer();
        });
      } else {
        setState(() {
          _errorMessage = 'Không thể gửi mã OTP. Vui lòng thử lại.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể gửi mã OTP. Vui lòng thử lại.';
      });
      debugPrint('Error sending OTP: $e');
    } finally {
      setState(() {
        _isSendingOtp = false;
      });
    }
  }

  // Bắt đầu bộ đếm thời gian để gửi lại OTP
  void _startResendTimer() {
    setState(() {
      _resendTime = 60;
    });
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTime > 0) {
          _resendTime--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  // Xác thực OTP
  Future<void> _verifyOtp() async {
    // Nối các số OTP từ các trường input
    final enteredOtp = _controllers.map((controller) => controller.text).join();
    
    if (enteredOtp.length != 6) {
      setState(() {
        _errorMessage = 'Vui lòng nhập đầy đủ 6 chữ số OTP';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      if (enteredOtp == _generatedOtp) {
        // OTP hợp lệ, tiến hành đăng ký người dùng
        final success = await AuthService.register(
          widget.userData.map((key, value) => MapEntry(key.toString(), value.toString())),
        );
        
        if (success) {
          await AuthService.verifyAccount(widget.email);
          
          if (mounted) {
            _showSuccessDialog();
          }
        } else {
          setState(() {
            _errorMessage = 'Đăng ký không thành công. Vui lòng thử lại.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Mã OTP không chính xác. Vui lòng thử lại.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      });
      debugPrint('Verification error: $e');
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  // Hiển thị dialog thành công
  // Hiển thị dialog thành công với điều hướng đúng
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đăng ký thành công'),
          content: const Text('Tài khoản của bạn đã được tạo thành công.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                
                // Điều hướng đến trang đăng nhập
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login', // Đường dẫn đến trang đăng nhập
                  (route) => false, // Xóa tất cả các màn hình khỏi stack
                );
                
                // Hoặc sử dụng cách khác để chuyển đến trang login
                // Navigator.of(context).pushAndRemoveUntil(
                //   MaterialPageRoute(builder: (context) => const LoginScreen()),
                //   (route) => false,
                // );
              },
              child: const Text('Đăng nhập ngay'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Xác thực OTP'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Icon(
                Icons.mark_email_read,
                color: AppColors.primary,
                size: 80,
              ),
              const SizedBox(height: 20),
              const Text(
                'Xác thực Email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Chúng tôi đã gửi mã OTP đến email\n${widget.email}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildOtpFields(),
              const SizedBox(height: 10),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 30),
              _buildVerifyButton(),
              const SizedBox(height: 20),
              _buildResendButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
        (index) => SizedBox(
          width: 45,
          child: TextFormField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                _focusNodes[index + 1].requestFocus();
              }
              // Tự động xác thực nếu đã nhập đủ 6 chữ số
              if (index == 5 && value.isNotEmpty) {
                _verifyOtp();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isVerifying ? null : _verifyOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isVerifying
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Xác thực',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildResendButton() {
    return TextButton(
      onPressed: _resendTime == 0 && !_isSendingOtp
          ? _generateAndSendOtp
          : null,
      child: _isSendingOtp
          ? const CircularProgressIndicator(strokeWidth: 2)
          : Text(
              _resendTime > 0
                  ? 'Gửi lại OTP sau $_resendTime giây'
                  : 'Gửi lại OTP',
              style: TextStyle(
                color: _resendTime > 0 ? Colors.grey : AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
    );
  }
}