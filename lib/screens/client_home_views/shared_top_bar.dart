part of '../client_home_screen.dart';

class _BrandTopBar extends StatelessWidget {
  const _BrandTopBar({this.onMenuTap, this.onNotificationsTap});

  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationsTap;

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
            onPressed: onNotificationsTap,
            icon: const Icon(Icons.notifications_rounded, color: BrandColors.primary),
          ),
        ],
      ),
    );
  }
}
