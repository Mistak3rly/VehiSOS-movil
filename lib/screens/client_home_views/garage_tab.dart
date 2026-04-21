part of '../client_home_screen.dart';

class GarageTab extends StatelessWidget {
  const GarageTab({super.key, required this.onOpenNotifications});

  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 128),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GarageTopBar(onNotificationsTap: onOpenNotifications),
              const SizedBox(height: 26),
              Text(
                'ACTIVE FLEET',
                style: GoogleFonts.workSans(
                  color: BrandColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 2.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'My Garage',
                style: GoogleFonts.plusJakartaSans(
                  color: BrandColors.onSurface,
                  fontWeight: FontWeight.w800,
                  fontSize: 52 * 0.72,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(color: Color(0x14291714), blurRadius: 26, offset: Offset(0, 10)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                          child: Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDJfvXz1qa5rorRutMTM09WWhquwNg6xhBXwSdNugtXV7nIruaR1ZV0uKbDi0GKjKEJxB2bMc6_wfz4kJEdWfWAEAWb_1aTm2aMSo2S8txMwL_jl2WRg0v4EtqI5E1a43sPi1i1IwOoSFxyttdpR1iPrJPi0DKBRfbE3zXrU1vE-DNGqT_R58p4mUhJABeJykkavX6SK6MpCWOWfqxvtcZCKHE55USsWeI-lsygrdL0Ajekhy9jcoxOhJIu1NCP7TqD92ZCw4UzQ7s',
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: BrandColors.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'PRIMARY VEHICLE',
                              style: GoogleFonts.workSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                letterSpacing: 1.8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  'Tesla Model S',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: BrandColors.onSurface,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 36,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDECE9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.bolt_rounded, color: BrandColors.primary, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '84%',
                                      style: GoogleFonts.workSans(
                                        color: BrandColors.primary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Midnight Silver Edition',
                            style: GoogleFonts.workSans(
                              color: BrandColors.onSurface.withValues(alpha: 0.76),
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: const [
                              Expanded(child: _GarageMiniStat(label: 'SYSTEM HEALTH', value: 'Optimal')),
                              SizedBox(width: 10),
                              Expanded(child: _GarageMiniStat(label: 'RANGE', value: '284 mi')),
                              SizedBox(width: 10),
                              Expanded(child: _GarageMiniStat(label: 'LAST SOS CHECK', value: '2d ago')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                height: 176,
                decoration: BoxDecoration(
                  color: BrandColors.primary,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 34),
                      ),
                      const SizedBox(height: 12),
                      Text('Add Vehicle', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text('Extend your guardian coverage to a new asset.', style: GoogleFonts.workSans(color: Colors.white.withValues(alpha: 0.82), fontSize: 14), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6D6D1),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fleet Summary', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: BrandColors.onSurface)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('Coverage Status', style: GoogleFonts.workSans(color: BrandColors.onSurface.withValues(alpha: 0.7), fontSize: 13)),
                        const Spacer(),
                        Text('Active', style: GoogleFonts.workSans(color: BrandColors.primary, fontWeight: FontWeight.w800, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(height: 4, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.65), borderRadius: BorderRadius.circular(99))),
                    const SizedBox(height: 12),
                    Text('2 vehicles currently synchronized with Guardian Sentinel real-time diagnostic engine.', style: GoogleFonts.workSans(fontSize: 12, color: BrandColors.onSurface.withValues(alpha: 0.7))),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: const [BoxShadow(color: Color(0x14291714), blurRadius: 20, offset: Offset(0, 10))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAzco6UasrloiGdlhINGgZM7XpKGjZJqhrXe385yBvnCYF6iQ5HzF3Y5c8-gJSMRoUWREEf3ahXePZQvY0uPLZUcPIV9SIvUg7M241NLcQvCLxeNfZMlPaIRy1OoaMLw-cOSUxLH6qZbcRs4hSq4G3ABV6AxLhI-xDZTNPtQQ932KaWHeiF1vik0bngqmoPtIHfJdYKztCiyvsU-cogF6dPT6zbzs9BGWk9Qd8jpB1gkAxK3MTrjVqNNtcJrrMwfp_lR4f_VzJqOyU',
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text('Rivian R1S', style: GoogleFonts.plusJakartaSans(fontSize: 27, fontWeight: FontWeight.w800, color: BrandColors.onSurface))),
                              const Icon(Icons.more_vert, color: Color(0xFFB8A9A5)),
                            ],
                          ),
                          Text('Adventure Package • Forest Green', style: GoogleFonts.workSans(fontSize: 14, color: BrandColors.onSurface.withValues(alpha: 0.76))),
                          const SizedBox(height: 14),
                          Row(
                            children: const [
                              Expanded(child: _GarageMetric(label: 'CHARGE', value: '62%', suffix: 'Remaining', icon: Icons.battery_charging_full)),
                              SizedBox(width: 10),
                              Expanded(child: _GarageMetric(label: 'TIRES', value: '34', suffix: 'PSI avg', icon: Icons.tire_repair)),
                              SizedBox(width: 10),
                              Expanded(child: _GarageMetric(label: 'CABIN', value: '72°', suffix: 'F', icon: Icons.thermostat)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: const Color(0xFFFDECE9), borderRadius: BorderRadius.circular(12)),
                                  child: Text('Details', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: BrandColors.onSurface)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: BrandColors.primary, borderRadius: BorderRadius.circular(12)),
                                  child: Text('Sync Diagnostics', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text('Upcoming Service', style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, color: BrandColors.onSurface)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECE9),
                  borderRadius: BorderRadius.circular(22),
                  border: Border(left: BorderSide(color: BrandColors.secondary, width: 6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(color: const Color(0xFFF5E1D7), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.build_rounded, color: BrandColors.secondary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Annual Inspection - Tesla Model S', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: BrandColors.onSurface)),
                              const SizedBox(height: 4),
                              Text('Recommended in 1,240 miles or 14 days.', style: GoogleFonts.workSans(fontSize: 12, color: BrandColors.onSurface.withValues(alpha: 0.75))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(height: 46, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)), child: Text('Schedule Service', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: BrandColors.onSurface))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GarageTopBar extends StatelessWidget {
  const _GarageTopBar({required this.onNotificationsTap});

  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuA7gVM1_LseHELYeojr93iNg_2VSuHkrZ0PsffjCjYRYJOEiBLl8pabFw2QsD_8_ZJmNBL6unPu9FV5QiC3s9v6WiL4FhmGw8u6TFq5D_gmeoJrkLiNMyJN3zRAdg6iD4p_kBjML0pY3nsbvhtPiuXPf2pCwwlmp2HyATjj7TP9oJwmOU2hBO4ai04GhLg3helEE0KyDm2hvlom1LlGdvGnyGALENUu9jkC_cBv-tjY5gPCCkDnBqH6cH3zboG22IDYQfi9chK2cL0')),
        const SizedBox(width: 10),
        Text('VehiSOS', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic, color: BrandColors.onSurface)),
        const Spacer(),
        IconButton(onPressed: onNotificationsTap, icon: const Icon(Icons.notifications_rounded, color: BrandColors.primary)),
      ],
    );
  }
}

class _GarageMiniStat extends StatelessWidget {
  const _GarageMiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFFDECE9), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.workSans(fontSize: 10, fontWeight: FontWeight.w800, color: BrandColors.onSurface.withValues(alpha: 0.56), letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: BrandColors.onSurface)),
        ],
      ),
    );
  }
}

class _GarageMetric extends StatelessWidget {
  const _GarageMetric({required this.label, required this.value, required this.suffix, required this.icon});

  final String label;
  final String value;
  final String suffix;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFFDECE9), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(width: 28, height: 28, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: BrandColors.primary, size: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.workSans(fontSize: 10, fontWeight: FontWeight.w800, color: BrandColors.onSurface.withValues(alpha: 0.56), letterSpacing: 1.1)),
                const SizedBox(height: 4),
                Text('$value $suffix', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: BrandColors.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
