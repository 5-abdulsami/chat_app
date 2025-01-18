import 'package:flutter/material.dart';
import 'package:linkup/main.dart';
import 'package:linkup/utils/colors.dart';

import '../view/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    mediaQuery = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("LinkUp"),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
              duration: const Duration(seconds: 1),
              top: mediaQuery.height * 0.15,
              // if _isAnimate is true then move to left else it disappears (comes from right)
              right: _isAnimate
                  ? mediaQuery.width * 0.25
                  : -mediaQuery.width * 0.5,
              width: mediaQuery.width * 0.5,
              child: Image.asset('assets/images/icon.png')),
          Positioned(
              bottom: mediaQuery.height * 0.15,
              left: mediaQuery.width * 0.5,
              width: mediaQuery.width * 0.9,
              height: mediaQuery.height * 0.07,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: greenColor, shape: const StadiumBorder()),
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()));
                },
                icon: Image.asset('assets/images/google.png'),
                label: const Text("Login with Google"),
              )),
        ],
      ),
    );
  }
}
