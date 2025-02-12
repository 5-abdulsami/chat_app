import 'package:flutter/material.dart';
import 'package:linkup/auth/auth_service.dart';
import 'package:linkup/view/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      // exit full screen
      if (_authService.auth.currentUser != null) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/images/icon.png",
          width: mediaQuery.width * 0.4,
        ),
      ),
    );
  }
}
