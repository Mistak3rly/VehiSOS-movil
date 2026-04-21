part of '../client_home_screen.dart';

class _ProfileTab extends StatefulWidget {
  const _ProfileTab({required this.user, required this.onEditProfile, required this.onLogout, required this.onOpenNotifications});

  final VehiSosUser user;
  final VoidCallback onEditProfile;
  final VoidCallback onLogout;
  final VoidCallback onOpenNotifications;

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  static const List<IconData> _maleAvatars = <IconData>[
    Icons.face_6_rounded,
    Icons.person_rounded,
    Icons.sports_motorsports_rounded,
  ];
  static const List<IconData> _femaleAvatars = <IconData>[
    Icons.face_4_rounded,
    Icons.person_2_rounded,
    Icons.support_agent_rounded,
  ];
  static const List<IconData> _neutralAvatars = <IconData>[
    Icons.account_circle_rounded,
    Icons.person_outline_rounded,
    Icons.emoji_people_rounded,
  ];

  String _selectedGender = 'neutral';
  int _selectedAvatarIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAvatarPreferences();
  }

  Future<void> _loadAvatarPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final gender = prefs.getString(_genderKey) ?? _selectedGender;
    final avatarIndex = prefs.getInt(_avatarKey) ?? _selectedAvatarIndex;
    final clampedIndex = avatarIndex.clamp(0, _avatarsForGender(gender).length - 1);

    if (!mounted) {
      return;
    }
    setState(() {
      _selectedGender = gender;
      _selectedAvatarIndex = clampedIndex;
    });
  }

  Future<void> _saveAvatarPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_genderKey, _selectedGender);
    await prefs.setInt(_avatarKey, _selectedAvatarIndex);
  }

  String get _genderKey => 'vehisos_profile_gender_${widget.user.id}';
  String get _avatarKey => 'vehisos_profile_avatar_${widget.user.id}';

  List<IconData> _avatarsForGender(String gender) {
    switch (gender) {
      case 'male':
        return _maleAvatars;
      case 'female':
        return _femaleAvatars;
      default:
        return _neutralAvatars;
    }
  }

  IconData get _currentAvatarIcon {
    final avatars = _avatarsForGender(_selectedGender);
    return avatars[_selectedAvatarIndex];
  }

  Future<void> _openAvatarEditor() async {
    var tempGender = _selectedGender;
    var tempAvatarIndex = _selectedAvatarIndex;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFFDF1EF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final avatarOptions = _avatarsForGender(tempGender);
            if (tempAvatarIndex >= avatarOptions.length) {
              tempAvatarIndex = 0;
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Editar avatar',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: BrandColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Elige genero y estilo de avatar para tu perfil.',
                      style: GoogleFonts.workSans(
                        fontSize: 14,
                        color: BrandColors.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _AvatarGenderChip(
                          label: 'Masculino',
                          selected: tempGender == 'male',
                          onTap: () => setModalState(() {
                            tempGender = 'male';
                            tempAvatarIndex = 0;
                          }),
                        ),
                        _AvatarGenderChip(
                          label: 'Femenino',
                          selected: tempGender == 'female',
                          onTap: () => setModalState(() {
                            tempGender = 'female';
                            tempAvatarIndex = 0;
                          }),
                        ),
                        _AvatarGenderChip(
                          label: 'Otro',
                          selected: tempGender == 'neutral',
                          onTap: () => setModalState(() {
                            tempGender = 'neutral';
                            tempAvatarIndex = 0;
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: avatarOptions.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final selected = tempAvatarIndex == index;
                        return GestureDetector(
                          onTap: () => setModalState(() => tempAvatarIndex = index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: selected ? const Color(0xFFFFE1DD) : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: selected ? BrandColors.primary : const Color(0xFFFFC9C2),
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Icon(
                              avatarOptions[index],
                              size: 42,
                              color: selected ? BrandColors.primary : BrandColors.onSurface,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    GradientActionButton(
                      label: 'Guardar Avatar',
                      onTap: () async {
                        setState(() {
                          _selectedGender = tempGender;
                          _selectedAvatarIndex = tempAvatarIndex;
                        });
                        await _saveAvatarPreferences();
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BrandTopBar(onNotificationsTap: widget.onOpenNotifications),
          const SizedBox(height: 20),
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 116,
                    height: 116,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFFE2DE), Color(0xFFFFF4F2)],
                      ),
                      border: Border.all(color: const Color(0xFFFFC9C2), width: 1.2),
                    ),
                    child: Icon(
                      _currentAvatarIcon,
                      size: 68,
                      color: BrandColors.primary,
                    ),
                  ),
                  Positioned(
                    right: -3,
                    bottom: -3,
                    child: GestureDetector(
                      onTap: _openAvatarEditor,
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
                      widget.user.displayName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 54 * 0.6,
                        color: BrandColors.onSurface,
                        fontWeight: FontWeight.w800,
                        height: 1.03,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.user.correo,
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
                _ProfileMenuItem(icon: Icons.person_rounded, label: 'Manage Profile', onTap: widget.onEditProfile),
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
            onTap: widget.onLogout,
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

class _AvatarGenderChip extends StatelessWidget {
  const _AvatarGenderChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? BrandColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? BrandColors.primary : const Color(0xFFFFC9C2)),
        ),
        child: Text(
          label,
          style: GoogleFonts.workSans(
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : BrandColors.onSurface,
          ),
        ),
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
