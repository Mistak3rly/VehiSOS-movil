part of '../client_home_screen.dart';

class _SosDashboardTab extends StatelessWidget {
  const _SosDashboardTab({
    required this.onOpenReport,
    required this.onOpenStatus,
    required this.onOpenNotifications,
  });

  final VoidCallback onOpenReport;
  final VoidCallback onOpenStatus;
  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BrandTopBar(onNotificationsTap: onOpenNotifications),
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
                            const Icon(
                              Icons.local_shipping_rounded,
                              size: 15,
                              color: BrandColors.primary,
                            ),
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
                _VehicleTile(
                  icon: Icons.directions_car_filled_rounded,
                  title: 'Tesla Model S',
                  subtitle: 'NY-992-KLD • 98% HEALTH',
                ),
                SizedBox(height: 14),
                _VehicleTile(
                  icon: Icons.electric_car_rounded,
                  title: 'Rivian R1S',
                  subtitle: 'CA-442-EVX • 100% HEALTH',
                ),
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
              const _QuickActionCard(
                icon: Icons.car_repair_rounded,
                title: 'Roadside\nAssistance',
              ),
              _QuickActionCard(
                icon: Icons.local_shipping_rounded,
                title: 'Request Tow\nTruck',
                active: true,
                onTap: onOpenReport,
              ),
              const _QuickActionCard(
                icon: Icons.battery_charging_full_rounded,
                title: 'Battery\nJump Start',
              ),
              const _QuickActionCard(
                icon: Icons.tire_repair_rounded,
                title: 'Flat Tire\nSupport',
              ),
            ],
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
            Container(
              width: 188,
              height: 188,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x55BB000E),
              ),
            ),
            Container(
              width: 166,
              height: 166,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x33BB000E),
              ),
            ),
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
  const _VehicleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: BrandColors.primary),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: BrandColors.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.workSans(
                fontSize: 11,
                color: BrandColors.onSurface.withValues(alpha: 0.66),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    this.active = false,
    this.onTap,
  });

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
