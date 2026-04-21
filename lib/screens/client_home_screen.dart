import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/vehisos_auth_api.dart';
import '../theme/brand_colors.dart';
import 'auth_gate.dart';
import 'client_profile_screen.dart';

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
                      )
                    : _SosDashboardTab(
                        onOpenReport: () => setState(() => _showSosReport = true),
                        onOpenStatus: () => setState(() => _currentIndex = 1),
                      ),
                const _TrackingStatusTab(),
                _ProfileTab(
                  user: displayUser,
                  onEditProfile: () => _openProfileEditor(context, displayUser),
                  onLogout: () => _signOut(context),
                ),
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

class _SosDashboardTab extends StatelessWidget {
  const _SosDashboardTab({required this.onOpenReport, required this.onOpenStatus});

  final VoidCallback onOpenReport;
  final VoidCallback onOpenStatus;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BrandTopBar(),
          const SizedBox(height: 18),
          _HeroGuardianCard(),
          const SizedBox(height: 26),
          Center(
            child: Column(
              children: [
                _PulseSosButton(onTap: onOpenReport),
                const SizedBox(height: 18),
                Text(
                  'HOLD FOR IMMEDIATE ASSISTANCE',
                  style: GoogleFonts.workSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.primary,
                    letterSpacing: 2.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Text(
                'Active Requests',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 39 * 0.66,
                  fontWeight: FontWeight.w800,
                  color: BrandColors.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                'VIEW HISTORY',
                style: GoogleFonts.workSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: BrandColors.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: const Color(0xFFFDF7F5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14291714),
                  blurRadius: 28,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(width: 8, height: 250, color: BrandColors.primary),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuAEThz9192bDiXB-fskMYyhNMxIwmNlxYdUw2aAn7m0g8PYE6KvXtODLoC4Vmtdl3P6iNwne4pbeNYP4UkI95k2Jmb98dRUJkxE_wVDABoHOCAewOGB2Pv6Mlv_32zrgzSueAyuM3-Tzyr0Z7pII-vGkg-mmsMAHJ-_KhKJGpvYDpQLXRl8gkCutyx_qYPtdXS6n6_8JtmQT9lCifzGkeLUkuaT3s0X_3gMhRAzD2MkuwDUdox2hUUz4Xa7w4XOZJUY4E-ECPtiiIk',
                            width: double.infinity,
                            height: 124,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.local_shipping_rounded, size: 15, color: BrandColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              'EN ROUTE • 12 MINS AWAY',
                              style: GoogleFonts.workSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: BrandColors.primary,
                                letterSpacing: 1.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Towing Service #8821',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 30 * 0.6,
                            fontWeight: FontWeight.w800,
                            color: BrandColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Operator Mark is en route in a heavy-duty flatbed. Please remain in your vehicle.',
                          style: GoogleFonts.workSans(
                            fontSize: 14,
                            color: BrandColors.onSurface.withValues(alpha: 0.74),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const _GhostButton(label: 'CALL DRIVER'),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: onOpenStatus,
                              child: const _GhostButton(label: 'TRACK LIVE'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'My Garage',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 40 * 0.66,
              fontWeight: FontWeight.w800,
              color: BrandColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFECE8),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              children: [
                _VehicleTile(icon: Icons.directions_car_filled_rounded, title: 'Tesla Model S', subtitle: 'NY-992-KLD • 98% HEALTH'),
                SizedBox(height: 14),
                _VehicleTile(icon: Icons.electric_car_rounded, title: 'Rivian R1S', subtitle: 'CA-442-EVX • 100% HEALTH'),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Quick Actions',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 40 * 0.66,
              fontWeight: FontWeight.w800,
              color: BrandColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 0.95,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              const _QuickActionCard(icon: Icons.car_repair_rounded, title: 'Roadside\nAssistance'),
              _QuickActionCard(icon: Icons.local_shipping_rounded, title: 'Request Tow\nTruck', active: true, onTap: onOpenReport),
              const _QuickActionCard(icon: Icons.battery_charging_full_rounded, title: 'Battery\nJump Start'),
              const _QuickActionCard(icon: Icons.tire_repair_rounded, title: 'Flat Tire\nSupport'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SosReportTab extends StatelessWidget {
  const _SosReportTab({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BrandTopBar(onMenuTap: onBack),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: _ProgressDash(active: true)),
              SizedBox(width: 10),
              Expanded(child: _ProgressDash()),
              SizedBox(width: 10),
              Expanded(child: _ProgressDash()),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'STEP 01',
            style: GoogleFonts.workSans(
              fontSize: 11,
              color: BrandColors.primary,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: GoogleFonts.plusJakartaSans(
                fontSize: 54 * 0.72,
                fontWeight: FontWeight.w800,
                color: BrandColors.onSurface,
              ),
              children: [
                const TextSpan(text: "What's the\n"),
                TextSpan(
                  text: 'Emergency?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 54 * 0.72,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    color: BrandColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 0.92,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            children: [
              _EmergencyTypeCard(icon: Icons.tire_repair_rounded, title: 'Flat tire', active: true),
              _EmergencyTypeCard(icon: Icons.car_repair_rounded, title: 'Engine\nfailure'),
              _EmergencyTypeCard(icon: Icons.car_crash_rounded, title: 'Accident'),
              _EmergencyTypeCard(icon: Icons.local_gas_station_rounded, title: 'Out of fuel'),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            'STEP 02',
            style: GoogleFonts.workSans(
              fontSize: 11,
              color: BrandColors.primary,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Location Details',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 44 * 0.72,
              fontWeight: FontWeight.w800,
              color: BrandColors.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7D8D3),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: BrandColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Enter address or detect GPS',
                    style: GoogleFonts.workSans(
                      fontSize: 15,
                      color: BrandColors.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'DETECT',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: BrandColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 214,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuB416vigehCWne6XoGfXQABYUfWPwcuDruHnZ9RRb4PcEYtyaNGQ-yD0hk6tZQYyfJZz8EA1U0ssWTcLgs5m0vZ9CIXscBVW-tTEuE5utjXz92TacJDmyEFgYdD6L4SWnq5FUT4zakr74-pEzF4kuoquRna59tHVjFZ31r65OIztgzEfeBLEIUK8pO7Wpya1hytWkOARc4X1cRYJuVnKu9BMyjgoQYF081kUKVzDayPv-beXJHXC2VjjSOK7YtGWovJytUQ-8BSejQ',
                    fit: BoxFit.cover,
                  ),
                  Container(color: const Color(0x99F4E7E4)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'STEP 03',
            style: GoogleFonts.workSans(
              fontSize: 11,
              color: BrandColors.primary,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Evidence & Details',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 44 * 0.72,
              fontWeight: FontWeight.w800,
              color: BrandColors.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(child: _EvidenceAction(icon: Icons.add_a_photo_rounded, label: 'ADD IMAGE')),
              SizedBox(width: 10),
              Expanded(child: _EvidenceAction(icon: Icons.mic_rounded, label: 'RECORD')),
              SizedBox(width: 10),
              Expanded(child: _EvidenceAction(icon: Icons.edit_note_rounded, label: 'WRITE')),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 84,
            decoration: BoxDecoration(
              gradient: BrandColors.ctaGradient,
              borderRadius: BorderRadius.circular(26),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x30BB000E),
                  blurRadius: 28,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SEND REPORT',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 35 * 0.6,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.bolt_rounded, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingStatusTab extends StatelessWidget {
  const _TrackingStatusTab();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAfPriWSKT4UFEj6t137oCSsG_FggiPdt32wHJNurf2pYnLZb3CFSZdjv3x_QkPK7C4fpSOM-8DCvTY-fDEEmMIJE4qx2oxt0PanbKLvj-e3NaS67tjqQ6iK8lzkM7XT40UUsVDNZRe6-eadFCCwK5vBN1Cvq0LPPsw4u3sUr6xJm0LDqfpvT5K-xca5bTmV1eeBm6vf0DWf8XpAQ7OmH1UDjjwkk9QiBfUJyTpgPH2v2gAvdl_UeL7K_E7NAYCQn1CPUwrNlSuPB8',
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xEEFFF8F6), Color(0x00FFF8F6), Color(0xFFFFFFFF)],
              ),
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 130),
            child: Column(
              children: [
                Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.86),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0C291714), blurRadius: 14, offset: Offset(0, 6)),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back_rounded, color: Color(0xFF6E6A77)),
                      const Spacer(),
                      Text(
                        'Tracking Assistance',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 39 * 0.56,
                          color: const Color(0xFF6E6A77),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.notifications_rounded, color: Color(0xFF6E6A77)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.86),
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'CURRENT STATUS',
                              style: GoogleFonts.workSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: BrandColors.secondary,
                                letterSpacing: 3,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.circle, size: 14, color: BrandColors.primary),
                            const SizedBox(width: 6),
                            Text('Live', style: GoogleFonts.workSans(fontSize: 36 * 0.52, fontWeight: FontWeight.w700, color: BrandColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Help is 8 mins away',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 52 * 0.74,
                            color: BrandColors.onSurface,
                            fontWeight: FontWeight.w800,
                            height: 1.02,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Technician Marco is en route to your location.',
                          style: GoogleFonts.workSans(
                            fontSize: 41 * 0.48,
                            color: BrandColors.onSurface.withValues(alpha: 0.8),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 180),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCF9F8),
                      borderRadius: BorderRadius.circular(44),
                      boxShadow: const [
                        BoxShadow(color: Color(0x14291714), blurRadius: 28, offset: Offset(0, 10)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(width: 8, height: 500, color: BrandColors.primary),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(18),
                                          child: Image.network(
                                            'https://lh3.googleusercontent.com/aida-public/AB6AXuAp3eW2FAHXb8a3Htmi4mu56PJ6V0cc8ObWcHbXXaRLC8nsGpDnMaSxl7UmJEFzIcOaOyL-To5sm4AP0E976vFicZjILpthnc5HvR50nL_pTIZXkZEu3Om3MjsEiewaw9N05jd8SdovCUXpLdEEg7ec0h53-vNciiO4ygNaBmptsNvVGL4_1c44w42lUKH3zV-3WEorfN3HTnWZB4ZUd8cZdRDH23tbr0Qy8V1hM0ZnkH3gpAdYkvCH-c-VV8bMCX6smjbKB1WEorQ',
                                            width: 102,
                                            height: 102,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          right: -2,
                                          bottom: -2,
                                          child: Container(
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(
                                              color: BrandColors.primary,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Icon(Icons.verified_rounded, color: Colors.white, size: 18),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Marco\nSantini',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 52 * 0.62,
                                              fontWeight: FontWeight.w800,
                                              color: BrandColors.onSurface,
                                              height: 1.08,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF3D6D1),
                                              borderRadius: BorderRadius.circular(22),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.star_rounded, color: BrandColors.secondary, size: 20),
                                                const SizedBox(width: 6),
                                                Text('4.9 (124\nreviews)', style: GoogleFonts.workSans(fontSize: 16 * 1.1, fontWeight: FontWeight.w700, color: BrandColors.secondary)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                const Row(
                                  children: [
                                    Expanded(child: _MiniMetricCard(icon: Icons.schedule_rounded, title: 'Estimated ETA', value: '08:42 AM')),
                                    SizedBox(width: 12),
                                    Expanded(child: _MiniMetricCard(icon: Icons.pin_drop_rounded, title: 'Distance', value: '3.2 Miles')),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  height: 74,
                                  decoration: BoxDecoration(
                                    gradient: BrandColors.ctaGradient,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.forum_rounded, color: Colors.white, size: 30),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Chat with Marco',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 48 * 0.58,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.user, required this.onEditProfile, required this.onLogout});

  final VehiSosUser user;
  final VoidCallback onEditProfile;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BrandTopBar(),
          const SizedBox(height: 20),
          Row(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuC6aGXc0On5yOa9uLICpluJMtu9RzDA1tqivrHJW6n_xvY9zhCv49iErQ7t8QMMU43Z17Cx4hz_LkgATOLYLXJfS3WTDbquuRACzQ-V4JAMwda6-MH4_ZAUjK7CVg63Q-ol7McJrOOftrt4H8tVXP8wqhTYUg4k2SrNy1fAsYNmOxxHFoVhdKwA7lusqjAiqnSUeU3MR3cBdbyee4_n4p38rH13PbJkDlPf0wdOD8UrKdV7le1dbqkuPuTyJ_O1CgHJLjCrZFjBWCM',
                      width: 116,
                      height: 116,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: -3,
                    bottom: -3,
                    child: GestureDetector(
                      onTap: onEditProfile,
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: BrandColors.primary,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(color: Color(0x2EBB000E), blurRadius: 16, offset: Offset(0, 8)),
                          ],
                        ),
                        child: const Icon(Icons.edit_rounded, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 54 * 0.6,
                        color: BrandColors.onSurface,
                        fontWeight: FontWeight.w800,
                        height: 1.03,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.correo,
                      style: GoogleFonts.workSans(
                        fontSize: 35 * 0.48,
                        color: BrandColors.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: _ProfileMiniStat(title: 'MEMBERSHIP', value: 'Premium Gold')),
              SizedBox(width: 12),
              Expanded(child: _ProfileMiniStat(title: 'REGISTERED', value: '2 Vehicles')),
            ],
          ),
          const SizedBox(height: 28),
          const _ProfileSectionTitle('ACCOUNT'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFFDECE9), borderRadius: BorderRadius.circular(26)),
            child: Column(
              children: [
                _ProfileMenuItem(icon: Icons.person_rounded, label: 'Manage Profile', onTap: onEditProfile),
                const _ProfileMenuItem(icon: Icons.shield_rounded, label: 'Password & Security'),
                const _ProfileMenuItem(icon: Icons.notifications_active_rounded, label: 'Notifications'),
                const _ProfileMenuItem(icon: Icons.language_rounded, label: 'Language', subtitle: 'English (US)'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _ProfileSectionTitle('PREFERENCES'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFFDECE9), borderRadius: BorderRadius.circular(26)),
            child: const Column(
              children: [
                _ProfileMenuItem(icon: Icons.info_rounded, label: 'About Us'),
                _ProfileMenuItem(icon: Icons.palette_rounded, label: 'Theme', subtitle: 'Light Mode'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _ProfileSectionTitle('SUPPORT'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFFDECE9), borderRadius: BorderRadius.circular(26)),
            child: const Column(
              children: [
                _ProfileMenuItem(icon: Icons.help_rounded, label: 'Help Center'),
                _ProfileMenuItem(icon: Icons.contact_support_rounded, label: 'Contact Us'),
              ],
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: onLogout,
            child: Container(
              height: 82,
              decoration: BoxDecoration(
                color: const Color(0xFFF6D5D1),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.logout_rounded, color: BrandColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: GoogleFonts.plusJakartaSans(
                        color: BrandColors.primary,
                        fontSize: 38 * 0.56,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandTopBar extends StatelessWidget {
  const _BrandTopBar({this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onMenuTap,
            icon: Icon(onMenuTap == null ? Icons.menu_rounded : Icons.arrow_back_rounded, color: BrandColors.primary),
          ),
          const Spacer(),
          Text(
            'VehiSOS',
            style: GoogleFonts.plusJakartaSans(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w800,
              color: BrandColors.primary,
              fontSize: 44 * 0.66,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_rounded, color: BrandColors.primary),
          ),
        ],
      ),
    );
  }
}

class _HeroGuardianCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 270,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCLcXDjKZq4jUnSISgSybSVghKsJEQRE494ipo_cgkhDl2mqt2RqRaXq-sqqY7HR6K4FPn3rkCW24bKEuV82JGIntDPkIdAukYRFG-Lu3fn9cVzmkrCQ2ivhE4x31QVp6sjlie0NnlNqpJ97xb7UFpSNRTG3Zy5SsQEkF9mvyXjP6NQMdYcythGS3zIzk_7a6OTLHvGNbK05nOh4xga6vThrbAdJr5peGjb_yPm2zCGT3w30U6hYJAM7iVdILzUrr4zxWYYarn_nBg',
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.34),
              colorBlendMode: BlendMode.darken,
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x30FFFFFF), Color(0xBBFFF8F6)],
                ),
              ),
            ),
            Positioned(
              left: 22,
              right: 22,
              bottom: 26,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GUARDIAN STATUS',
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: BrandColors.primary,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All Systems\nSecure.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 52 * 0.68,
                      color: BrandColors.onSurface,
                      fontWeight: FontWeight.w800,
                      height: 1.04,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your vehicles are connected to our premium roadside monitoring network.',
                    style: GoogleFonts.workSans(
                      fontSize: 39 * 0.46,
                      color: BrandColors.onSurface.withValues(alpha: 0.82),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseSosButton extends StatelessWidget {
  const _PulseSosButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 190,
        height: 190,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(width: 188, height: 188, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x55BB000E))),
            Container(width: 166, height: 166, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x33BB000E))),
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: BrandColors.ctaGradient,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 7),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.ac_unit_rounded, color: Colors.white, size: 46),
                    const SizedBox(height: 3),
                    Text(
                      'SOS',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 38 * 0.6,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFBECE8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.workSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: BrandColors.onSurface,
          letterSpacing: 0.9,
        ),
      ),
    );
  }
}

class _VehicleTile extends StatelessWidget {
  const _VehicleTile({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: BrandColors.primary),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w700, color: BrandColors.onSurface)),
            const SizedBox(height: 2),
            Text(subtitle, style: GoogleFonts.workSans(fontSize: 11, color: BrandColors.onSurface.withValues(alpha: 0.66))),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.icon, required this.title, this.active = false, this.onTap});

  final IconData icon;
  final String title;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: active ? BrandColors.primary : const Color(0xFFFDECE9),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: active ? Colors.white : BrandColors.primary, size: 34),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                color: active ? Colors.white : BrandColors.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 33 * 0.55,
                height: 1.12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressDash extends StatelessWidget {
  const _ProgressDash({this.active = false});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: active ? BrandColors.primary : const Color(0xFFF1CDC8),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _EmergencyTypeCard extends StatelessWidget {
  const _EmergencyTypeCard({required this.icon, required this.title, this.active = false});

  final IconData icon;
  final String title;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: active ? Colors.white : const Color(0xFFFDEDEB),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        children: [
          if (active)
            Positioned(
              left: -18,
              top: 0,
              bottom: 0,
              child: Container(width: 6, decoration: BoxDecoration(color: BrandColors.primary, borderRadius: BorderRadius.circular(8))),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: active ? BrandColors.primary : BrandColors.onSurface.withValues(alpha: 0.78), size: 34),
              const Spacer(),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 38 * 0.56,
                  fontWeight: FontWeight.w700,
                  color: BrandColors.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EvidenceAction extends StatelessWidget {
  const _EvidenceAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.66),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: BrandColors.primary),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.workSans(
              fontSize: 11,
              color: BrandColors.onSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetricCard extends StatelessWidget {
  const _MiniMetricCard({required this.icon, required this.title, required this.value});

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFFDECEA), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: BrandColors.primary),
          const SizedBox(height: 10),
          Text(title, style: GoogleFonts.workSans(fontSize: 13, color: BrandColors.onSurface.withValues(alpha: 0.76))),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 37 * 0.56, fontWeight: FontWeight.w800, color: BrandColors.onSurface)),
        ],
      ),
    );
  }
}

