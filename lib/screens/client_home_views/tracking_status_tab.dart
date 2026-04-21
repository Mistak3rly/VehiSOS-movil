part of '../client_home_screen.dart';

class _TrackingStatusTab extends StatelessWidget {
  const _TrackingStatusTab({required this.onOpenNotifications});

  final VoidCallback onOpenNotifications;

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
                      BoxShadow(
                        color: Color(0x0C291714),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
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
                      IconButton(
                        onPressed: onOpenNotifications,
                        icon: const Icon(Icons.notifications_rounded, color: Color(0xFF6E6A77)),
                      ),
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
                            Text(
                              'Live',
                              style: GoogleFonts.workSans(
                                fontSize: 36 * 0.52,
                                fontWeight: FontWeight.w700,
                                color: BrandColors.primary,
                              ),
                            ),
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
                                                Text(
                                                  '4.9 (124\nreviews)',
                                                  style: GoogleFonts.workSans(
                                                    fontSize: 16 * 1.1,
                                                    fontWeight: FontWeight.w700,
                                                    color: BrandColors.secondary,
                                                  ),
                                                ),
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
