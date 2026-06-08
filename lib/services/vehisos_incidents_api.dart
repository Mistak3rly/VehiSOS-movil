import 'dart:convert';
import 'package:http/http.dart' as http;
import 'vehisos_auth_api.dart';

class TipoIncidenteModel {
  const TipoIncidenteModel({
    required this.id,
    required this.codigo,
    required this.nombre,
  });
  final int id;
  final String codigo;
  final String nombre;

  factory TipoIncidenteModel.fromJson(Map<String, dynamic> json) =>
      TipoIncidenteModel(
        id: (json['id'] as num).toInt(),
        codigo: json['codigo'] as String? ?? '',
        nombre: json['nombre'] as String? ?? '',
      );
}

class IncidenteModel {
  const IncidenteModel({
    required this.id,
    required this.codigoIncidente,
    required this.titulo,
    required this.latitud,
    required this.longitud,
    required this.estadoNombre,
    required this.fechaReporte,
    this.descripcionTexto,
    this.direccionTextual,
    this.tipoIncidenteNombre,
    this.prioridadNombre,
    this.vehiculoNombre,
    this.requiereGrua = false,
  });

  final int id;
  final String codigoIncidente;
  final String titulo;
  final double latitud;
  final double longitud;
  final String estadoNombre;
  final DateTime fechaReporte;
  final String? descripcionTexto;
  final String? direccionTextual;
  final String? tipoIncidenteNombre;
  final String? prioridadNombre;
  final String? vehiculoNombre;
  final bool requiereGrua;

  bool get isActivo =>
      estadoNombre.toLowerCase() != 'cerrado' &&
      estadoNombre.toLowerCase() != 'cancelado' &&
      estadoNombre.toLowerCase() != 'completado';

  factory IncidenteModel.fromJson(Map<String, dynamic> json) {
    final estado = json['estado_servicio'] as Map<String, dynamic>?;
    final tipo = json['tipo_incidente'] as Map<String, dynamic>?;
    final prioridad = json['prioridad'] as Map<String, dynamic>?;
    final vehiculo = json['vehiculo'] as Map<String, dynamic>?;

    return IncidenteModel(
      id: (json['id'] as num).toInt(),
      codigoIncidente: json['codigo_incidente'] as String? ?? '',
      titulo: json['titulo'] as String? ?? '',
      latitud: (json['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (json['longitud'] as num?)?.toDouble() ?? 0.0,
      estadoNombre: estado?['nombre'] as String? ?? 'Pendiente',
      fechaReporte: DateTime.tryParse(json['fecha_reporte'] as String? ?? '') ??
          DateTime.now(),
      descripcionTexto: json['descripcion_texto'] as String?,
      direccionTextual: json['direccion_textual'] as String?,
      tipoIncidenteNombre: tipo?['nombre'] as String?,
      prioridadNombre: prioridad?['nombre'] as String?,
      vehiculoNombre: vehiculo != null
          ? '${vehiculo['marca'] ?? ''} ${vehiculo['modelo'] ?? ''}'.trim()
          : null,
      requiereGrua: json['requiere_grua'] as bool? ?? false,
    );
  }
}

class VehiSosIncidentsApi {
  VehiSosIncidentsApi({
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

  Future<List<IncidenteModel>> getIncidentes() async {
    final response = await _client.get(
      _uri('/api/v1/emergencias/incidentes'),
      headers: _headers(),
    );
    if (response.statusCode != 200) {
      throw VehiSosApiException(_extractError(response),
          statusCode: response.statusCode);
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((v) => IncidenteModel.fromJson(v as Map<String, dynamic>))
        .toList();
  }

  Future<IncidenteModel> createIncidente({
    required int idVehiculo,
    required String titulo,
    required double latitud,
    required double longitud,
    int? idTallerDestino,
    String? descripcionTexto,
    String? direccionTextual,
    bool requiereGrua = false,
  }) async {
    final body = <String, dynamic>{
      'id_vehiculo': idVehiculo,
      'titulo': titulo,
      'latitud': latitud,
      'longitud': longitud,
      'requiere_grua': requiereGrua,
    };
    if (idTallerDestino != null) body['id_taller_destino'] = idTallerDestino;
    if (descripcionTexto != null && descripcionTexto.isNotEmpty) {
      body['descripcion_texto'] = descripcionTexto;
    }
    if (direccionTextual != null && direccionTextual.isNotEmpty) {
      body['direccion_textual'] = direccionTextual;
    }

    final response = await _client.post(
      _uri('/api/v1/emergencias/incidentes'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    if (response.statusCode != 201) {
      throw VehiSosApiException(_extractError(response),
          statusCode: response.statusCode);
    }
    return IncidenteModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<TipoIncidenteModel>> getTiposIncidente() async {
    final response = await _client.get(
      _uri('/api/v1/emergencias/catalogos/tipos-incidente'),
      headers: _headers(),
    );
    if (response.statusCode != 200) {
      throw VehiSosApiException(_extractError(response),
          statusCode: response.statusCode);
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((v) => TipoIncidenteModel.fromJson(v as Map<String, dynamic>))
        .toList();
  }
}
