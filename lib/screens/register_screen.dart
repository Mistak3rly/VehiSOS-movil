import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/vehisos_auth_api.dart';
import '../theme/brand_colors.dart';
import '../widgets/common_widgets.dart';
import 'client_home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _api = VehiSOSAuthApi();
  final _sessionStore = VehiSosSessionStore();
  final _fullNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _documentController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  Future<void> _submit() async {
    final fullName = _fullNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final document = _documentController.text.trim();
    final password = _passwordController.text;

    if (fullName.isEmpty || lastName.isEmpty || email.isEmpty || document.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa nombre, apellidos, correo, documento y contraseña.')),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña debe tener al menos 8 caracteres.')),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await _api.register(
        nombre: fullName,
        apellidos: lastName,
        correo: email,
        documentoIdentidad: document,
        password: password,
        telefono: phone.isEmpty ? null : phone,
      );

      final session = await _api.login(
        identificador: email,
        password: password,
      );

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
        const SnackBar(content: Text('No se pudo completar el registro.')),
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
    _fullNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _documentController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7EFED),
      body: Stack(
        children: [
          Positioned.fill(
            child: Row(
              children: const [
                Expanded(child: ColoredBox(color: Color(0xFFF7EFED))),
                Expanded(child: ColoredBox(color: Color(0xFFF1E4E2))),
              ],
            ),
          ),
          Positioned(
            right: -80,
            bottom: 220,
            child: Icon(
              Icons.directions_car_filled_rounded,
              size: 320,
              color: Colors.black.withValues(alpha: 0.05),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(26, 14, 26, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircularIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 14),
                  const Center(child: BrandMark()),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'VehiSOS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 46 * 0.6,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: BrandColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Registro Cliente',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 62 * 0.65,
                        fontWeight: FontWeight.w800,
                        color: BrandColors.onSurface,
                        height: 1.05,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Crea tu cuenta para solicitar asistencia vehicular',
                      style: GoogleFonts.workSans(
                        fontSize: 16 * 1.1,
                        color: BrandColors.onSurface.withValues(alpha: 0.86),
                      ),
                    ),
                  ),
                  const SizedBox(height: 34),
                  const FieldLabel(text: 'Nombres'),
                  const SizedBox(height: 10),
                  EditorialTextField(
                    controller: _fullNameController,
                    hintText: 'John',
                  ),
                  const SizedBox(height: 22),
                  const FieldLabel(text: 'Apellidos'),
                  const SizedBox(height: 10),
                  EditorialTextField(
                    controller: _lastNameController,
                    hintText: 'Doe',
                  ),
                  const SizedBox(height: 24),
                  const FieldLabel(text: 'Correo'),
                  const SizedBox(height: 10),
                  EditorialTextField(
                    controller: _emailController,
                    hintText: 'email@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  const FieldLabel(text: 'Telefono'),
                  const SizedBox(height: 10),
                  EditorialTextField(
                    controller: _phoneController,
                    hintText: '+51 999 999 999',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  const FieldLabel(text: 'Documento'),
                  const SizedBox(height: 10),
                  EditorialTextField(
                    controller: _documentController,
                    hintText: '12345678',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  const FieldLabel(text: 'Contrasena'),
                  const SizedBox(height: 10),
                  EditorialTextField(
                    controller: _passwordController,
                    hintText: '••••••••',
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),
                  IgnorePointer(
                    ignoring: _loading,
                    child: Opacity(
                      opacity: _loading ? 0.72 : 1,
                      child: GradientActionButton(
                        label: _loading ? 'Registrando...' : 'Crear Cuenta',
                        onTap: _submit,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 2,
                          color: BrandColors.outlineVariant.withValues(alpha: 0.4),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'O REGISTRATE CON',
                          style: GoogleFonts.workSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: BrandColors.onSurface.withValues(alpha: 0.4),
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: BrandColors.outlineVariant.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SocialChip(label: 'G'),
                      SizedBox(width: 14),
                      SocialChip(label: 'X'),
                      SizedBox(width: 14),
                      SocialChip(label: 'iOS'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Wrap(
                      children: [
                        Text(
                          'Ya tienes una cuenta? ',
                          style: GoogleFonts.workSans(
                            fontSize: 17,
                            color: BrandColors.onSurface.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Iniciar Sesion',
                            style: GoogleFonts.workSans(
                              fontSize: 17,
                              color: BrandColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
