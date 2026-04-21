import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';

import '../services/vehisos_auth_api.dart';
import '../services/workshop_assistant_service.dart';
import '../theme/brand_colors.dart';
import '../widgets/common_widgets.dart';
import 'auth_gate.dart';
import 'client_profile_screen.dart';

part 'client_home_views/shared_top_bar.dart';
part 'client_home_views/bottom_nav.dart';
part 'client_home_views/sos_dashboard_tab.dart';
part 'client_home_views/sos_report_tab.dart';
part 'client_home_views/tracking_status_tab.dart';
part 'client_home_views/profile_tab.dart';
part 'client_home_views/garage_tab.dart';
part 'client_home_views/history_tab.dart';
part 'client_home_views/payments_tab.dart';
part 'client_home_views/notifications_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({
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

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _currentIndex = 0;
  bool _showSosReport = false;

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ClientNotificationsScreen(),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await widget.sessionStore.clear();
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const AuthGate()),
      (route) => false,
    );
  }

  void _openProfileEditor(BuildContext context, VehiSosUser user) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ClientProfileScreen(
          user: user,
          sessionStore: widget.sessionStore,
          initialToken: widget.initialToken,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayUser = widget.fallbackUser ?? widget.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3F2),
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _showSosReport
                    ? _SosReportTab(
                        onBack: () => setState(() => _showSosReport = false),
                        onOpenNotifications: _openNotifications,
                      )
                    : _SosDashboardTab(
                        onOpenReport: () => setState(() => _showSosReport = true),
                        onOpenStatus: () => setState(() => _currentIndex = 1),
                        onOpenNotifications: _openNotifications,
                      ),
                _TrackingStatusTab(
                  initialToken: widget.initialToken,
                  onOpenNotifications: _openNotifications,
                ),
                _ProfileTab(
                  user: displayUser,
                  onEditProfile: () => _openProfileEditor(context, displayUser),
                  onLogout: () => _signOut(context),
                  onOpenNotifications: _openNotifications,
                ),
                GarageTab(onOpenNotifications: _openNotifications),
                HistoryTab(onOpenNotifications: _openNotifications),
                PaymentsTab(onOpenNotifications: _openNotifications),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _ClientBottomNav(
              currentIndex: _currentIndex,
              onChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  if (index != 0) {
                    _showSosReport = false;
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