class _ProfileMiniStat extends StatelessWidget {
  const _ProfileMiniStat({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECE9),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.workSans(fontSize: 11, fontWeight: FontWeight.w700, color: BrandColors.secondary, letterSpacing: 2.2)),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 36 * 0.55, fontWeight: FontWeight.w800, color: BrandColors.onSurface)),
        ],
      ),
    );
  }
}

class _ProfileSectionTitle extends StatelessWidget {
  const _ProfileSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: GoogleFonts.workSans(
          fontSize: 14,
          color: BrandColors.secondary,
          fontWeight: FontWeight.w700,
          letterSpacing: 4,
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({required this.icon, required this.label, this.subtitle, this.onTap});

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: const Color(0xFFF8DAD6), borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: BrandColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 35 * 0.56,
                      fontWeight: FontWeight.w700,
                      color: BrandColors.onSurface,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: GoogleFonts.workSans(fontSize: 13, color: BrandColors.onSurface.withValues(alpha: 0.62)),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: BrandColors.onSurface.withValues(alpha: 0.5), size: 30),
          ],
        ),
      ),
    );
  }
}

class _ClientBottomNav extends StatelessWidget {
  const _ClientBottomNav({required this.currentIndex, required this.onChanged});

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 106,
      decoration: const BoxDecoration(
        color: Color(0xF5F5F5F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Color(0x14291714), blurRadius: 30, offset: Offset(0, -8)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.ac_unit_rounded, label: 'SOS', active: currentIndex == 0, onTap: () => onChanged(0)),
          _NavItem(icon: Icons.assignment_turned_in_rounded, label: 'STATUS', active: currentIndex == 1, onTap: () => onChanged(1)),
          _NavItem(icon: Icons.person_rounded, label: 'PROFILE', active: currentIndex == 2, onTap: () => onChanged(2)),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: active ? 25 : 4, vertical: 10),
        decoration: BoxDecoration(
          color: active ? BrandColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: active
              ? const [
                  BoxShadow(color: Color(0x2ABB000E), blurRadius: 16, offset: Offset(0, 8)),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? Colors.white : const Color(0xFF7E7A88), size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.workSans(
                color: active ? Colors.white : const Color(0xFF7E7A88),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
