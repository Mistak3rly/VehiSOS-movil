part of '../client_home_screen.dart';

class _SosReportTab extends StatefulWidget {
  const _SosReportTab({
    required this.onBack,
    required this.onOpenNotifications,
    required this.vehicles,
    required this.incidentsApi,
    required this.onIncidenteCreado,
  });

  final VoidCallback onBack;
  final VoidCallback onOpenNotifications;
  final List<ClientVehicle> vehicles;
  final VehiSosIncidentsApi incidentsApi;
  final void Function(int incidenteId) onIncidenteCreado;

  @override
  State<_SosReportTab> createState() => _SosReportTabState();
}

class _SosReportTabState extends State<_SosReportTab> {
  int _step = 0; // 0=tipo, 1=ubicación, 2=detalles
  int _selectedType = -1;
  bool _requiereGrua = false;
  bool _detectingLocation = false;
  bool _sending = false;

  double _lat = -17.7833;
  double _lng = -63.1821;
  String _direccion = '';
  int? _selectedVehicleIndex;

  final _descripcionController = TextEditingController();

  static const _tiposEmergencia = [
    (icon: Icons.tire_repair_rounded, title: 'Llanta\npinchada', key: 'llanta_pinchada'),
    (icon: Icons.car_repair_rounded, title: 'Falla de\nmotor', key: 'falla_motor'),
    (icon: Icons.car_crash_rounded, title: 'Accidente', key: 'accidente'),
    (icon: Icons.local_gas_station_rounded, title: 'Sin\ncombustible', key: 'sin_combustible'),
    (icon: Icons.battery_alert_rounded, title: 'Batería\ndescargada', key: 'bateria'),
    (icon: Icons.warning_rounded, title: 'Otro\nproblema', key: 'otro'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.vehicles.isNotEmpty) _selectedVehicleIndex = 0;
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _detectarUbicacion() async {
    setState(() => _detectingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('El servicio de ubicación está desactivado.');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Permiso de ubicación denegado.');
          return;
        }
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      if (!mounted) return;
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _direccion = 'Lat: ${pos.latitude.toStringAsFixed(5)}, Lng: ${pos.longitude.toStringAsFixed(5)}';
      });
    } catch (e) {
      _showError('No se pudo obtener la ubicación: $e');
    } finally {
      if (mounted) setState(() => _detectingLocation = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _enviarReporte() async {
    if (_selectedVehicleIndex == null || widget.vehicles.isEmpty) {
      _showError('Selecciona un vehículo para el reporte.');
      return;
    }
    if (_selectedType < 0) {
      _showError('Selecciona el tipo de emergencia.');
      return;
    }

    final vehicle = widget.vehicles[_selectedVehicleIndex!];
    if (vehicle.id == 0) {
      _showError('El vehículo seleccionado no está sincronizado con el servidor.');
      return;
    }

    setState(() => _sending = true);
    try {
      final tipo = _tiposEmergencia[_selectedType];
      final titulo = '${tipo.title.replaceAll('\n', ' ')} · ${vehicle.plate}';
      final descripcion = _descripcionController.text.trim();

      final incidente = await widget.incidentsApi.createIncidente(
        idVehiculo: vehicle.id,
        titulo: titulo,
        latitud: _lat,
        longitud: _lng,
        descripcionTexto: descripcion.isEmpty ? null : descripcion,
        direccionTextual: _direccion.isEmpty ? null : _direccion,
        requiereGrua: _requiereGrua,
      );

      if (!mounted) return;
      widget.onIncidenteCreado(incidente.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incidente ${incidente.codigoIncidente} creado. Un operador te contactará pronto.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
      widget.onBack();
    } catch (e) {
      if (!mounted) return;
      _showError('Error al enviar reporte: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BrandTopBar(onMenuTap: widget.onBack, onNotificationsTap: widget.onOpenNotifications),
          const SizedBox(height: 24),
          // Progreso
          Row(
            children: List.generate(3, (i) => Expanded(
              child: Container(
                height: 6,
                margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
                decoration: BoxDecoration(
                  color: i <= _step ? BrandColors.primary : const Color(0xFFF1CDC8),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            )),
          ),
          const SizedBox(height: 28),

          // PASO 0: Tipo de emergencia
          _buildSeccion(
            paso: 'PASO 01',
            titulo: '¿Qué emergencia\ntiene tu',
            tituloResaltado: 'vehículo?',
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 0.92,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              children: List.generate(_tiposEmergencia.length, (i) {
                final t = _tiposEmergencia[i];
                final active = _selectedType == i;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedType = i;
                    if (_step == 0) _step = 1;
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: active ? Colors.white : const Color(0xFFFDEDEB),
                      borderRadius: BorderRadius.circular(22),
                      border: active ? Border.all(color: BrandColors.primary, width: 2) : null,
                      boxShadow: active ? [const BoxShadow(color: Color(0x22BB000E), blurRadius: 16)] : null,
                    ),
                    child: Stack(
                      children: [
                        if (active)
                          Positioned(
                            left: -18, top: 0, bottom: 0,
                            child: Container(
                              width: 6,
                              decoration: BoxDecoration(
                                color: BrandColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(t.icon,
                                color: active ? BrandColors.primary : BrandColors.onSurface.withValues(alpha: 0.78),
                                size: 34),
                            const Spacer(),
                            Text(t.title,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14, fontWeight: FontWeight.w700,
                                    color: BrandColors.onSurface)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 28),

          // PASO 1: Ubicación y vehículo
          _buildSeccion(
            paso: 'PASO 02',
            titulo: 'Ubicación y',
            tituloResaltado: 'vehículo',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selector de vehículo
                if (widget.vehicles.isNotEmpty) ...[
                  Text('Vehículo con el problema:',
                      style: GoogleFonts.workSans(fontSize: 13, fontWeight: FontWeight.w600,
                          color: BrandColors.onSurface.withValues(alpha: 0.7))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7D8D3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedVehicleIndex,
                        isExpanded: true,
                        items: widget.vehicles.asMap().entries.map((e) =>
                            DropdownMenuItem(
                              value: e.key,
                              child: Text('${e.value.model} · ${e.value.plate}',
                                  style: GoogleFonts.workSans(fontSize: 14)),
                            )).toList(),
                        onChanged: (v) => setState(() => _selectedVehicleIndex = v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('No tienes vehículos registrados. Agrega uno en "My Garage" primero.',
                        style: GoogleFonts.workSans(fontSize: 13, color: Colors.orange.shade800)),
                  ),
                  const SizedBox(height: 14),
                ],
                // Ubicación
                GestureDetector(
                  onTap: _detectingLocation ? null : _detectarUbicacion,
                  child: Container(
                    height: 68,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7D8D3),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: BrandColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _direccion.isEmpty ? 'Toca para detectar ubicación GPS' : _direccion,
                            style: GoogleFonts.workSans(
                                fontSize: 14,
                                color: _direccion.isEmpty
                                    ? BrandColors.onSurface.withValues(alpha: 0.45)
                                    : BrandColors.onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_detectingLocation)
                          const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: BrandColors.primary))
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.72),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text('DETECTAR',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12, color: BrandColors.primary,
                                    fontWeight: FontWeight.w800)),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // PASO 2: Descripción y detalles
          _buildSeccion(
            paso: 'PASO 03',
            titulo: 'Descripción y',
            tituloResaltado: 'detalles',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF1CDC8)),
                  ),
                  child: TextField(
                    controller: _descripcionController,
                    maxLines: 4,
                    style: GoogleFonts.workSans(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Describe el problema con más detalle (opcional)...',
                      hintStyle: GoogleFonts.workSans(
                          color: BrandColors.onSurface.withValues(alpha: 0.4)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF1CDC8)),
                  ),
                  child: SwitchListTile.adaptive(
                    value: _requiereGrua,
                    onChanged: (v) => setState(() => _requiereGrua = v),
                    title: Text('Requiere grúa',
                        style: GoogleFonts.workSans(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text('El vehículo no puede moverse por sus propios medios',
                        style: GoogleFonts.workSans(fontSize: 12,
                            color: BrandColors.onSurface.withValues(alpha: 0.6))),
                    activeTrackColor: BrandColors.primary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Botón enviar
          GestureDetector(
            onTap: (_sending || widget.vehicles.isEmpty) ? null : _enviarReporte,
            child: Container(
              height: 84,
              decoration: BoxDecoration(
                gradient: (_sending || widget.vehicles.isEmpty)
                    ? const LinearGradient(colors: [Color(0xFFCCCCCC), Color(0xFFAAAAAA)])
                    : BrandColors.ctaGradient,
                borderRadius: BorderRadius.circular(26),
                boxShadow: (_sending || widget.vehicles.isEmpty) ? null : const [
                  BoxShadow(color: Color(0x30BB000E), blurRadius: 28, offset: Offset(0, 12)),
                ],
              ),
              child: Center(
                child: _sending
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('ENVIAR REPORTE',
                              style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white, fontSize: 18,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(width: 10),
                          const Icon(Icons.bolt_rounded, color: Colors.white),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccion({
    required String paso,
    required String titulo,
    required String tituloResaltado,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(paso,
            style: GoogleFonts.workSans(
                fontSize: 11, color: BrandColors.primary,
                letterSpacing: 2, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: GoogleFonts.plusJakartaSans(
                fontSize: 26, fontWeight: FontWeight.w800,
                color: BrandColors.onSurface),
            children: [
              TextSpan(text: '$titulo\n'),
              TextSpan(
                text: tituloResaltado,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 26, fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    color: BrandColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        child,
      ],
    );
  }
}

