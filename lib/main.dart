import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/vehisos_auth_api.dart';

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

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final VehiSOSAuthApi _api = VehiSOSAuthApi();
  final VehiSosSessionStore _sessionStore = VehiSosSessionStore();
  bool _loading = true;
  Widget _targetScreen = const SizedBox.shrink();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final token = await _sessionStore.readToken();
      if (token == null || token.isEmpty) {
        if (!mounted) {
          return;
        }
        setState(() {
          _targetScreen = const WelcomeScreen();
          _loading = false;
        });
        return;
      }

      final cachedUser = await _sessionStore.readUser();
      final validUser = await _api.fetchCurrentUser(token);
      if (!mounted) {
        return;
      }
      setState(() {
        _targetScreen = HomeScreen(
          user: validUser,
          sessionStore: _sessionStore,
          initialToken: token,
          fallbackUser: cachedUser,
        );
        _loading = false;
      });
    } catch (_) {
      await _sessionStore.clear();
      if (!mounted) {
        return;
      }
      setState(() {
        _targetScreen = const WelcomeScreen();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _RoadsideBackdrop(),
            Container(
              color: const Color(0xB0291714),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BrandMark(isLight: true),
                  const SizedBox(height: 20),
                  Text(
                    'Checking session',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return _targetScreen;
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.user,
    required this.sessionStore,
    required this.initialToken,
    this.fallbackUser,
  });

  final VehiSosUser user;
  final VehiSosUser? fallbackUser;
  final VehiSosSessionStore sessionStore;
  final String initialToken;

  Future<void> _signOut(BuildContext context) async {
    await sessionStore.clear();
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const AuthGate()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayUser = fallbackUser ?? user;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _RoadsideBackdrop(),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x9A291714), Color(0xD6291714)],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const BrandMark(isLight: true),
                      const Spacer(),
                      _CircularIconButton(
                        icon: Icons.logout_rounded,
                        onTap: () => _signOut(context),
                      ),
                    ],
                  ),
                  const Spacer(flex: 2),
                  Text(
                    'Welcome, ${displayUser.displayName}',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 54 * 0.72,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayUser.correo,
                    style: GoogleFonts.workSans(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: const Color(0x66F3EAE7),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14291714),
                              offset: Offset(0, 12),
                              blurRadius: 32,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Session active',
                              style: GoogleFonts.plusJakartaSans(
                                color: BrandColors.primary,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'The app validated your JWT and redirected here automatically.',
                              style: GoogleFonts.workSans(
                                color: BrandColors.onSurface,
                                fontSize: 15,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Documento: ${displayUser.documentoIdentidad}',
                              style: GoogleFonts.workSans(
                                color: BrandColors.onSurface.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Usuario ID: ${displayUser.id}',
                              style: GoogleFonts.workSans(
                                color: BrandColors.onSurface.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  GradientActionButton(
                    label: 'Sign Out',
                    icon: Icons.logout_rounded,
                    onTap: () => _signOut(context),
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

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _RoadsideBackdrop(),
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
                              'The best assistance for your vehicle',
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
                                      label: 'Sign In',
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
                                      label: 'Create Account',
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
                                        _BottomMetaItem(
                                          icon: Icons.language_rounded,
                                          label: 'English',
                                        ),
                                        const Spacer(),
                                        _BottomMetaItem(label: 'Help'),
                                        const SizedBox(width: 24),
                                        _BottomMetaItem(label: 'Privacy'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            '© 2024 VEHISOS GLOBAL SENTINEL',
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
          builder: (_) => HomeScreen(
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
                  _CircularIconButton(
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
                      'Register',
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
                      'Create your new account',
                      style: GoogleFonts.workSans(
                        fontSize: 16 * 1.1,
                        color: BrandColors.onSurface.withValues(alpha: 0.86),
                      ),
                    ),
                  ),
                  const SizedBox(height: 34),
                  _FieldLabel(text: 'Full Name'),
                  const SizedBox(height: 10),
                  EditorialTextField(
                    controller: _fullNameController,
                    hintText: 'John',
                  ),
                  const SizedBox(height: 22),
                  _FieldLabel(text: 'Last Name'),
                  const SizedBox(height: 10),
                  EditorialTextField(
                    controller: _lastNameController,
                    hintText: 'Doe',
                  ),
                  const SizedBox(height: 24),
                  _FieldLabel(text: 'Email'),
                  const SizedBox(height: 10),
                  EditorialTextField(
                    controller: _emailController,
                    hintText: 'email@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  _FieldLabel(text: 'Phone'),
                  const SizedBox(height: 10),
                  EditorialTextField(
                    controller: _phoneController,
                    hintText: '+51 999 999 999',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  _FieldLabel(text: 'Document ID'),
                  const SizedBox(height: 10),
                  EditorialTextField(
                    controller: _documentController,
                    hintText: '12345678',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  _FieldLabel(text: 'Password'),
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
                        label: _loading ? 'Registering...' : 'Register',
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
                          'OR SIGN UP WITH',
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
                      _SocialChip(label: 'G'),
                      SizedBox(width: 14),
                      _SocialChip(label: 'X'),
                      SizedBox(width: 14),
                      _SocialChip(label: 'iOS'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Wrap(
                      children: [
                        Text(
                          'Already have an account? ',
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
                            'Sign In',
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

      await _sessionStore.saveSession(session);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => HomeScreen(
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
                                'Guardian Sentinel',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 36 * 0.48,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Roadside safety, redefined.',
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
                            'Welcome Back',
                            style: GoogleFonts.plusJakartaSans(
                              color: BrandColors.primary,
                              fontSize: 35 * 0.44,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sign in to access your digital roadside companion.',
                            style: GoogleFonts.workSans(
                              color: BrandColors.onSurface.withValues(alpha: 0.9),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _FieldLabel(text: 'Email', isCompact: true),
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
                                child: _FieldLabel(text: 'Password', isCompact: true),
                              ),
                              Text(
                                'Forgot?',
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
                                label: _loading ? 'Signing in...' : 'Login',
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
                                  'OR CONTINUE WITH',
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
                              _SocialChip(label: 'G', compact: true),
                              SizedBox(width: 10),
                              _SocialChip(label: 'iOS', compact: true),
                              SizedBox(width: 10),
                              _SocialChip(label: 'X', compact: true),
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

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.isLight = false});

  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final iconColor = isLight ? Colors.white : Colors.white;
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: isLight ? Colors.white.withValues(alpha: 0.12) : BrandColors.primary,
      ),
      child: Center(
        child: Icon(
          Icons.wifi_tethering_rounded,
          color: iconColor,
          size: 34,
        ),
      ),
    );
  }
}

class _RoadsideBackdrop extends StatelessWidget {
  const _RoadsideBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF584229),
                Color(0xFFB47626),
                Color(0xFF5A2A1D),
              ],
            ),
          ),
        ),
        Positioned(
          left: -70,
          bottom: 250,
          child: Container(
            width: 300,
            height: 300,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0xFFE5B65A), Color(0x00E5B65A)],
              ),
            ),
          ),
        ),
        Positioned(
          right: -24,
          bottom: 50,
          child: Icon(
            Icons.local_shipping_rounded,
            size: 300,
            color: Colors.black.withValues(alpha: 0.25),
          ),
        ),
        Positioned(
          left: -30,
          bottom: 20,
          child: Icon(
            Icons.directions_car_filled_rounded,
            size: 280,
            color: Colors.black.withValues(alpha: 0.28),
          ),
        ),
      ],
    );
  }
}

