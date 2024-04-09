import 'package:flutter/material.dart';
import '../main.dart';
import 'package:bionexus_admin/hex_color.dart';

class Splash extends StatefulWidget {
  final showOnboard;
  const Splash({super.key, required this.showOnboard});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => MyApp(showOnboard: widget.showOnboard)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DARK_GREEN,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Opacity(
            opacity: 0,
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .08,
                    child: Image.asset("assets/datagoralogo.png"),
                  ),
                  const Text(
                    "datagora",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 100,
                  )
                ],
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * .6,
              child: Image.asset("assets/bionexuslogo.png"),
            ),
          ),
          Opacity(
            opacity: 0.5,
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 40,
                    child: Image.asset("assets/datagoralogo.png"),
                  ),
                  const Text(
                    "datagora",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 100,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
