import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/vehisos_auth_api.dart';
import '../theme/brand_colors.dart';
import '../widgets/common_widgets.dart';
import 'client_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _api = VehiSOSAuthApi();
  final _sessionStore = VehiSosSessionStore();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  Future<void> _submit() async {
    final identifier = _emailController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa correo o documento y contraseña.')),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final session = await _api.login(
        identificador: identifier,
        password: password,
      );

      if (!session.user.isClientProfile) {
        await _sessionStore.clear();
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Esta aplicacion movil es exclusiva para clientes.')),
        );
        return;
      }

      await _sessionStore.saveSession(session);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => ClientHomeScreen(
            user: session.user,
            sessionStore: _sessionStore,
            initialToken: session.token,
          ),
        ),
        (route) => false,
      );
    } on VehiSosApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo iniciar sesión.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF0F4),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14291714),
                  offset: Offset(0, 12),
                  blurRadius: 32,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 190,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6A070A), Color(0xFFBB000E), Color(0xFFE22623)],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 16,
                          top: 16,
                          child: Text(
                            'VehiSOS',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.italic,
                              fontSize: 22,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 14,
                          top: 14,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.help_outline_rounded, size: 16, color: Colors.white),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          bottom: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Guardian Cliente',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 36 * 0.48,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Asistencia en carretera para ti.',
                                style: GoogleFonts.workSans(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F6F6),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenido de nuevo',
                            style: GoogleFonts.plusJakartaSans(
                              color: BrandColors.primary,
                              fontSize: 35 * 0.44,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Inicia sesion para gestionar tu asistencia vehicular.',
                            style: GoogleFonts.workSans(
                              color: BrandColors.onSurface.withValues(alpha: 0.9),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const FieldLabel(text: 'Correo o Documento', isCompact: true),
                          const SizedBox(height: 6),
                          EditorialTextField(
                            controller: _emailController,
                            hintText: 'name@example.com or ID',
                            compact: true,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Expanded(
                                child: FieldLabel(text: 'Password', isCompact: true),
                              ),
                              Text(
                                'Olvide mi clave',
                                style: GoogleFonts.workSans(
                                  color: BrandColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          EditorialTextField(
                            controller: _passwordController,
                            hintText: '••••••••',
                            obscureText: true,
                            compact: true,
                          ),
                          const SizedBox(height: 14),
                          IgnorePointer(
                            ignoring: _loading,
                            child: Opacity(
                              opacity: _loading ? 0.72 : 1,
                              child: GradientActionButton(
                                label: _loading ? 'Ingresando...' : 'Iniciar Sesion',
                                icon: Icons.east_rounded,
                                compact: true,
                                onTap: _submit,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1.5,
                                  color: BrandColors.outlineVariant.withValues(alpha: 0.4),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  'O CONTINUA CON',
                                  style: GoogleFonts.workSans(
                                    fontSize: 9,
                                    letterSpacing: 0.6,
                                    fontWeight: FontWeight.w700,
                                    color: BrandColors.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1.5,
                                  color: BrandColors.outlineVariant.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SocialChip(label: 'G', compact: true),
                              SizedBox(width: 10),
                              SocialChip(label: 'iOS', compact: true),
                              SizedBox(width: 10),
                              SocialChip(label: 'X', compact: true),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
