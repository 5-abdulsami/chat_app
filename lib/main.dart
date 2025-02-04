import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linkup/utils/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:linkup/view/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // for only portrait full screen view
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LinkUp - Chat App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: blueColor),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
            centerTitle: true,
            elevation: 1,
            titleTextStyle:
                GoogleFonts.poppins(color: blackColor, fontSize: 19)),
      ),
      home: const SplashScreen(),
    );
  }
}
