// ignore_for_file: prefer_const_constructors

import 'package:bionexus_admin/subpages/fittedVideo.dart';
import 'package:bionexus_admin/subpages/mainScreen.dart';
import 'package:bionexus_admin/subpages/splash.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FittedVideo(),
        Opacity(
          opacity: .7,
          child: Container(
            color: DARK_GREEN,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
        ),
        Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                SizedBox(
                  height: 60,
                ),
                SizedBox(
                    width: 300, child: Image.asset("assets/bionexuslogo.png")),
              ],
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 70,
              child: Text(
                "Ready to Streamline your Medical Management Process?",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontFamily: "montserrat",
                    fontWeight: FontWeight.bold),
              ),
            ),
            Column(
              children: [
                OutlinedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                          PROCESS_CYAN.withOpacity(0.2)),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4))),
                      side: MaterialStateProperty.all(BorderSide(
                          color: Colors.white,
                          width: 2,
                          style: BorderStyle.solid)),
                      padding: MaterialStatePropertyAll(EdgeInsets.symmetric(
                          horizontal:
                              (MediaQuery.of(context).size.width * .5) - 115,
                          vertical: 15)),
                    ),
                    onPressed: () async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setBool("opened", true);
                      print(await prefs.getBool("opened"));
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => MainScreen()));
                    },
                    child: Text("GET STARTED",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            letterSpacing: 2,
                            fontFamily: "montserrat",
                            fontWeight: FontWeight.bold))),
                SizedBox(
                  height: 60,
                )
              ],
            )
          ],
        ))
      ],
    );
  }
}
