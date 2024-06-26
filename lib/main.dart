// ignore_for_file: prefer_const_constructors

import 'package:bionexus_admin/firebase_options.dart';
import 'package:bionexus_admin/subpages/main_screen.dart';
import 'package:bionexus_admin/subpages/onboarding_screen.dart';
import 'package:bionexus_admin/subpages/splash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
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
    theme: ThemeData(
      appBarTheme: AppBarTheme(
        centerTitle: true,
        titleTextStyle: GoogleFonts.montserrat(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      colorScheme: ThemeData().colorScheme.copyWith(primary: AERO),
      backgroundColor: EMERALD,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          padding: MaterialStatePropertyAll(
            EdgeInsets.all(20),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(AERO),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          textStyle: MaterialStatePropertyAll(GoogleFonts.montserrat(
              fontWeight: FontWeight.w600, fontSize: 15, letterSpacing: 1)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
      ),
      fontFamily: "montserrat",
      primaryColor: PROCESS_CYAN,
      radioTheme: RadioThemeData(
        fillColor: MaterialStatePropertyAll(AERO),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AERO, width: 3.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AERO;
        } else {
          return Colors.transparent;
        }
      })),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
            side: MaterialStatePropertyAll(
              BorderSide(
                color: Colors.transparent,
              ),
            ),
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
            ))),
      ),
    ),
    home: Splash(showOnboard: showOnboard),
  ));
}

final firebase = FirebaseFirestore.instance;

class MyApp extends StatefulWidget {
  final bool showOnboard;
  const MyApp({super.key, required this.showOnboard});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          centerTitle: true,
          titleTextStyle: GoogleFonts.montserrat(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        colorScheme: ThemeData().colorScheme.copyWith(primary: AERO),
        backgroundColor: EMERALD,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            padding: MaterialStatePropertyAll(
              EdgeInsets.all(20),
            ),
            backgroundColor: MaterialStateProperty.all<Color>(AERO),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            textStyle: MaterialStatePropertyAll(GoogleFonts.montserrat(
                fontWeight: FontWeight.w600, fontSize: 15, letterSpacing: 1)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
        ),
        fontFamily: "montserrat",
        primaryColor: PROCESS_CYAN,
        radioTheme: RadioThemeData(
          fillColor: MaterialStatePropertyAll(AERO),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AERO, width: 3.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
            fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AERO;
          } else {
            return Colors.transparent;
          }
        })),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
              side: MaterialStatePropertyAll(
                BorderSide(
                  color: Colors.transparent,
                ),
              ),
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
              ))),
        ),
      ),
      title: 'BioNexus',
      home: Scaffold(
        body: widget.showOnboard ? MainScreen() : OnboardingScreen(),
      ),
    );
  }
}
