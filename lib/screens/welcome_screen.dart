import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/common_widgets.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const RoadsideBackdrop(),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x80291714),
                  Color(0xB3291714),
                  Color(0xE6291714),
                ],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          const SizedBox(height: 34),
                          const BrandMark(isLight: true),
                          const SizedBox(height: 16),
                          Text(
                            'VehiSOS',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 72,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Text(
                              'La mejor asistencia para tu vehiculo',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.workSans(
                                fontSize: 44 * 0.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.96),
                                height: 1.5,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 34),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(34),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
                                decoration: BoxDecoration(
                                  color: const Color(0x66F2E9E6),
                                  borderRadius: BorderRadius.circular(34),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x14291714),
                                      offset: Offset(0, 12),
                                      blurRadius: 32,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    GradientActionButton(
                                      label: 'Iniciar Sesion',
                                      icon: Icons.login_rounded,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) => const LoginScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    GlassSecondaryButton(
                                      label: 'Crear Cuenta',
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) => const RegisterScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 30),
                                    Row(
                                      children: [
                                        const BottomMetaItem(
                                          icon: Icons.language_rounded,
                                          label: 'Espanol',
                                        ),
                                        const Spacer(),
                                        const BottomMetaItem(label: 'Ayuda'),
                                        const SizedBox(width: 24),
                                        const BottomMetaItem(label: 'Privacidad'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            '© 2026 VEHISOS GLOBAL SENTINEL',
                            style: GoogleFonts.workSans(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.65),
                              letterSpacing: 1.8,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
