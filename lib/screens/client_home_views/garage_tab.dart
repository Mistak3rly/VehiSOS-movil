part of '../client_home_screen.dart';

typedef OnEditVehicle = Future<void> Function({
  required int vehicleId,
  required ClientVehicle updatedVehicle,
});

typedef OnDeleteVehicle = Future<void> Function({
  required int vehicleId,
  required ClientVehicle vehicle,
});

class GarageTab extends StatelessWidget {
  const GarageTab({
    super.key,
    required this.onOpenNotifications,
    required this.vehicles,
    required this.onAddVehicle,
    this.onEditVehicle,
    this.onDeleteVehicle,
  });

  final VoidCallback onOpenNotifications;
  final List<ClientVehicle> vehicles;
  final ValueChanged<ClientVehicle> onAddVehicle;
  final OnEditVehicle? onEditVehicle;
  final OnDeleteVehicle? onDeleteVehicle;

  Future<void> _openAddVehicleDialog(BuildContext context) async {
    final modelController = TextEditingController();
    final nicknameController = TextEditingController();
    final plateController = TextEditingController();
    final colorController = TextEditingController();
    bool isPrimary = vehicles.isEmpty;

    final result = await showDialog<ClientVehicle>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: Text(
                'Agregar auto',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: modelController,
                      decoration: const InputDecoration(labelText: 'Modelo'),
                    ),
                    TextField(
                      controller: nicknameController,
                      decoration: const InputDecoration(labelText: 'Alias (opcional)'),
                    ),
                    TextField(
                      controller: plateController,
                      decoration: const InputDecoration(labelText: 'Placa'),
                    ),
                    TextField(
                      controller: colorController,
                      decoration: const InputDecoration(labelText: 'Color'),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile.adaptive(
                      value: isPrimary,
                      title: const Text('Marcar como principal'),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) => setLocalState(() => isPrimary = value),
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
                    final model = modelController.text.trim();
                    final plate = plateController.text.trim().toUpperCase();
                    final color = colorController.text.trim();
                    final nickname = nicknameController.text.trim();
                    if (model.isEmpty || plate.isEmpty || color.isEmpty) {
                      return;
                    }

                    Navigator.of(dialogContext).pop(
                      ClientVehicle(
                        nickname: nickname.isEmpty ? model : nickname,
                        plate: plate,
                        model: model,
                        color: color,
                        isPrimary: isPrimary,
                      ),
                    );
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (!context.mounted || result == null) {
      return;
    }

    onAddVehicle(result);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${result.model} agregado correctamente.'),
        backgroundColor: BrandColors.primary,
      ),
    );
  }

  Future<void> _openEditVehicleDialog(BuildContext context, ClientVehicle vehicle, int index) async {
    final modelController = TextEditingController(text: vehicle.model);
    final nicknameController = TextEditingController(text: vehicle.nickname);
    final plateController = TextEditingController(text: vehicle.plate);
    final colorController = TextEditingController(text: vehicle.color);
    bool isPrimary = vehicle.isPrimary;

    final result = await showDialog<ClientVehicle>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: Text(
                'Editar auto',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: modelController,
                      decoration: const InputDecoration(labelText: 'Modelo'),
                    ),
                    TextField(
                      controller: nicknameController,
                      decoration: const InputDecoration(labelText: 'Alias'),
                    ),
                    TextField(
                      controller: plateController,
                      decoration: const InputDecoration(labelText: 'Placa'),
                    ),
                    TextField(
                      controller: colorController,
                      decoration: const InputDecoration(labelText: 'Color'),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile.adaptive(
                      value: isPrimary,
                      title: const Text('Marcar como principal'),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) => setLocalState(() => isPrimary = value),
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
                    final model = modelController.text.trim();
                    final plate = plateController.text.trim().toUpperCase();
                    final color = colorController.text.trim();
                    final nickname = nicknameController.text.trim();
                    if (model.isEmpty || plate.isEmpty || color.isEmpty) {
                      return;
                    }

                    Navigator.of(dialogContext).pop(
                      ClientVehicle(
                        nickname: nickname,
                        plate: plate,
                        model: model,
                        color: color,
                        isPrimary: isPrimary,
                      ),
                    );
                  },
                  child: const Text('Actualizar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (!context.mounted || result == null) {
      return;
    }

    onEditVehicle?.call(vehicleId: index, updatedVehicle: result);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${result.model} actualizado correctamente.'),
        backgroundColor: BrandColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = vehicles.where((item) => item.isPrimary).toList(growable: false);
    final featured = primary.isNotEmpty ? primary.first : (vehicles.isNotEmpty ? vehicles.first : null);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 128),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GarageTopBar(onNotificationsTap: onOpenNotifications),
              const SizedBox(height: 24),
              Text(
                'My Garage',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: BrandColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Administra los autos vinculados a tu cuenta.',
                style: GoogleFonts.workSans(
                  color: BrandColors.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(color: Color(0x14291714), blurRadius: 22, offset: Offset(0, 10)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vehiculos registrados',
                            style: GoogleFonts.workSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                              color: BrandColors.onSurface.withValues(alpha: 0.65),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${vehicles.length}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: BrandColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vehiculo principal',
                            style: GoogleFonts.workSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                              color: BrandColors.onSurface.withValues(alpha: 0.65),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            featured?.model ?? 'Sin definir',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: BrandColors.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => _openAddVehicleDialog(context),
                child: Container(
                  height: 92,
                  decoration: BoxDecoration(
                    gradient: BrandColors.ctaGradient,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_circle_rounded, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(
                        'Agregar Vehiculo',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (vehicles.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDECE9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Aun no agregaste vehiculos. Usa "Agregar Vehiculo" para comenzar.',
                    style: GoogleFonts.workSans(fontSize: 14, height: 1.4),
                  ),
                ),
              ...vehicles.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final vehicle = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: vehicle.isPrimary ? BrandColors.primary : const Color(0xFFEADBD7),
                        width: vehicle.isPrimary ? 1.8 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDECE9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.directions_car_filled_rounded, color: BrandColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          vehicle.model,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: BrandColors.onSurface,
                                          ),
                                        ),
                                      ),
                                      if (vehicle.isPrimary)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFDECE9),
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            'PRINCIPAL',
                                            style: GoogleFonts.workSans(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: BrandColors.primary,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${vehicle.nickname} • ${vehicle.plate} • ${vehicle.color}',
                                    style: GoogleFonts.workSans(
                                      fontSize: 13,
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
                                onPressed: () => _openEditVehicleDialog(context, vehicle, index),
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
                                      title: const Text('Eliminar vehículo'),
                                      content: Text('¿Eliminar ${vehicle.model}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(dialogContext).pop(),
                                          child: const Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(dialogContext).pop();
                                            onDeleteVehicle?.call(vehicleId: index, vehicle: vehicle);
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
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _GarageTopBar extends StatelessWidget {
  const _GarageTopBar({required this.onNotificationsTap});

  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuA7gVM1_LseHELYeojr93iNg_2VSuHkrZ0PsffjCjYRYJOEiBLl8pabFw2QsD_8_ZJmNBL6unPu9FV5QiC3s9v6WiL4FhmGw8u6TFq5D_gmeoJrkLiNMyJN3zRAdg6iD4p_kBjML0pY3nsbvhtPiuXPf2pCwwlmp2HyATjj7TP9oJwmOU2hBO4ai04GhLg3helEE0KyDm2hvlom1LlGdvGnyGALENUu9jkC_cBv-tjY5gPCCkDnBqH6cH3zboG22IDYQfi9chK2cL0',
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'VehiSOS',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            color: BrandColors.onSurface,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: onNotificationsTap,
          icon: const Icon(Icons.notifications_rounded, color: BrandColors.primary),
        ),
      ],
    );
  }
}
