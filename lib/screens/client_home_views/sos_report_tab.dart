part of '../client_home_screen.dart';

class _SosReportTab extends StatelessWidget {
  const _SosReportTab({required this.onBack, required this.onOpenNotifications});

  final VoidCallback onBack;
  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BrandTopBar(onMenuTap: onBack, onNotificationsTap: onOpenNotifications),
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
              child: Container(
                width: 6,
                decoration: BoxDecoration(
                  color: BrandColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: active ? BrandColors.primary : BrandColors.onSurface.withValues(alpha: 0.78),
                size: 34,
              ),
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
