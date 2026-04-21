import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/vehisos_auth_api.dart';
import '../widgets/common_widgets.dart';
import 'client_home_screen.dart';
import 'welcome_screen.dart';

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
      if (!validUser.isClientProfile) {
        await _sessionStore.clear();
        if (!mounted) {
          return;
        }
        setState(() {
          _targetScreen = const WelcomeScreen();
          _loading = false;
        });
        return;
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _targetScreen = ClientHomeScreen(
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
            const RoadsideBackdrop(),
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
                    'Verificando sesion de cliente',
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
