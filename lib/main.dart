import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/auth_gate.dart';
import 'theme/brand_colors.dart';

void main() {
  runApp(const VehiSOSApp());
}

class VehiSOSApp extends StatelessWidget {
  const VehiSOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        height: 1.02,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 46,
        fontWeight: FontWeight.w800,
        height: 1.08,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 36,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: GoogleFonts.workSans(
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: GoogleFonts.workSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      labelLarge: GoogleFonts.workSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: GoogleFonts.workSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VehiSOS',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: BrandColors.primary,
          onPrimary: Colors.white,
          secondary: BrandColors.secondary,
          onSecondary: Colors.white,
          error: const Color(0xFFBA1A1A),
          onError: Colors.white,
          surface: const Color(0xFFF8F1EE),
          onSurface: BrandColors.onSurface,
          surfaceContainerHighest: const Color(0xFFF3D8D2),
          surfaceContainerHigh: const Color(0xFFF0E4E0),
          surfaceContainer: const Color(0xFFEED7D1),
          surfaceContainerLow: const Color(0xFFF4EAE7),
          surfaceContainerLowest: const Color(0xFFFDF8F6),
        ),
        textTheme: textTheme,
      ),
      home: const AuthGate(),
    );
  }
}
