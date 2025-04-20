import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final colors = {
    'appName': Colors.white,
    'title': const Color(0xFF8ba961),
    'text': Colors.white,
    'background': Colors.white,
    'button': const Color(0xFF8ba961),
  };

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 10), () {
      checkLoginAndNavigate();
    });
  }

  void checkLoginAndNavigate() async {
    // bool isLoggedIn = false;
    
      navigateToHome();
    // if (isLoggedIn) {
    //   navigateToHome();
    // } else {
    //   navigateToLogin();
    // }
  }

  void navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors['background'],
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: colors['background'],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.asset(
                    'assets/images/splash.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Flora Mart',  
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                      color: colors['appName'],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Nền tảng quản lý hệ thống mua bán cây trực tuyến', 
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'sans-serif',
                      color: colors['text'],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Nhóm phát triển:\n- Nguyễn Hà Quỳnh Giao\n- Hoàng Công Mạnh',
                    style: TextStyle(
                      fontSize: 16,
                      color: colors['text'],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}