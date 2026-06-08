import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'vehisos_auth_api.dart';

class TallerDisponible {
  const TallerDisponible({
    required this.id,
    required this.nombre,
    this.telefono,
    this.direccion,
    this.ciudad,
    this.latitud,
    this.longitud,
    this.capacidadMaxima = 1,
  });

  final int id;
  final String nombre;
  final String? telefono;
  final String? direccion;
  final String? ciudad;
  final double? latitud;
  final double? longitud;
  final int capacidadMaxima;

  /// Calcula distancia en km usando la fórmula de Haversine.
  double distanciaKm(double fromLat, double fromLng) {
    if (latitud == null || longitud == null) return 9999.0;
    const r = 6371.0;
    final dLat = (latitud! - fromLat) * pi / 180;
    final dLon = (longitud! - fromLng) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(fromLat * pi / 180) *
            cos(latitud! * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  String get ubicacionLabel {
    if (ciudad != null && direccion != null) return '$ciudad · $direccion';
    if (ciudad != null) return ciudad!;
    if (direccion != null) return direccion!;
    return 'Ubicación no especificada';
  }

  factory TallerDisponible.fromJson(Map<String, dynamic> json) =>
      TallerDisponible(
        id: (json['id'] as num).toInt(),
        nombre: json['nombre'] as String? ?? '',
        telefono: json['telefono'] as String?,
        direccion: json['direccion'] as String?,
        ciudad: json['ciudad'] as String?,
        latitud: _parseDecimal(json['latitud']),
        longitud: _parseDecimal(json['longitud']),
        capacidadMaxima: (json['capacidad_maxima'] as num?)?.toInt() ?? 1,
      );

  static double? _parseDecimal(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}

class VehiSosTalleresApi {
  VehiSosTalleresApi({
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

  Future<List<TallerDisponible>> getTalleresActivos() async {
    final response = await _client.get(
      _uri('/api/v1/logistica/talleres/activos'),
      headers: _headers(),
    );
    if (response.statusCode != 200) {
      throw VehiSosApiException(_extractError(response),
          statusCode: response.statusCode);
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((v) => TallerDisponible.fromJson(v as Map<String, dynamic>))
        .toList();
  }
}
