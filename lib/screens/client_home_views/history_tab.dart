part of '../client_home_screen.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key, required this.onOpenNotifications});

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
              _HistoryTopBar(onNotificationsTap: onOpenNotifications),
              const SizedBox(height: 30),
              Text('OVERVIEW', style: GoogleFonts.workSans(color: BrandColors.primary, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 2.4)),
              const SizedBox(height: 6),
              Text('Your Incident\nArchive.', style: GoogleFonts.plusJakartaSans(color: BrandColors.onSurface, fontWeight: FontWeight.w800, fontSize: 50 * 0.72, height: 0.95)),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: const [BoxShadow(color: Color(0x14291714), blurRadius: 24, offset: Offset(0, 10))]),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 8, height: 320, decoration: const BoxDecoration(color: BrandColors.primary, borderRadius: BorderRadius.only(topLeft: Radius.circular(28), bottomLeft: Radius.circular(28)))),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text('OCT 24, 2023 • 14:22', style: GoogleFonts.workSans(fontSize: 12, color: BrandColors.onSurface.withValues(alpha: 0.55), letterSpacing: 2.2))),
                                    Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: const Color(0xFFF7D7D4), borderRadius: BorderRadius.circular(999)), child: Text('COMPLETED', style: GoogleFonts.workSans(fontSize: 10, fontWeight: FontWeight.w800, color: BrandColors.primary, letterSpacing: 1.4))),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text('Emergency\nTowing', style: GoogleFonts.plusJakartaSans(fontSize: 34, fontWeight: FontWeight.w800, color: BrandColors.onSurface, height: 0.95)),
                                const SizedBox(height: 18),
                                Text('LOCATION', style: GoogleFonts.workSans(fontSize: 11, color: BrandColors.onSurface.withValues(alpha: 0.55), letterSpacing: 1.4)),
                                const SizedBox(height: 3),
                                Text('I-95 North, Exit 12', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 14),
                                Text('VEHICLE', style: GoogleFonts.workSans(fontSize: 11, color: BrandColors.onSurface.withValues(alpha: 0.55), letterSpacing: 1.4)),
                                const SizedBox(height: 3),
                                Text('Tesla Model 3 • ABC-1234', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 14),
                                Text('COST', style: GoogleFonts.workSans(fontSize: 11, color: BrandColors.onSurface.withValues(alpha: 0.55), letterSpacing: 1.4)),
                                const SizedBox(height: 3),
                                Text(r'$142.50', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: BrandColors.primary)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    ClipRRect(
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAQDQQGYgiNFYuzL8plQRuQc7GlmP2JCGWWZdZNB51O0GLd7uyedXdrXUUpEhX4kMp06LL1QakLIDV_HSDeJ07U41wzZ2nMtrAwPvkUhNBmZhtLPYeyXVWDPpc___wlpyAxgy0WpNSor1Cx0bY97MnzstoynPR4GkxtKnTF8-LkjJh-_J-JVTvYw7sIUyiEuGJTZ3dDbhEOkVTLJSFqKXBweyiEGT5WJGcFbbxnRKF-AYDkElXqvvryzvfbzsJ7oTY-BY57EwaOliU',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(color: const Color(0xFFF8D8D2), borderRadius: BorderRadius.circular(26)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SEP 12, 2023', style: GoogleFonts.workSans(fontSize: 12, color: BrandColors.onSurface.withValues(alpha: 0.55), letterSpacing: 2.2)),
                          const SizedBox(height: 8),
                          Text('Flat Tire Repair', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: BrandColors.onSurface)),
                          const SizedBox(height: 18),
                          Text('TOTAL PAID', style: GoogleFonts.workSans(fontSize: 11, color: BrandColors.onSurface.withValues(alpha: 0.55), letterSpacing: 1.4)),
                          const SizedBox(height: 3),
                          Text(r'$45.00', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: BrandColors.onSurface)),
                          const SizedBox(height: 10),
                          Align(alignment: Alignment.centerRight, child: Container(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8), decoration: BoxDecoration(color: BrandColors.onSurface, borderRadius: BorderRadius.circular(999)), child: Text('DETAILS', style: GoogleFonts.workSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 2)))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(color: const Color(0xFFF8D8D2), borderRadius: BorderRadius.circular(26)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AUG 05, 2023', style: GoogleFonts.workSans(fontSize: 12, color: BrandColors.onSurface.withValues(alpha: 0.55), letterSpacing: 2.2)),
                          const SizedBox(height: 8),
                          Text('Fuel Delivery', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: BrandColors.onSurface)),
                          const SizedBox(height: 18),
                          Text('TOTAL PAID', style: GoogleFonts.workSans(fontSize: 11, color: BrandColors.onSurface.withValues(alpha: 0.55), letterSpacing: 1.4)),
                          const SizedBox(height: 3),
                          Text(r'$32.10', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: BrandColors.onSurface)),
                          const SizedBox(height: 10),
                          Align(alignment: Alignment.centerRight, child: Container(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8), decoration: BoxDecoration(color: BrandColors.onSurface, borderRadius: BorderRadius.circular(999)), child: Text('DETAILS', style: GoogleFonts.workSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 2)))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: const [BoxShadow(color: Color(0x14291714), blurRadius: 24, offset: Offset(0, 10))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                      child: Image.network('https://lh3.googleusercontent.com/aida-public/AB6AXuBgFWZniJDZ-v1ZFral1ezyCllv6oKIn8jUODTWQUXMgV6cviSAUZ199vv5BEz9F7N5S58fASA_yAIbTlRfkHOkYptwBPw8_H6i-t199S17l6_L1vOoAyE0nUgKmQKbIU3ZQY0jHSTL6USH7pflFcRuDUdsGDjLVvb5I48D5zYrKNgh6X4U6EkfUI_eHEbNjYW3smGZvwJMRqPUftGjcQ3kDSkvOUYH3pwXE24n_RKH9FyMve4t2RY3HiKp9k-JIsY_chhtf6dcd8w', height: 170, width: double.infinity, fit: BoxFit.cover),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('JUL 21, 2023', style: GoogleFonts.workSans(fontSize: 12, color: BrandColors.onSurface.withValues(alpha: 0.55), letterSpacing: 2.2)),
                          const SizedBox(height: 8),
                          Text('Battery Jumpstart', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: BrandColors.onSurface)),
                          const SizedBox(height: 4),
                          Text('Location: Shopping Mall Basement P2', style: GoogleFonts.workSans(fontSize: 13, color: BrandColors.onSurface.withValues(alpha: 0.72))),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('AMOUNT', style: GoogleFonts.workSans(fontSize: 11, color: BrandColors.onSurface.withValues(alpha: 0.55), letterSpacing: 1.4)),
                                  const SizedBox(height: 3),
                                  Text(r'$55.00', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: BrandColors.onSurface)),
                                ],
                              ),
                              const Spacer(),
                              const Icon(Icons.chevron_right_rounded, color: BrandColors.primary, size: 32),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text('LOAD MORE ARCHIVES', style: GoogleFonts.plusJakartaSans(color: BrandColors.primary, fontWeight: FontWeight.w800, letterSpacing: 1.8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryTopBar extends StatelessWidget {
  const _HistoryTopBar({required this.onNotificationsTap});

  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDZ-q2z5Ze2d6ySBBOUc3rwMuLv4ZNCNn4g0CocA-vC8yG-R_0Pi23-guhxA2kANBIx8pFZphmTQ-NIQyQqYhHmhw0X4_G99Sue6JfVgj6BOkamhN_GSN9Cz0Jcit0ZJ5OOdlkcjCRsMZo-idqmnwAQ3McVWa8-OgLHW8pSxz_z0iFj5YqQKPYukPfagEmMb5LVEe6ytmCG7PaRqtYp3CujqUbZsmepLVGxRgNuPIMI381h0Ltv9qlS0oFhMrYqRZ7RfYriFlUBoI4')),
        const SizedBox(width: 10),
        Text('History', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: BrandColors.onSurface)),
        const Spacer(),
        IconButton(onPressed: onNotificationsTap, icon: const Icon(Icons.notifications_rounded, color: BrandColors.onSurface)),
        Text('VehiSOS', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic, color: BrandColors.primary)),
      ],
    );
  }
}
