// ignore_for_file: prefer_const_constructors

import 'package:bionexus_admin/subpages/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bionexus_admin/hex_color.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
                      backgroundColor:
                          MaterialStatePropertyAll(AERO.withOpacity(0.3)),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4))),
                      side: MaterialStateProperty.all(BorderSide(
                          color: Colors.white,
                          width: 2,
                          style: BorderStyle.solid)),
                      padding: MaterialStatePropertyAll(EdgeInsets.symmetric(
                          horizontal:
                              (MediaQuery.of(context).size.width * .5) - 115,
                          vertical: 20)),
                    ),
                    onPressed: () async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setBool("opened", true);
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
