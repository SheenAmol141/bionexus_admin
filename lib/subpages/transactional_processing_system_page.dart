import 'package:flutter/material.dart';

class TPS extends StatelessWidget {
  const TPS({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Form(
              child: Column(TextFormField()),
            ),
          ],
        ),
      ),
    );
  }
}
