import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linkup/api/api.dart';
import 'package:linkup/auth/auth_service.dart';
import 'package:linkup/main.dart';
import 'package:linkup/utils/colors.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isAnimate = false;
  @override
  void initState() {
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
              left: mediaQuery.width * 0.065,
              width: mediaQuery.width * 0.85,
              height: mediaQuery.height * 0.07,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: greenColor, shape: const StadiumBorder()),
                onPressed: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(
                        color: whiteColor,
                      ),
                    ),
                  );

                  final user = await _authService.signInWithGoogle();
                  Navigator.pop(context); // Close the progress dialog

                  if (user != null) {
                    log('Signed in as: ${user.displayName}');
                    if (await API.userExists()) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()));
                    } else {
                      await API.createUser().then((value) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ));
                      });
                    }
                  } else {
                    log('-----Google Sign-In failed');
                  }
                },
                icon: Image.asset(
                  'assets/images/google.png',
                  height: mediaQuery.height * 0.05,
                ),
                label: Text(
                  "Login with Google",
                  style: GoogleFonts.poppins(
                      color: whiteColor, fontSize: mediaQuery.width * 0.04),
                ),
              )),
        ],
      ),
    );
  }
}
