part of '../client_home_screen.dart';

typedef OnEditCard = Future<void> Function({
  required int cardId,
  required ClientPaymentCard updatedCard,
});

typedef OnDeleteCard = Future<void> Function({
  required int cardId,
  required ClientPaymentCard card,
});

class PaymentsTab extends StatelessWidget {
  const PaymentsTab({
    super.key,
    required this.onOpenNotifications,
    required this.cards,
    required this.assignedWorkshop,
    required this.onAddCard,
    this.onEditCard,
    this.onDeleteCard,
    required this.onPay,
  });

  final VoidCallback onOpenNotifications;
  final List<ClientPaymentCard> cards;
  final WorkshopSuggestion? assignedWorkshop;
  final ValueChanged<ClientPaymentCard> onAddCard;
  final OnEditCard? onEditCard;
  final OnDeleteCard? onDeleteCard;
  final void Function({
    required ClientPaymentCard card,
    required double amount,
    required String concept,
  }) onPay;

  Future<void> _openAddCardDialog(BuildContext context) async {
    final holderController = TextEditingController();
    final numberController = TextEditingController();
    final monthController = TextEditingController();
    final yearController = TextEditingController();

    final card = await showDialog<ClientPaymentCard>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Agregar tarjeta',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: holderController,
                  decoration: const InputDecoration(labelText: 'Titular'),
                ),
                TextField(
                  controller: numberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Numero de tarjeta'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: monthController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Mes MM'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: yearController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Ano YY'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final holder = holderController.text.trim().toUpperCase();
                final digits = numberController.text.replaceAll(RegExp(r'\D'), '');
                final month = int.tryParse(monthController.text.trim());
                final year = int.tryParse(yearController.text.trim());
                if (holder.isEmpty || digits.length < 16 || month == null || year == null) {
                  return;
                }

                final brand = digits.startsWith('4')
                    ? 'VISA'
                    : (digits.startsWith('5') ? 'MASTERCARD' : 'CARD');
                Navigator.of(dialogContext).pop(
                  ClientPaymentCard(
                    holder: holder,
                    last4: digits.substring(digits.length - 4),
                    expMonth: month.clamp(1, 12),
                    expYear: year,
                    brand: brand,
                  ),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (!context.mounted || card == null) {
      return;
    }

    onAddCard(card);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tarjeta ${card.brand} agregada.'),
        backgroundColor: BrandColors.primary,
      ),
    );
  }

  Future<void> _openEditCardDialog(BuildContext context, ClientPaymentCard card, int index) async {
    final holderController = TextEditingController(text: card.holder);
    final cardNumberController = TextEditingController(text: '**** **** **** ${card.last4}');
    final monthController = TextEditingController(text: card.expMonth.toString().padLeft(2, '0'));
    final yearController = TextEditingController(text: card.expYear.toString());

    final updated = await showDialog<ClientPaymentCard>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Editar tarjeta',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: holderController,
                  decoration: const InputDecoration(labelText: 'Titular'),
                ),
                TextField(
                  enabled: false,
                  controller: cardNumberController,
                  decoration: const InputDecoration(labelText: 'Número de tarjeta'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: monthController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Mes MM'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: yearController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Año YY'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final holder = holderController.text.trim().toUpperCase();
                final month = int.tryParse(monthController.text.trim());
                final year = int.tryParse(yearController.text.trim());
                if (holder.isEmpty || month == null || year == null) {
                  return;
                }

                Navigator.of(dialogContext).pop(
                  ClientPaymentCard(
                    holder: holder,
                    last4: card.last4,
                    expMonth: month.clamp(1, 12),
                    expYear: year,
                    brand: card.brand,
                  ),
                );
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );

    if (!context.mounted || updated == null) {
      return;
    }

    onEditCard?.call(cardId: card.id, updatedCard: updated);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tarjeta ${updated.brand} actualizada.'),
        backgroundColor: BrandColors.primary,
      ),
    );
  }

  Future<void> _openPayDialog(BuildContext context) async {
    if (cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero agrega una tarjeta para pagar.')),
      );
      return;
    }

    final amountController = TextEditingController(text: '120.00');
    final conceptController = TextEditingController(
      text: assignedWorkshop == null
          ? 'Servicio de asistencia'
          : 'Servicio ${assignedWorkshop!.name}',
    );
    ClientPaymentCard selectedCard = cards.first;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: Text(
                'Realizar pago',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<ClientPaymentCard>(
                      initialValue: selectedCard,
                      decoration: const InputDecoration(labelText: 'Tarjeta'),
                      items: cards
                          .map(
                            (card) => DropdownMenuItem<ClientPaymentCard>(
                              value: card,
                              child: Text('${card.brand} **** ${card.last4}'),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value != null) {
                          setLocalState(() => selectedCard = value);
                        }
                      },
                    ),
                    TextField(
                      controller: conceptController,
                      decoration: const InputDecoration(labelText: 'Concepto'),
                    ),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Monto'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text.trim());
                    if (amount == null || amount <= 0) {
                      return;
                    }
                    onPay(
                      card: selectedCard,
                      amount: amount,
                      concept: conceptController.text.trim(),
                    );
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: const Text('Pagar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (!context.mounted || confirmed != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pago procesado correctamente.'),
        backgroundColor: BrandColors.primary,
      ),
    );
  }

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
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: BrandColors.ctaGradient,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pagos del cliente',
                      style: GoogleFonts.workSans(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      assignedWorkshop == null
                          ? 'Sin taller asignado aun'
                          : 'Taller actual: ${assignedWorkshop!.name}',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if ((assignedWorkshop?.phoneNumber ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Telefono: ${assignedWorkshop!.phoneNumber}',
                        style: GoogleFonts.workSans(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tarjetas',
                                  style: GoogleFonts.workSans(
                                    color: BrandColors.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${cards.length}',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: BrandColors.primary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _openPayDialog(context),
                            child: Container(
                              height: 94,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
                              ),
                              child: Text(
                                'PAGAR',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Metodos guardados',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _openAddCardDialog(context),
                    child: Text(
                      '+ AGREGAR TARJETA',
                      style: GoogleFonts.workSans(
                        color: BrandColors.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              if (cards.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDECE9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'No tienes tarjetas registradas.',
                    style: GoogleFonts.workSans(fontSize: 14),
                  ),
                ),
              ...cards.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final card = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDECE9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF2D6D1)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _CardLogoBox(
                              color: card.brand == 'VISA' ? const Color(0xFF1A4C8F) : const Color(0xFF1A1A1A),
                              label: card.brand == 'MASTERCARD' ? 'mc' : card.brand,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    card.holder,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      color: BrandColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '•••• •••• •••• ${card.last4} • Exp ${card.expiryLabel}',
                                    style: GoogleFonts.workSans(
                                      color: BrandColors.onSurface.withValues(alpha: 0.72),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _openEditCardDialog(context, card, index),
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text('Editar'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  showDialog<void>(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text('Eliminar tarjeta'),
                                      content: Text('¿Eliminar ${card.brand} **** ${card.last4}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(dialogContext).pop(),
                                          child: const Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(dialogContext).pop();
                                            onDeleteCard?.call(cardId: card.id, card: card);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red.shade500,
                                          ),
                                          child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.delete, size: 16),
                                label: const Text('Eliminar'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
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
        const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBE8CJsUkjYhZkdkSSVqrKBwKO-rAlsPVlNBfuEpA73oNjrVv_wKwZOnKwYtzvOLpJtzgQQxR-lG4QRrOrsrXd9KyWKtvVj0pzS2_XtmCTrXVlDcJCNCf1rKgWnXDBhfWJsMPnPSAzRiWTneNA7EuXjjY1QGBFHChnfo4Jx_QtaSgcyvxUMuhStGVSu_w4cPp3TirInbOsH0f72m0DAXEsJJJo68j9D0ekhnn8dIG1QyJ0O8WvTGrWkS6q1fftt4vT8fIR_thsHE5E',
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Payments',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: BrandColors.onSurface,
          ),
        ),
        const Spacer(),
        Text(
          'VehiSOS',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            color: BrandColors.primary,
          ),
        ),
        IconButton(
          onPressed: onNotificationsTap,
          icon: const Icon(Icons.notifications_rounded, color: BrandColors.onSurface),
        ),
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
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}
