part of '../client_home_screen.dart';

class CotizacionesTab extends StatefulWidget {
  const CotizacionesTab({
    super.key,
    required this.apiBaseUrl,
    required this.token,
    required this.onOpenNotifications,
  });

  final String apiBaseUrl;
  final String token;
  final VoidCallback onOpenNotifications;

  @override
  State<CotizacionesTab> createState() => _CotizacionesTabState();
}

class _CotizacionesTabState extends State<CotizacionesTab> {
  late VehiSosCotizacionesApi _api;
  List<CotizacionModel> _cotizaciones = const [];
  bool _loading = true;
  String? _error;

  static const _metodosPago = ['Efectivo', 'Tarjeta', 'QR', 'Transferencia'];

  @override
  void initState() {
    super.initState();
    _api = VehiSosCotizacionesApi(
      baseUrl: widget.apiBaseUrl,
      token: widget.token,
    );
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.getMisCotizaciones();
      if (!mounted) return;
      setState(() {
        _cotizaciones = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar las cotizaciones: $e';
        _loading = false;
      });
    }
  }

  Future<void> _aceptar(CotizacionModel c) async {
    String? metodoPago;
    final confirm = await showDialog<String>(
      context: context,
      builder: (ctx) {
        String selected = _metodosPago.first;
        return StatefulBuilder(builder: (ctx, setLocal) {
          return AlertDialog(
            title: Text('Aceptar cotización',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total a pagar: \$${c.totalConComision.toStringAsFixed(2)}',
                    style: GoogleFonts.workSans(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Text('Método de pago:', style: GoogleFonts.workSans(fontSize: 14)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selected,
                  items: _metodosPago
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) => setLocal(() => selected = v!),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(selected),
                style: ElevatedButton.styleFrom(
                    backgroundColor: BrandColors.primary),
                child: const Text('Confirmar',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );
    if (confirm == null || !mounted) return;
    metodoPago = confirm.toLowerCase();
    try {
      final updated = await _api.responderCotizacion(
        cotizacionId: c.id,
        aceptar: true,
        metodoPago: metodoPago,
      );
      _replaceCotizacion(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Cotización aceptada correctamente.'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al aceptar: $e')),
        );
      }
    }
  }

  Future<void> _rechazar(CotizacionModel c) async {
    final motivoController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Rechazar cotización',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Estás seguro de rechazar esta cotización?',
                style: GoogleFonts.workSans()),
            const SizedBox(height: 12),
            TextField(
              controller: motivoController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Motivo (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Rechazar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      final updated = await _api.responderCotizacion(
        cotizacionId: c.id,
        aceptar: false,
        motivoRechazo: motivoController.text.trim().isEmpty
            ? null
            : motivoController.text.trim(),
      );
      _replaceCotizacion(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cotización rechazada.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al rechazar: $e')),
        );
      }
    }
  }

  Future<void> _confirmarPago(CotizacionModel c) async {
    final confirm = await showDialog<String>(
      context: context,
      builder: (ctx) {
        String selected = c.metodoPago ?? _metodosPago.first;
        return StatefulBuilder(builder: (ctx, setLocal) {
          return AlertDialog(
            title: Text('Confirmar pago',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total: \$${c.totalConComision.toStringAsFixed(2)}',
                    style: GoogleFonts.workSans(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selected,
                  items: _metodosPago
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) => setLocal(() => selected = v!),
                  decoration: const InputDecoration(
                    labelText: 'Método de pago',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(selected),
                style: ElevatedButton.styleFrom(
                    backgroundColor: BrandColors.primary),
                child: const Text('Pagar', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );
    if (confirm == null || !mounted) return;
    try {
      final updated = await _api.confirmarPago(
        cotizacionId: c.id,
        metodoPago: confirm.toLowerCase(),
      );
      _replaceCotizacion(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Pago confirmado exitosamente.'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al confirmar pago: $e')),
        );
      }
    }
  }

  void _replaceCotizacion(CotizacionModel updated) {
    setState(() {
      _cotizaciones = _cotizaciones
          .map((c) => c.id == updated.id ? updated : c)
          .toList();
    });
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'enviada':
        return const Color(0xFF3B82F6);
      case 'aceptada':
        return const Color(0xFF10B981);
      case 'rechazada':
        return const Color(0xFFEF4444);
      case 'pagada':
        return const Color(0xFF8B5CF6);
      case 'vencida':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String _estadoLabel(String estado) {
    switch (estado) {
      case 'enviada':
        return 'PENDIENTE';
      case 'aceptada':
        return 'ACEPTADA';
      case 'rechazada':
        return 'RECHAZADA';
      case 'pagada':
        return 'PAGADA';
      case 'vencida':
        return 'VENCIDA';
      default:
        return estado.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3F2),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFDECE9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: BrandColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mis Cotizaciones',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: BrandColors.onSurface)),
                Text('Revisa y gestiona las ofertas de los talleres',
                    style: GoogleFonts.workSans(
                        fontSize: 12,
                        color: BrandColors.onSurface.withValues(alpha: 0.6))),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _cargar,
                icon: const Icon(Icons.refresh_rounded,
                    color: BrandColors.primary),
                tooltip: 'Actualizar',
              ),
              IconButton(
                onPressed: widget.onOpenNotifications,
                icon: const Icon(Icons.notifications_rounded,
                    color: BrandColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: BrandColors.primary));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: BrandColors.primary),
              const SizedBox(height: 16),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.workSans(color: BrandColors.onSurface)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _cargar,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: BrandColors.primary,
                    foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
    if (_cotizaciones.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFDECE9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.receipt_long_rounded,
                  size: 40, color: BrandColors.primary),
            ),
            const SizedBox(height: 20),
            Text('Sin cotizaciones aún',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.onSurface)),
            const SizedBox(height: 8),
            Text('Cuando reportes un incidente,\nlos talleres te enviarán sus ofertas.',
                textAlign: TextAlign.center,
                style: GoogleFonts.workSans(
                    color: BrandColors.onSurface.withValues(alpha: 0.6))),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargar,
      color: BrandColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
        itemCount: _cotizaciones.length,
        itemBuilder: (context, index) =>
            _buildCotizacionCard(_cotizaciones[index]),
      ),
    );
  }

  Widget _buildCotizacionCard(CotizacionModel c) {
    final color = _estadoColor(c.estado);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
              color: Color(0x10291714), blurRadius: 18, offset: Offset(0, 6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              color: color.withValues(alpha: 0.08),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(_estadoLabel(c.estado),
                      style: GoogleFonts.workSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: color,
                          letterSpacing: 1.4)),
                  const Spacer(),
                  Text('#${c.id} · Incidente #${c.idIncidente}',
                      style: GoogleFonts.workSans(
                          fontSize: 12,
                          color: BrandColors.onSurface.withValues(alpha: 0.5))),
                ],
              ),
            ),
            // Contenido
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.descripcionDesperfecto,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: BrandColors.onSurface)),
                  if (c.repuestos != null && c.repuestos!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text('Repuestos: ${c.repuestos}',
                        style: GoogleFonts.workSans(
                            fontSize: 13,
                            color:
                                BrandColors.onSurface.withValues(alpha: 0.7))),
                  ],
                  const SizedBox(height: 14),
                  // Desglose de costos
                  _buildCostoRow('Repuestos', c.costoRepuestos),
                  _buildCostoRow('Mano de obra', c.costoManoObra),
                  _buildCostoRow('Comisión plataforma', c.comisionPlataforma),
                  const Divider(height: 20),
                  Row(
                    children: [
                      Text('TOTAL',
                          style: GoogleFonts.workSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: 1,
                              color: BrandColors.onSurface)),
                      const Spacer(),
                      Text('\$${c.totalConComision.toStringAsFixed(2)}',
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                              color: BrandColors.primary)),
                    ],
                  ),
                  if (c.tiempoEstimado != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 16,
                            color: BrandColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Tiempo estimado: ${c.tiempoEstimado! >= 60 ? '${c.tiempoEstimado! ~/ 60}h ${c.tiempoEstimado! % 60}min' : '${c.tiempoEstimado} min'}',
                          style: GoogleFonts.workSans(
                              fontSize: 13,
                              color:
                                  BrandColors.onSurface.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ],
                  if (c.notasAdicionales != null &&
                      c.notasAdicionales!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F3F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(c.notasAdicionales!,
                          style: GoogleFonts.workSans(
                              fontSize: 13,
                              color: BrandColors.onSurface
                                  .withValues(alpha: 0.7))),
                    ),
                  ],
                  if (c.motivoRechazo != null &&
                      c.motivoRechazo!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Motivo de rechazo: ${c.motivoRechazo}',
                          style: GoogleFonts.workSans(
                              fontSize: 13, color: Colors.red.shade700)),
                    ),
                  ],
                  if (c.fechaVencimiento != null && c.isEnviada) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Vence: ${_formatDate(c.fechaVencimiento!)}',
                      style: GoogleFonts.workSans(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                  // Botones de acción
                  const SizedBox(height: 16),
                  _buildActions(c),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostoRow(String label, double valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label,
              style: GoogleFonts.workSans(
                  fontSize: 13,
                  color: BrandColors.onSurface.withValues(alpha: 0.6))),
          const Spacer(),
          Text('\$${valor.toStringAsFixed(2)}',
              style: GoogleFonts.workSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: BrandColors.onSurface)),
        ],
      ),
    );
  }

  Widget _buildActions(CotizacionModel c) {
    if (c.isEnviada) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _rechazar(c),
              icon: const Icon(Icons.close_rounded, size: 16),
              label: const Text('Rechazar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _aceptar(c),
              icon: const Icon(Icons.check_rounded, size: 16),
              label: const Text('Aceptar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: BrandColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      );
    }

    if (c.isAceptada) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _confirmarPago(c),
          icon: const Icon(Icons.payment_rounded),
          label: const Text('Confirmar Pago'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5CF6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );
    }

    if (c.isPagada) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFD1FAE5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF065F46), size: 18),
            const SizedBox(width: 8),
            Text('Pagado · ${c.metodoPago ?? ''}',
                style: GoogleFonts.workSans(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF065F46))),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
