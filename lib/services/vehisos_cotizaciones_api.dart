import 'dart:convert';
import 'package:http/http.dart' as http;
import 'vehisos_auth_api.dart';

class CotizacionModel {
  const CotizacionModel({
    required this.id,
    required this.idIncidente,
    required this.idTaller,
    required this.descripcionDesperfecto,
    required this.costoRepuestos,
    required this.costoManoObra,
    required this.costoTotal,
    required this.comisionPlataforma,
    required this.estado,
    this.repuestos,
    this.tiempoEstimado,
    this.notasAdicionales,
    this.motivoRechazo,
    this.metodoPago,
    this.fechaCreacion,
    this.fechaVencimiento,
    this.fechaRespuesta,
  });

  final int id;
  final int idIncidente;
  final int idTaller;
  final String descripcionDesperfecto;
  final double costoRepuestos;
  final double costoManoObra;
  final double costoTotal;
  final double comisionPlataforma;
  final String estado;
  final String? repuestos;
  final int? tiempoEstimado;
  final String? notasAdicionales;
  final String? motivoRechazo;
  final String? metodoPago;
  final DateTime? fechaCreacion;
  final DateTime? fechaVencimiento;
  final DateTime? fechaRespuesta;

  double get totalConComision => costoTotal + comisionPlataforma;

  bool get isEnviada => estado == 'enviada';
  bool get isAceptada => estado == 'aceptada';
  bool get isRechazada => estado == 'rechazada';
  bool get isPagada => estado == 'pagada';
  bool get isVencida => estado == 'vencida';
  bool get isPendiente => estado == 'pendiente';

  static double _d(dynamic v, [double fallback = 0.0]) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  factory CotizacionModel.fromJson(Map<String, dynamic> json) =>
      CotizacionModel(
        id: (json['id'] as num).toInt(),
        idIncidente: (json['id_incidente'] as num).toInt(),
        idTaller: (json['id_taller'] as num).toInt(),
        descripcionDesperfecto:
            json['descripcion_desperfecto'] as String? ?? '',
        costoRepuestos: _d(json['costo_repuestos']),
        costoManoObra: _d(json['costo_mano_obra']),
        costoTotal: _d(json['costo_total']),
        comisionPlataforma: _d(json['comision_plataforma']),
        estado: json['estado'] as String? ?? 'pendiente',
        repuestos: json['repuestos'] as String?,
        tiempoEstimado: (json['tiempo_estimado'] as num?)?.toInt(),
        notasAdicionales: json['notas_adicionales'] as String?,
        motivoRechazo: json['motivo_rechazo'] as String?,
        metodoPago: json['metodo_pago'] as String?,
        fechaCreacion:
            DateTime.tryParse(json['fecha_creacion'] as String? ?? ''),
        fechaVencimiento:
            DateTime.tryParse(json['fecha_vencimiento'] as String? ?? ''),
        fechaRespuesta:
            DateTime.tryParse(json['fecha_respuesta'] as String? ?? ''),
      );
}

class VehiSosCotizacionesApi {
  VehiSosCotizacionesApi({
    required this.baseUrl,
    required this.token,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  final String token;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  String _extractError(http.Response r) {
    try {
      final d = jsonDecode(r.body);
      if (d is Map && d['detail'] is String) return d['detail'] as String;
    } catch (_) {}
    return r.body.isNotEmpty ? r.body : 'Error en servidor';
  }

  Future<List<CotizacionModel>> getMisCotizaciones() async {
    final response = await _client.get(
      _uri('/api/v1/cotizaciones/mis-cotizaciones'),
      headers: _headers(),
    );
    if (response.statusCode != 200) {
      throw VehiSosApiException(_extractError(response),
          statusCode: response.statusCode);
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((v) => CotizacionModel.fromJson(v as Map<String, dynamic>))
        .toList();
  }

  Future<CotizacionModel> responderCotizacion({
    required int cotizacionId,
    required bool aceptar,
    String? metodoPago,
    String? motivoRechazo,
  }) async {
    final body = <String, dynamic>{
      'accion': aceptar ? 'aceptar' : 'rechazar',
    };
    if (aceptar && metodoPago != null) body['metodo_pago'] = metodoPago;
    if (!aceptar && motivoRechazo != null) body['motivo_rechazo'] = motivoRechazo;

    final response = await _client.patch(
      _uri('/api/v1/cotizaciones/$cotizacionId/respuesta'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw VehiSosApiException(_extractError(response),
          statusCode: response.statusCode);
    }
    return CotizacionModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<CotizacionModel> confirmarPago({
    required int cotizacionId,
    required String metodoPago,
  }) async {
    final response = await _client.patch(
      _uri('/api/v1/cotizaciones/$cotizacionId/pago'),
      headers: _headers(),
      body: jsonEncode({'metodo_pago': metodoPago}),
    );
    if (response.statusCode != 200) {
      throw VehiSosApiException(_extractError(response),
          statusCode: response.statusCode);
    }
    return CotizacionModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }
}
