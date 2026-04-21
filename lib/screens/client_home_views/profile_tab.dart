part of '../client_home_screen.dart';

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.user, required this.onEditProfile, required this.onLogout, required this.onOpenNotifications});

  final VehiSosUser user;
  final VoidCallback onEditProfile;
  final VoidCallback onLogout;
  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BrandTopBar(onNotificationsTap: onOpenNotifications),
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
