import 'package:flutter/material.dart';

class BrandColors {
  static const Color primary = Color(0xFFBB000E);
  static const Color primaryContainer = Color(0xFFE22623);
  static const Color secondary = Color(0xFF9A4600);
  static const Color onSurface = Color(0xFF291714);
  static const Color outlineVariant = Color(0xFFE8BDB5);

  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryContainer],
  );

  static const LinearGradient ctaGradientPressed = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8F000B), Color(0xFFBB1515)],
  );
}
