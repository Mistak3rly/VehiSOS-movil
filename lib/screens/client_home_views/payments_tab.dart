part of '../client_home_screen.dart';

class PaymentsTab extends StatelessWidget {
  const PaymentsTab({super.key, required this.onOpenNotifications});

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
              _PaymentsTopBar(onNotificationsTap: onOpenNotifications),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: BrandColors.ctaGradient,
                  borderRadius: BorderRadius.circular(34),
                  boxShadow: const [BoxShadow(color: Color(0x33291714), blurRadius: 26, offset: Offset(0, 12))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CURRENT PLAN', style: GoogleFonts.workSans(color: Colors.white.withValues(alpha: 0.85), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2.3)),
                            const SizedBox(height: 10),
                            Text('Premium\nGold', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 52 * 0.72, height: 0.95)),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(999)),
                          child: Text('Active', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Row(
                      children: [
                        Expanded(child: _PlanMetric(label: 'Next billing date', value: 'Oct 24, 2024', light: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _PlanMetric(label: 'Monthly cost', value: r'$14.99', light: true)),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Container(height: 60, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Text('Manage Plan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: BrandColors.primary))),
                    const SizedBox(height: 12),
                    Container(height: 60, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withValues(alpha: 0.08))), child: Text('View Perks', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text('Saved Methods', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: BrandColors.onSurface)),
                  const Spacer(),
                  Text('+ ADD NEW CARD', style: GoogleFonts.workSans(color: BrandColors.primary, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.8)),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: const Color(0xFFFDECE9), borderRadius: BorderRadius.circular(24), border: Border(left: BorderSide(color: BrandColors.primary, width: 6))),
                child: Row(
                  children: [
                    _CardLogoBox(color: const Color(0xFF1A4C8F), label: 'VISA'),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Visa Classic', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text('•••• •••• •••• 4492', style: GoogleFonts.workSans(color: BrandColors.onSurface.withValues(alpha: 0.7)))])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('EXPIRES', style: GoogleFonts.workSans(fontSize: 10, letterSpacing: 1.8, fontWeight: FontWeight.w800, color: BrandColors.onSurface.withValues(alpha: 0.55))), const SizedBox(height: 3), Text('09/27', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))]),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: const Color(0xFFFDECE9), borderRadius: BorderRadius.circular(24)),
                child: Row(
                  children: [
                    _CardLogoBox(color: const Color(0xFF1A1A1A), label: 'mc'),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('World Elite Debit', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text('•••• •••• •••• 8103', style: GoogleFonts.workSans(color: BrandColors.onSurface.withValues(alpha: 0.7)))])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('EXPIRES', style: GoogleFonts.workSans(fontSize: 10, letterSpacing: 1.8, fontWeight: FontWeight.w800, color: BrandColors.onSurface.withValues(alpha: 0.55))), const SizedBox(height: 3), Text('12/25', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800))]),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: const Color(0xFFF6D6D1), borderRadius: BorderRadius.circular(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.security_rounded, color: BrandColors.primary),
                    const SizedBox(height: 10),
                    Text('Secure Payments', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text('All transactions are encrypted with military-grade security. We never store your CVV codes.', style: GoogleFonts.workSans(fontSize: 14, height: 1.5, color: BrandColors.onSurface.withValues(alpha: 0.78))),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: const Color(0xFFF6D6D1), borderRadius: BorderRadius.circular(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_awesome, color: BrandColors.secondary),
                    const SizedBox(height: 10),
                    Text('Quick Dispatch', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text('Verified cards ensure faster technician dispatch during roadside emergencies.', style: GoogleFonts.workSans(fontSize: 14, height: 1.5, color: BrandColors.onSurface.withValues(alpha: 0.78))),
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

class _PaymentsTopBar extends StatelessWidget {
  const _PaymentsTopBar({required this.onNotificationsTap});

  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBE8CJsUkjYhZkdkSSVqrKBwKO-rAlsPVlNBfuEpA73oNjrVv_wKwZOnKwYtzvOLpJtzgQQxR-lG4QRrOrsrXd9KyWKtvVj0pzS2_XtmCTrXVlDcJCNCf1rKgWnXDBhfWJsMPnPSAzRiWTneNA7EuXjjY1QGBFHChnfo4Jx_QtaSgcyvxUMuhStGVSu_w4cPp3TirInbOsH0f72m0DAXEsJJJo68j9D0ekhnn8dIG1QyJ0O8WvTGrWkS6q1fftt4vT8fIR_thsHE5E')),
        const SizedBox(width: 10),
        Text('Payments', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: BrandColors.onSurface)),
        const Spacer(),
        Text('VehiSOS', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic, color: BrandColors.primary)),
        IconButton(onPressed: onNotificationsTap, icon: const Icon(Icons.notifications_rounded, color: BrandColors.onSurface)),
      ],
    );
  }
}

class _PlanMetric extends StatelessWidget {
  const _PlanMetric({required this.label, required this.value, this.light = false});

  final String label;
  final String value;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.workSans(color: light ? Colors.white.withValues(alpha: 0.75) : BrandColors.onSurface.withValues(alpha: 0.55), fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.plusJakartaSans(color: light ? Colors.white : BrandColors.onSurface, fontWeight: FontWeight.w800, fontSize: 18)),
      ],
    );
  }
}

class _CardLogoBox extends StatelessWidget {
  const _CardLogoBox({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }
}
