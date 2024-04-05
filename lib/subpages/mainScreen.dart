import 'package:bionexus_admin/subpages/fittedVideo.dart';
import 'package:bionexus_admin/subpages/splash.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return FirebaseAuth.instance.currentUser != null
        ? HomeScreen()
        : Stack( // --------------------------------------------------------------------------------------------------- loginScreen
            children: [
              FittedVideo(),
              Opacity(
                opacity: .9,
                child: Container(
                  color: DARK_GREEN,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 200,
                      ),
                      SizedBox(
                          width: 420,
                          child: Image.asset("assets/bionexuslogo.png")),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30))),
                    height: 400,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      child: SignInScreen(providers: [
                        EmailAuthProvider(),
                      ], actions: [
                        AuthStateChangeAction<UserCreated>((context, state) {
                          print("Account created");
                          print(FirebaseAuth.instance.currentUser);
                          setState(() {});
                        }),
                        AuthStateChangeAction<SignedIn>((context, state) {
                          print(FirebaseAuth.instance.currentUser);
                          setState(() {});
                        })
                      ]),
                    ),
                  ),
                ],
              ),
            ],
          );
  }
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
