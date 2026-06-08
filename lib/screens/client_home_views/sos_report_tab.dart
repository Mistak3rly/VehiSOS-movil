part of '../client_home_screen.dart';

class _SosReportTab extends StatefulWidget {
  const _SosReportTab({
    required this.onBack,
    required this.onOpenNotifications,
    required this.vehicles,
    required this.incidentsApi,
    required this.talleresApi,
    required this.onIncidenteCreado,
  });

  final VoidCallback onBack;
  final VoidCallback onOpenNotifications;
  final List<ClientVehicle> vehicles;
  final VehiSosIncidentsApi incidentsApi;
  final VehiSosTalleresApi talleresApi;
  final void Function(int incidenteId) onIncidenteCreado;

  @override
  State<_SosReportTab> createState() => _SosReportTabState();
}

class _SosReportTabState extends State<_SosReportTab> {
  // Paso actual: 0-tipo, 1-ubicación/vehículo, 2-detalles, 3-taller
  int _step = 0;
  int _selectedType = -1;
  bool _requiereGrua = false;
  bool _detectingLocation = false;
  bool _sending = false;

  double _lat = -17.7833;
  double _lng = -63.1821;
  String _direccion = '';
  int? _selectedVehicleIndex;

  // Talleres
  List<TallerDisponible> _talleres = const [];
  bool _loadingTalleres = false;
  String? _talleresError;
  TallerDisponible? _selectedTaller;

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

  void _goToStep(int step) {
    if (step == 3 && _talleres.isEmpty && _talleresError == null) {
      _cargarTalleres();
    }
    setState(() => _step = step);
  }

