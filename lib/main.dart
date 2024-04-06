// ignore_for_file: prefer_const_constructors

import 'package:bionexus_admin/firebase_options.dart';
import 'package:bionexus_admin/subpages/main_screen.dart';
import 'package:bionexus_admin/subpages/onboarding_screen.dart';
import 'package:bionexus_admin/subpages/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bionexus_admin/hex_color.dart';
//imports




Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // debugPaintSizeEnabled = true;

  final prefs = await SharedPreferences.getInstance();
  final showOnboard = prefs.getBool("opened") ?? false;

  runApp(MaterialApp(
    home: Splash(showOnboard: showOnboard),
  ));
}

class MyApp extends StatefulWidget {
  final bool showOnboard;
  const MyApp({super.key, required this.showOnboard});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(FirebaseAuth.instance.currentUser);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: "montserrat",
        primaryColor: PROCESS_CYAN,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.all(24),
            ),
            backgroundColor: MaterialStateProperty.all<Color>(AERO),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            textStyle: MaterialStatePropertyAll(TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            letterSpacing: 2,
                            fontFamily: "montserrat",
                            fontWeight: FontWeight.bold,
                            ))
          ),
        ),
      ),
      title: 'BioNexus',
      home: Scaffold(
        body: widget.showOnboard ? MainScreen() : OnboardingScreen(),
      ),
    );
  }
}
