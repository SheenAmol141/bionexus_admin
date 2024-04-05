
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../main.dart';

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

//COLORS
final Color SPACE_CADET = HexColor.fromHex("21295C");
final Color PROCESS_CYAN = HexColor.fromHex("08ADDB");
final Color DARK_GREEN = HexColor.fromHex("00322F");




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

    Future.delayed(Duration(seconds: 1), () {
      print(widget.showOnboard);
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => MyApp(showOnboard: widget.showOnboard)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: DARK_GREEN,
      body:  Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Opacity(
            opacity: 0,
            child: Center(
              child: Column(
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width * .08, child: Image.asset("assets/datagoralogo.png"),),
                Text("datagora", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                SizedBox(height: 100,)
                ],
              ),
            ),
          ),
          Center(
            child: SizedBox(width: MediaQuery.of(context).size.width * .6, child: Image.asset("assets/bionexuslogo.png"),),
          ),
          Opacity(
            opacity: 0.5,
            child: Center(
              child: Column(
                children: [
                  SizedBox(width: 40, child: Image.asset("assets/datagoralogo.png"),),
                Text("datagora", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                SizedBox(height: 100,)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
