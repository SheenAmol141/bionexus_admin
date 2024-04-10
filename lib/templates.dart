import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SectionTitlesTemplate extends StatelessWidget {
  final child;
  const SectionTitlesTemplate(this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(child,
        style:
            GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 25));
  }
}

class CardTemplate extends StatelessWidget {
  final Widget child;
  const CardTemplate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.white,
        elevation: 5,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: child,
        ));
  }
}
