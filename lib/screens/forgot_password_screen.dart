import 'package:flora_manager/screens/otp_verification_for_password_screen.dart';
import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../services/auth_service.dart';
import '../services/mail_service.dart';
import '../utils/otp_generator.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Kiểm tra email tồn tại
  Future<void> _checkEmailExists(String email) async {
    if (email.isEmpty) return;
    
    try {
      final exists = await AuthService.checkEmailExists(email);
      if (!exists) {
        setState(() {
          _emailError = 'Email này chưa được đăng ký';
        });
      } else {
        setState(() {
          _emailError = null;
        });
      }
    } catch (e) {
      debugPrint('Error checking email: $e');
      _showErrorMessage('Không thể kiểm tra email. Vui lòng thử lại.');
    }
  }

  // Xử lý gửi OTP
  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Kiểm tra email trước khi gửi OTP
      await _checkEmailExists(_emailController.text);
      
      if (_emailError != null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Tạo OTP
      final otp = OtpGenerator.generateOtp();
      debugPrint('Generated OTP: $otp');

      // Gửi email chứa OTP
      final mailService = MailService();
      final result = await mailService.sendOtpEmail(
        _emailController.text,
        MailType.forgetPasswordOtp,
        otp,
      );
      
      if (result) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationForPasswordScreen(
                email: _emailController.text,
                generatedOtp: otp,
              ),
            ),
          );
        }
      } else {
        _showErrorMessage('Không thể gửi mã OTP. Vui lòng thử lại.');
      }
    } catch (e) {
      _showErrorMessage('Đã xảy ra lỗi. Vui lòng thử lại sau.');
      debugPrint('Error sending OTP: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.lock_reset,
                  color: AppColors.primary,
                  size: 80,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Đặt lại mật khẩu',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Nhập email đã đăng ký để nhận mã xác thực',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 30),
                _buildEmailField(),
                const SizedBox(height: 30),
                _buildSendOtpButton(),
                const SizedBox(height: 20),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      onChanged: (val) {
        if (_emailError != null) {
          setState(() {
            _emailError = null;
          });
        }
      },
      onFieldSubmitted: (val) => _checkEmailExists(val),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Email không hợp lệ';
        }
        return null;
      },
      style: const TextStyle(color: AppColors.text),
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: const TextStyle(color: AppColors.textLight),
        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textLight),
        errorText: _emailError,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildSendOtpButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSendOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Nhận mã xác thực',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Đã nhớ mật khẩu? ',
          style: TextStyle(color: AppColors.textLight),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Đăng nhập',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}