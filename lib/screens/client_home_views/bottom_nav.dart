part of '../client_home_screen.dart';

class _ClientBottomNav extends StatelessWidget {
  const _ClientBottomNav({required this.currentIndex, required this.onChanged});

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      decoration: const BoxDecoration(
        color: Color(0xF5F5F5F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Color(0x14291714), blurRadius: 30, offset: Offset(0, -8)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 18),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _NavItem(icon: Icons.ac_unit_rounded, label: 'SOS', active: currentIndex == 0, onTap: () => onChanged(0)),
            _NavItem(icon: Icons.assignment_turned_in_rounded, label: 'STATUS', active: currentIndex == 1, onTap: () => onChanged(1)),
            _NavItem(icon: Icons.person_rounded, label: 'PROFILE', active: currentIndex == 2, onTap: () => onChanged(2)),
            _NavItem(icon: Icons.directions_car_rounded, label: 'GARAGE', active: currentIndex == 3, onTap: () => onChanged(3)),
            _NavItem(icon: Icons.history_rounded, label: 'HISTORY', active: currentIndex == 4, onTap: () => onChanged(4)),
            _NavItem(icon: Icons.payments_rounded, label: 'PAYMENTS', active: currentIndex == 5, onTap: () => onChanged(5)),
          ],
        ),
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
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: EdgeInsets.symmetric(horizontal: active ? 16 : 10, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF8EAE8) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: active
              ? const [
                  BoxShadow(color: Color(0x1ABB000E), blurRadius: 12, offset: Offset(0, 6)),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? BrandColors.primary : const Color(0xFF7E7A88), size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.workSans(
                color: active ? BrandColors.primary : const Color(0xFF7E7A88),
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
