import 'dart:async';
import 'package:flutter/material.dart';
import '../app_colors.dart';
import 'login_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 10), _navigateToLogin);
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: AppColors.background,
          ),
          child: Stack(
            children: [
              _buildBackgroundImage(),
              _buildCenteredTexts(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Image.asset(
          'assets/images/splash.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCenteredTexts() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: 20),
        _buildTeamInfo(),
        const Spacer(),
        _buildAppName(),
        const SizedBox(height: 20),
        _buildAppDescription(),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildAppName() {
    return const Text(
      'Flora Mart',
      style: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        fontFamily: 'serif',
        color: AppColors.appName,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildAppDescription() {
    return const Text(
      'Nền tảng quản lý hệ thống mua bán cây trực tuyến',
      style: TextStyle(
        fontSize: 15,
        fontFamily: 'sans-serif',
        color: AppColors.text,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTeamInfo() {
    return const Text(
      'Nhóm phát triển:\n- Nguyễn Hà Quỳnh Giao\n- Hoàng Công Mạnh',
      style: TextStyle(
        fontSize: 16,
        color: AppColors.text,
      ),
      textAlign: TextAlign.center,
    );
  }
}
