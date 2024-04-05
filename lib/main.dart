// ignore_for_file: prefer_const_constructors

import 'package:bionexus_admin/firebase_options.dart';
import 'package:bionexus_admin/subpages/mainScreen.dart';
import 'package:bionexus_admin/subpages/onboardingScreen.dart';
import 'package:bionexus_admin/subpages/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final showOnboard;
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
      theme: ThemeData(primaryColor: PROCESS_CYAN),
      title: 'BioNexus',
      home: Scaffold(
        body: widget.showOnboard
            ? MainScreen()
            : OnboardingScreen(),
      ),
    );
  }
}