  Future<void> _cargarTalleres() async {
    setState(() {
      _loadingTalleres = true;
      _talleresError = null;
    });
    try {
      final talleres = await widget.talleresApi.getTalleresActivos();
      // Ordenar por distancia si tenemos GPS
      talleres.sort((TallerDisponible a, TallerDisponible b) =>
          a.distanciaKm(_lat, _lng).compareTo(b.distanciaKm(_lat, _lng)));
      if (!mounted) return;
      setState(() {
        _talleres = talleres;
        _loadingTalleres = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _talleresError = 'No se pudieron cargar los talleres: $e';
        _loadingTalleres = false;
      });
    }
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
        _direccion =
            'Lat: ${pos.latitude.toStringAsFixed(5)}, Lng: ${pos.longitude.toStringAsFixed(5)}';
        // Re-ordenar talleres si ya cargaron
        if (_talleres.isNotEmpty) {
          final sorted = <TallerDisponible>[..._talleres];
          sorted.sort((TallerDisponible a, TallerDisponible b) =>
              a.distanciaKm(_lat, _lng).compareTo(b.distanciaKm(_lat, _lng)));
          _talleres = sorted;
        }
      });
    } catch (e) {
      _showError('No se pudo obtener la ubicación: $e');
    } finally {
      if (mounted) setState(() => _detectingLocation = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
    if (_selectedTaller == null) {
      _showError('Debes seleccionar un taller antes de enviar.');
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
      final titulo =
          '${tipo.title.replaceAll('\n', ' ')} · ${vehicle.plate}';
      final descripcion = _descripcionController.text.trim();

      final incidente = await widget.incidentsApi.createIncidente(
        idVehiculo: vehicle.id,
        titulo: titulo,
        latitud: _lat,
        longitud: _lng,
        idTallerDestino: _selectedTaller!.id,
        descripcionTexto: descripcion.isEmpty ? null : descripcion,
        direccionTextual: _direccion.isEmpty ? null : _direccion,
        requiereGrua: _requiereGrua,
      );

      if (!mounted) return;
      widget.onIncidenteCreado(incidente.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ Incidente ${incidente.codigoIncidente} enviado a ${_selectedTaller!.nombre}. Te contactarán pronto.',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
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

  bool get _canProceedToStep1 => _selectedType >= 0;
  bool get _canProceedToStep2 => _selectedVehicleIndex != null;
  bool get _canProceedToStep3 => true;
  bool get _canSend =>
      _selectedTaller != null && _selectedVehicleIndex != null && _selectedType >= 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopBar(),
        _buildProgressBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepContent(),
                const SizedBox(height: 28),
                _buildNavigationButtons(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: _BrandTopBar(
        onMenuTap: widget.onBack,
        onNotificationsTap: widget.onOpenNotifications,
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: List.generate(4, (i) {
          final done = i < _step;
          final active = i == _step;
          return Expanded(
            child: Container(
              height: 6,
              margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
              decoration: BoxDecoration(
                color: done
                    ? BrandColors.primary.withValues(alpha: 0.5)
                    : active
                        ? BrandColors.primary
                        : const Color(0xFFF1CDC8),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _buildPaso1Tipo();
      case 1:
        return _buildPaso2Ubicacion();
      case 2:
        return _buildPaso3Detalles();
      case 3:
        return _buildPaso4Taller();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNavigationButtons() {
    if (_step < 3) {
      return Row(
        children: [
          if (_step > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _step--),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Atrás'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          if (_step > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _buildCTAButton(
              label: 'CONTINUAR',
              icon: Icons.arrow_forward_rounded,
              enabled: _step == 0
                  ? _canProceedToStep1
                  : _step == 1
                      ? _canProceedToStep2
                      : _canProceedToStep3,
              onTap: () => _goToStep(_step + 1),
            ),
          ),
        ],
      );
    }

    // Paso 4: Enviar
    return Column(
      children: [
        if (_selectedTaller != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: BrandColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: BrandColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: BrandColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Taller seleccionado',
                          style: GoogleFonts.workSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: BrandColors.primary,
                              letterSpacing: 0.8)),
                      Text(_selectedTaller!.nombre,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: BrandColors.onSurface)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _selectedTaller = null),
                  child: const Text('Cambiar',
                      style: TextStyle(color: BrandColors.primary)),
                ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _step = 2),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Atrás'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _buildCTAButton(
                label: _sending ? '' : 'ENVIAR REPORTE',
                icon: Icons.bolt_rounded,
                enabled: _canSend && !_sending,
                loading: _sending,
                onTap: _enviarReporte,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCTAButton({
    required String label,
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
    bool loading = false,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: enabled
              ? BrandColors.ctaGradient
              : const LinearGradient(
                  colors: [Color(0xFFCCCCCC), Color(0xFFAAAAAA)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: enabled
              ? const [
                  BoxShadow(
                      color: Color(0x30BB000E),
                      blurRadius: 20,
                      offset: Offset(0, 8))
                ]
              : null,
        ),
        child: Center(
          child: loading
              ? const CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label,
                        style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    Icon(icon, color: Colors.white, size: 20),
                  ],
                ),
        ),
      ),
    );
  }

  // ─── PASO 1: TIPO DE EMERGENCIA ───────────────────────────────────────────

  Widget _buildPaso1Tipo() {
    return _buildSeccion(
      paso: 'PASO 01',
      titulo: '¿Qué tipo de',
      tituloResaltado: 'emergencia?',
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
            onTap: () => setState(() => _selectedType = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: active ? Colors.white : const Color(0xFFFDEDEB),
                borderRadius: BorderRadius.circular(22),
                border: active
                    ? Border.all(color: BrandColors.primary, width: 2)
                    : null,
                boxShadow: active
                    ? const [
                        BoxShadow(
                            color: Color(0x22BB000E), blurRadius: 16)
                      ]
                    : null,
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
                          color: active
                              ? BrandColors.primary
                              : BrandColors.onSurface.withValues(alpha: 0.78),
                          size: 34),
                      const Spacer(),
                      Text(t.title,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: BrandColors.onSurface)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── PASO 2: UBICACIÓN Y VEHÍCULO ────────────────────────────────────────

  Widget _buildPaso2Ubicacion() {
    return _buildSeccion(
      paso: 'PASO 02',
      titulo: 'Ubicación y',
      tituloResaltado: 'vehículo',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehículo
          if (widget.vehicles.isNotEmpty) ...[
            Text('Vehículo afectado:',
                style: GoogleFonts.workSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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
                        child: Text(
                          '${e.value.model} · ${e.value.plate}',
                          style: GoogleFonts.workSans(fontSize: 14),
                        ),
                      )).toList(),
                  onChanged: (v) => setState(() => _selectedVehicleIndex = v),
                ),
              ),
            ),
          ] else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Sin vehículos registrados. Ve a "GARAGE" y agrega uno primero.',
                style: GoogleFonts.workSans(
                    fontSize: 13, color: Colors.orange.shade800),
              ),
            ),
          const SizedBox(height: 16),
          // Ubicación GPS
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
                  const Icon(Icons.location_on_rounded,
                      color: BrandColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _direccion.isEmpty
                          ? 'Toca para detectar tu ubicación GPS'
                          : _direccion,
                      style: GoogleFonts.workSans(
                          fontSize: 13,
                          color: _direccion.isEmpty
                              ? BrandColors.onSurface.withValues(alpha: 0.45)
                              : BrandColors.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_detectingLocation)
                    const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: BrandColors.primary))
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text('DETECTAR',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: BrandColors.primary,
                              fontWeight: FontWeight.w800)),
                    ),
                ],
              ),
            ),
          ),
          if (_direccion.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.green, size: 16),
                const SizedBox(width: 6),
                Text('Ubicación capturada correctamente',
                    style: GoogleFonts.workSans(
                        fontSize: 12, color: Colors.green.shade700)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── PASO 3: DETALLES ────────────────────────────────────────────────────

  Widget _buildPaso3Detalles() {
    return _buildSeccion(
      paso: 'PASO 03',
      titulo: 'Detalles',
      tituloResaltado: 'adicionales',
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
                hintText:
                    'Describe el problema con detalle (opcional)...',
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
              subtitle: Text(
                  'El vehículo no puede moverse por sus propios medios',
                  style: GoogleFonts.workSans(
                      fontSize: 12,
                      color:
                          BrandColors.onSurface.withValues(alpha: 0.6))),
              activeTrackColor: BrandColors.primary,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── PASO 4: SELECCIÓN DE TALLER ─────────────────────────────────────────

  Widget _buildPaso4Taller() {
    return _buildSeccion(
      paso: 'PASO 04',
      titulo: 'Elige un',
      tituloResaltado: 'taller cercano',
      child: _buildTallerBody(),
    );
  }

  Widget _buildTallerBody() {
    if (_loadingTalleres) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: BrandColors.primary),
              SizedBox(height: 16),
              Text('Buscando talleres disponibles...'),
            ],
          ),
        ),
      );
    }

    if (_talleresError != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(_talleresError!,
                style: GoogleFonts.workSans(color: Colors.red.shade700)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _cargarTalleres,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: BrandColors.primary,
                  foregroundColor: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_talleres.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFDECE9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Icon(Icons.store_mall_directory_rounded,
                size: 40, color: BrandColors.primary),
            const SizedBox(height: 12),
            Text('Sin talleres disponibles',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 6),
            Text('No hay talleres activos en este momento.',
                textAlign: TextAlign.center,
                style: GoogleFonts.workSans(
                    color: BrandColors.onSurface.withValues(alpha: 0.6))),
          ],
        ),
      );
    }

    return Column(
      children: _talleres.map((taller) => _buildTallerCard(taller)).toList(),
    );
  }

  Widget _buildTallerCard(TallerDisponible taller) {
    final selected = _selectedTaller?.id == taller.id;
    final dist = taller.distanciaKm(_lat, _lng);
    final distLabel = dist < 9000
        ? '${dist.toStringAsFixed(1)} km'
        : 'Sin GPS';

    return GestureDetector(
      onTap: () => setState(() => _selectedTaller = taller),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF5F5) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? BrandColors.primary : const Color(0xFFEADBD7),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                      color: Color(0x18BB000E),
                      blurRadius: 12,
                      offset: Offset(0, 4))
                ]
              : const [
                  BoxShadow(
                      color: Color(0x08291714),
                      blurRadius: 8,
                      offset: Offset(0, 2))
                ],
        ),
        child: Row(
          children: [
            // Icono / selección
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: selected
                    ? BrandColors.primary
                    : const Color(0xFFFDECE9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                selected
                    ? Icons.check_rounded
                    : Icons.home_repair_service_rounded,
                color: selected ? Colors.white : BrandColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            // Datos del taller
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(taller.nombre,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: BrandColors.onSurface)),
                  const SizedBox(height: 3),
                  Text(taller.ubicacionLabel,
                      style: GoogleFonts.workSans(
                          fontSize: 12,
                          color:
                              BrandColors.onSurface.withValues(alpha: 0.6)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (taller.telefono != null) ...[
                    const SizedBox(height: 2),
                    Text(taller.telefono!,
                        style: GoogleFonts.workSans(
                            fontSize: 12,
                            color: BrandColors.onSurface.withValues(alpha: 0.5))),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Distancia
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: selected
                        ? BrandColors.primary.withValues(alpha: 0.12)
                        : const Color(0xFFF8F3F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(distLabel,
                      style: GoogleFonts.workSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? BrandColors.primary
                              : BrandColors.onSurface
                                  .withValues(alpha: 0.65))),
                ),
                if (selected) ...[
                  const SizedBox(height: 4),
                  Text('Seleccionado',
                      style: GoogleFonts.workSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: BrandColors.primary,
                          letterSpacing: 0.5)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── HELPER ──────────────────────────────────────────────────────────────

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
                fontSize: 11,
                color: BrandColors.primary,
                letterSpacing: 2,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: GoogleFonts.plusJakartaSans(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: BrandColors.onSurface),
            children: [
              TextSpan(text: '$titulo\n'),
              TextSpan(
                text: tituloResaltado,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    color: BrandColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        child,
      ],
    );
  }
}
