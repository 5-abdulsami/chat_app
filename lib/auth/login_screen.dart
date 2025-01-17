import 'package:flutter/material.dart';
import 'package:linkup/main.dart';
import 'package:linkup/utils/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    mediaQuery = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("LinkUp"),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Positioned(
              top: mediaQuery.height * 0.15,
              left: mediaQuery.width * 0.25,
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
                onPressed: () {},
                icon: Image.asset('assets/images/google.png'),
                label: Text("Signin with Google"),
              )),
        ],
      ),
    );
  }
}
