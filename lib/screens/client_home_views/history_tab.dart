part of '../client_home_screen.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({
    super.key,
    required this.onOpenNotifications,
    required this.history,
    this.onLoadMore,
    this.onFilterByCategory,
    this.currentFilter = 'todos',
    this.hasMorePages = false,
  });

  final VoidCallback onOpenNotifications;
  final List<ClientHistoryEntry> history;
  final Future<void> Function()? onLoadMore;
  final Future<void> Function(String category)? onFilterByCategory;
  final String currentFilter;
  final bool hasMorePages;

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (widget.hasMorePages) {
        widget.onLoadMore?.call();
      }
    }
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'payment':
      case 'pagos':
        return Icons.payments_rounded;
      case 'garage':
        return Icons.directions_car_filled_rounded;
      case 'workshop':
      case 'talleres':
        return Icons.support_agent_rounded;
      case 'chat':
        return Icons.chat_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  Color _accentForCategory(String category) {
    switch (category) {
      case 'payment':
      case 'pagos':
        return const Color(0xFF0D8F43);
      case 'garage':
        return const Color(0xFF1457A7);
      case 'workshop':
      case 'talleres':
        return BrandColors.primary;
      case 'chat':
        return const Color(0xFF7A4B1F);
      default:
        return BrandColors.onSurface;
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year • $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['todos', 'pagos', 'garage', 'talleres', 'chat'];
    final categoryLabels = {
      'todos': 'Todos',
      'pagos': 'Pagos',
      'garage': 'Garage',
      'talleres': 'Talleres',
      'chat': 'Chat',
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3F2),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: _HistoryTopBar(onNotificationsTap: widget.onOpenNotifications),
                ),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Historial del cliente',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: BrandColors.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Aqui se guardan talleres contactados, pagos y acciones en la app.',
                    style: GoogleFonts.workSans(
                      fontSize: 14,
                      color: BrandColors.onSurface.withValues(alpha: 0.72),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(color: Color(0x14291714), blurRadius: 24, offset: Offset(0, 10)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total de eventos',
                                style: GoogleFonts.workSans(
                                  color: BrandColors.onSurface.withValues(alpha: 0.65),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.history.length}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: BrandColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDECE9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.timeline_rounded, color: BrandColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Filtrar por tipo',
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: BrandColors.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: categories.map((cat) {
                      final isSelected = widget.currentFilter == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(categoryLabels[cat] ?? cat),
                          onSelected: (_) {
                            widget.onFilterByCategory?.call(cat);
                          },
                          backgroundColor: Colors.white,
                          selectedColor: BrandColors.primary.withValues(alpha: 0.2),
                          side: BorderSide(
                            color: isSelected ? BrandColors.primary : const Color(0xFFE5D5CF),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),
              ]),
            ),
            if (widget.history.isEmpty)
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDECE9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Todavia no hay movimientos para mostrar.',
                        style: GoogleFonts.workSans(fontSize: 14),
                      ),
                    ),
                  ),
                ]),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == widget.history.length) {
                      if (widget.hasMorePages) {
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: CircularProgressIndicator(color: BrandColors.primary),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }

                    final entry = widget.history[index];
                    final accent = _accentForCategory(entry.category);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFECDCD8)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 8,
                              height: 116,
                              decoration: BoxDecoration(
                                color: accent,
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: accent.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(_iconForCategory(entry.category), color: accent),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            entry.title,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: BrandColors.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            entry.description,
                                            style: GoogleFonts.workSans(
                                              fontSize: 13,
                                              height: 1.35,
                                              color: BrandColors.onSurface.withValues(alpha: 0.78),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Text(
                                                _formatDate(entry.timestamp),
                                                style: GoogleFonts.workSans(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: BrandColors.onSurface.withValues(alpha: 0.58),
                                                ),
                                              ),
                                              const Spacer(),
                                              if (entry.amount != null)
                                                Text(
                                                  r'$' + entry.amount!.toStringAsFixed(2),
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w800,
                                                    color: const Color(0xFF0D8F43),
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
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: widget.history.length + (widget.hasMorePages ? 1 : 0),
                ),
              ),
            SliverPadding(padding: const EdgeInsets.only(bottom: 128)),
          ],
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
        const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDZ-q2z5Ze2d6ySBBOUc3rwMuLv4ZNCNn4g0CocA-vC8yG-R_0Pi23-guhxA2kANBIx8pFZphmTQ-NIQyQqYhHmhw0X4_G99Sue6JfVgj6BOkamhN_GSN9Cz0Jcit0ZJ5OOdlkcjCRsMZo-idqmnwAQ3McVWa8-OgLHW8pSxz_z0iFj5YqQKPYukPfagEmMb5LVEe6ytmCG7PaRqtYp3CujqUbZsmepLVGxRgNuPIMI381h0Ltv9qlS0oFhMrYqRZ7RfYriFlUBoI4',
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'History',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: BrandColors.onSurface,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: onNotificationsTap,
          icon: const Icon(Icons.notifications_rounded, color: BrandColors.onSurface),
        ),
        Text(
          'VehiSOS',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            color: BrandColors.primary,
          ),
        ),
      ],
    );
  }
}
