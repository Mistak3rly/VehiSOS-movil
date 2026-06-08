import 'dart:convert';
import 'package:http/http.dart' as http;
import 'vehisos_auth_api.dart';

class VehicleModel {
  const VehicleModel({
    required this.id,
    required this.marca,
    required this.modelo,
    required this.placa,
    required this.idUsuario,
    this.color,
    this.observaciones,
    this.anio,
  });

  final int id;
  final String marca;
  final String modelo;
  final String placa;
  final int idUsuario;
  final String? color;
  final String? observaciones;
  final int? anio;

  String get displayName => '$marca $modelo'.trim();

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
        id: (json['id'] as num).toInt(),
        marca: json['marca'] as String? ?? '',
        modelo: json['modelo'] as String? ?? '',
        placa: json['placa'] as String? ?? '',
        idUsuario: (json['id_usuario'] as num?)?.toInt() ?? 0,
        color: json['color'] as String?,
        observaciones: json['observaciones'] as String?,
        anio: (json['anio'] as num?)?.toInt(),
      );
}

class VehiSosVehicleApi {
  VehiSosVehicleApi({
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

  Future<List<VehicleModel>> getVehicles() async {
    final response = await _client.get(
      _uri('/api/v1/emergencias/vehiculos'),
      headers: _headers(),
    );
    if (response.statusCode != 200) {
      throw VehiSosApiException(_extractError(response),
          statusCode: response.statusCode);
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((v) => VehicleModel.fromJson(v as Map<String, dynamic>))
        .toList();
  }

  Future<VehicleModel> createVehicle({
    required String marca,
    required String modelo,
    required String placa,
    String? color,
    String? observaciones,
    int? anio,
  }) async {
    final body = <String, dynamic>{
      'marca': marca,
      'modelo': modelo,
      'placa': placa,
    };
    if (color != null && color.isNotEmpty) body['color'] = color;
    if (observaciones != null && observaciones.isNotEmpty) {
      body['observaciones'] = observaciones;
    }
    if (anio != null) body['anio'] = anio;

    final response = await _client.post(
      _uri('/api/v1/emergencias/vehiculos'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    if (response.statusCode != 201) {
      throw VehiSosApiException(_extractError(response),
          statusCode: response.statusCode);
    }
    return VehicleModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<VehicleModel> updateVehicle({
    required int vehicleId,
    required String marca,
    required String modelo,
    required String placa,
    String? color,
    String? observaciones,
    int? anio,
  }) async {
    final body = <String, dynamic>{
      'marca': marca,
      'modelo': modelo,
      'placa': placa,
    };
    if (color != null) body['color'] = color;
    if (observaciones != null) body['observaciones'] = observaciones;
    if (anio != null) body['anio'] = anio;

    final response = await _client.put(
      _uri('/api/v1/emergencias/vehiculos/$vehicleId'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw VehiSosApiException(_extractError(response),
          statusCode: response.statusCode);
    }
    return VehicleModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteVehicle(int vehicleId) async {
    final response = await _client.delete(
      _uri('/api/v1/emergencias/vehiculos/$vehicleId'),
      headers: _headers(),
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw VehiSosApiException(_extractError(response),
          statusCode: response.statusCode);
    }
  }
}
