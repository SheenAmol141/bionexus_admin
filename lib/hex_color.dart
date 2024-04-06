// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

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
final Color EMERALD = HexColor.fromHex("#00BF63");
final Color AERO = HexColor.fromHex("#0CC0DF");
final Color PRUSSIAN_BLUE = HexColor.fromHex("#13293D");

