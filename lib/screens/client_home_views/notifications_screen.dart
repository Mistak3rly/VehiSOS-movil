part of '../client_home_screen.dart';

class ClientNotificationsScreen extends StatelessWidget {
  const ClientNotificationsScreen({super.key});

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
              Row(
                children: [
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_rounded, color: BrandColors.onSurface)),
                  const CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBE8CJsUkjYhZkdkSSVqrKBwKO-rAlsPVlNBfuEpA73oNjrVv_wKwZOnKwYtzvOLpJtzgQQxR-lG4QRrOrsrXd9KyWKtvVj0pzS2_XtmCTrXVlDcJCNCf1rKgWnXDBhfWJsMPnPSAzRiWTneNA7EuXjjY1QGBFHChnfo4Jx_QtaSgcyvxUMuhStGVSu_w4cPp3TirInbOsH0f72m0DAXEsJJJo68j9D0ekhnn8dIG1QyJ0O8WvTGrWkS6q1fftt4vT8fIR_thsHE5E')),
                  const SizedBox(width: 10),
                  Text('Notifications', style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, color: BrandColors.onSurface)),
                  const Spacer(),
                  Text('MARK ALL READ', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: BrandColors.primary)),
                ],
              ),
              const SizedBox(height: 34),
              Row(
                children: [
                  Text('Recent Updates', style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w800, color: BrandColors.onSurface)),
                  const Spacer(),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: const Color(0xFFF7D7D4), borderRadius: BorderRadius.circular(999)), child: Text('3 NEW', style: GoogleFonts.plusJakartaSans(color: BrandColors.primary, fontWeight: FontWeight.w800))),
                ],
              ),
              const SizedBox(height: 16),
              _NotificationCard(
                leadingColor: BrandColors.primary,
                icon: Icons.emergency,
                title: 'Technician Assigned',
                subtitle: 'Marco R. is 4.2 miles away and dispatched to your location. Expected arrival: 12 mins.',
                tag: 'URGENT',
                innerTitle: 'Marco Rodriguez',
                innerLabel: 'ASSIGNED HELPER',
                showCall: true,
              ),
              const SizedBox(height: 14),
              _NotificationCard(
                leadingColor: const Color(0xFFFFA040),
                icon: Icons.build,
                title: 'Garage Confirmation',
                subtitle: 'Silverstone Auto Center has accepted your service request for tomorrow at 10:00 AM.',
                time: '2H AGO',
                unreadDot: true,
              ),
              const SizedBox(height: 14),
              _NotificationCard(
                leadingColor: const Color(0xFFF5D7D3),
                icon: Icons.payments,
                title: 'Payment Successful',
                subtitle: 'Your payment for "Towing Service #8812" has been processed successfully. View your digital receipt.',
                time: 'YESTERDAY',
                actionLabel: 'VIEW RECEIPT',
              ),
              const SizedBox(height: 26),
              Text('Earlier this week', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFFAAA4A2))),
              const SizedBox(height: 14),
              _NotificationCard(
                leadingColor: const Color(0xFFF0E7E4),
                icon: Icons.directions_car,
                title: 'Tire Inspection Due',
                subtitle: 'Based on your mileage, we recommend a routine tire health check at your nearest partner garage.',
                time: 'MONDAY',
                muted: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.leadingColor, required this.icon, required this.title, required this.subtitle, this.tag, this.time, this.innerLabel, this.innerTitle, this.showCall = false, this.actionLabel, this.unreadDot = false, this.muted = false});

  final Color leadingColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final String? tag;
  final String? time;
  final String? innerLabel;
  final String? innerTitle;
  final bool showCall;
  final String? actionLabel;
  final bool unreadDot;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: muted ? const Color(0xFFF7F0ED) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: Color(0x12291714), blurRadius: 18, offset: Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: leadingColor, borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: muted ? Colors.white54 : Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: BrandColors.onSurface))),
                        if (tag != null) Text(tag!, style: GoogleFonts.workSans(fontSize: 10, color: BrandColors.primary, fontWeight: FontWeight.w800, letterSpacing: 1.4)),
                        if (time != null) Text(time!, style: GoogleFonts.workSans(fontSize: 10, color: BrandColors.onSurface.withValues(alpha: 0.55), fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(subtitle, style: GoogleFonts.workSans(fontSize: 14, height: 1.45, color: muted ? BrandColors.onSurface.withValues(alpha: 0.35) : BrandColors.onSurface.withValues(alpha: 0.78))),
                  ],
                ),
              ),
              if (unreadDot) Container(width: 10, height: 10, margin: const EdgeInsets.only(top: 8), decoration: const BoxDecoration(color: BrandColors.primary, shape: BoxShape.circle)),
            ],
          ),
          if (innerTitle != null || innerLabel != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFFDECE9), borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const CircleAvatar(radius: 24, backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCsHAUvgAqgjQvv--LMuCpgtI7ll6E7G4A0orYsnUMSbO6GcSFKTOWSA3PXfYc8-CChIumi19jv-DUr7PEOCZaTq1uGj31E-Qx4EWI0EEICjsr-He39oPnWV6D3PYYOssJByBdwXUfSOkbl2ee7tRO8AUDNe91l7_ZX0qWc-hzhhKybNz4lCIP91X9ud8wo004WqHXoKxwSwjsIInTcO-myQjuy-oTdv4vTS4g5gwfDS3hLKE-fd7FkqXPZxNoGOflD7R9hV30ZmEE')),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(innerLabel!, style: GoogleFonts.workSans(fontSize: 11, fontWeight: FontWeight.w800, color: BrandColors.onSurface.withValues(alpha: 0.55), letterSpacing: 1.2)),
                      const SizedBox(height: 4),
                      Text(innerTitle!, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: BrandColors.onSurface)),
                    ]),
                  ),
                  if (showCall) Container(width: 48, height: 48, decoration: const BoxDecoration(color: BrandColors.primary, shape: BoxShape.circle), child: const Icon(Icons.call, color: Colors.white)),
                ],
              ),
            ),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: 14),
            Container(height: 42, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFFF8D8D2), borderRadius: BorderRadius.circular(16)), child: Text(actionLabel!, style: GoogleFonts.workSans(fontSize: 11, fontWeight: FontWeight.w800, color: BrandColors.onSurface, letterSpacing: 1.4))),
          ],
        ],
      ),
    );
  }
}