class GradientActionButton extends StatefulWidget {
  const GradientActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.compact = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool compact;

  @override
  State<GradientActionButton> createState() => _GradientActionButtonState();
}

class _GradientActionButtonState extends State<GradientActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = widget.compact ? 52.0 : 82.0;
    final textSize = widget.compact ? 26 * 0.62 : 40 * 0.58;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        height: buttonHeight,
        decoration: BoxDecoration(
          gradient: _pressed ? BrandColors.ctaGradientPressed : BrandColors.ctaGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14291714),
              offset: Offset(0, 12),
              blurRadius: 32,
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: textSize,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (widget.icon != null) ...[
                const SizedBox(width: 8),
                Icon(widget.icon, color: Colors.white, size: widget.compact ? 18 : 26),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class GlassSecondaryButton extends StatelessWidget {
  const GlassSecondaryButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Material(
          color: const Color(0x66EFE2DE),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 82,
              child: Center(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 40 * 0.58,
                    color: Colors.white.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EditorialTextField extends StatefulWidget {
  const EditorialTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.compact = false,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool compact;

  @override
  State<EditorialTextField> createState() => _EditorialTextFieldState();
}

class _EditorialTextFieldState extends State<EditorialTextField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;
    final height = widget.compact ? 42.0 : 68.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFFF1D5D0),
        boxShadow: [
          if (isFocused)
            BoxShadow(
              color: BrandColors.primary.withValues(alpha: 0.20),
              blurRadius: 0,
              spreadRadius: 2,
            ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        focusNode: _focusNode,
        style: GoogleFonts.workSans(
          fontSize: widget.compact ? 13 : 18,
          fontWeight: FontWeight.w500,
          color: BrandColors.onSurface,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: widget.hintText,
          hintStyle: GoogleFonts.workSans(
            color: const Color(0xC7D7A7A0),
            fontSize: widget.compact ? 13 : 18,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: widget.compact ? 8 : 16),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, this.isCompact = false});

  final String text;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.workSans(
        color: BrandColors.onSurface.withValues(alpha: 0.88),
        fontSize: isCompact ? 10 : 34 * 0.45,
        letterSpacing: isCompact ? 1.8 : 0,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _CircularIconButton extends StatelessWidget {
  const _CircularIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.5),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 68,
          height: 68,
          child: Icon(icon, color: BrandColors.onSurface, size: 34 * 0.7),
        ),
      ),
    );
  }
}

class _SocialChip extends StatelessWidget {
  const _SocialChip({required this.label, this.compact = false});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 38.0 : 74.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(compact ? 10 : 18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C291714),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: compact ? 11 : 20,
          color: BrandColors.onSurface,
        ),
      ),
    );
  }
}

class _BottomMetaItem extends StatelessWidget {
  const _BottomMetaItem({this.icon, required this.label});

  final IconData? icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: Colors.white.withValues(alpha: 0.72), size: 19),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: GoogleFonts.workSans(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 40 * 0.46,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
