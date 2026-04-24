import 'dart:convert';
import 'package:http/http.dart' as http;
import 'vehisos_auth_api.dart';

class VehicleModel {
  const VehicleModel({
    required this.id,
    required this.nickname,
    required this.plate,
    required this.model,
    required this.color,
    required this.isPrimary,
    required this.clientId,
  });

  final int id;
  final String nickname;
  final String plate;
  final String model;
  final String color;
  final bool isPrimary;
  final int clientId;

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: (json['id'] as num).toInt(),
      nickname: json['nickname'] as String? ?? '',
      plate: json['plate'] as String? ?? '',
      model: json['model'] as String? ?? '',
      color: json['color'] as String? ?? '',
      isPrimary: json['is_primary'] as bool? ?? false,
      clientId: (json['client_id'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'nickname': nickname,
    'plate': plate,
    'model': model,
    'color': color,
    'is_primary': isPrimary,
  };
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

  Map<String, String> _jsonHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];
        if (detail is String) {
          return detail;
        }
      }
    } catch (_) {
      // Fall back to raw body
    }
    return response.body.isNotEmpty ? response.body : 'Error en servidor';
  }

  Future<List<VehicleModel>> getVehicles(int clientId) async {
    final response = await _client.get(
      _uri('/api/v1/vehicles?client_id=$clientId'),
      headers: _jsonHeaders(),
    );

    if (response.statusCode != 200) {
      throw VehiSosApiException(
        _extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((v) => VehicleModel.fromJson(v as Map<String, dynamic>))
        .toList();
  }

  Future<VehicleModel> createVehicle({
    required int clientId,
    required String nickname,
    required String plate,
    required String model,
    required String color,
    required bool isPrimary,
  }) async {
    final response = await _client.post(
      _uri('/api/v1/vehicles'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'client_id': clientId,
        'nickname': nickname,
        'plate': plate,
        'model': model,
        'color': color,
        'is_primary': isPrimary,
      }),
    );

    if (response.statusCode != 201) {
      throw VehiSosApiException(
        _extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }

    return VehicleModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<VehicleModel> updateVehicle({
    required int vehicleId,
    required String nickname,
    required String plate,
    required String model,
    required String color,
    required bool isPrimary,
  }) async {
    final response = await _client.put(
      _uri('/api/v1/vehicles/$vehicleId'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'nickname': nickname,
        'plate': plate,
        'model': model,
        'color': color,
        'is_primary': isPrimary,
      }),
    );

    if (response.statusCode != 200) {
      throw VehiSosApiException(
        _extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }

    return VehicleModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteVehicle(int vehicleId) async {
    final response = await _client.delete(
      _uri('/api/v1/vehicles/$vehicleId'),
      headers: _jsonHeaders(),
    );

    if (response.statusCode != 204) {
      throw VehiSosApiException(
        _extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }
  }

  Future<VehicleModel> setPrimaryVehicle(int vehicleId, int clientId) async {
    final response = await _client.post(
      _uri('/api/v1/vehicles/$vehicleId/set-primary'),
      headers: _jsonHeaders(),
      body: jsonEncode({'client_id': clientId}),
    );

    if (response.statusCode != 200) {
      throw VehiSosApiException(
        _extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }

    return VehicleModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
