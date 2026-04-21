import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VehiSosApiException implements Exception {
  VehiSosApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'VehiSosApiException($statusCode): $message';
}

class VehiSosUser {
  const VehiSosUser({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.correo,
    required this.documentoIdentidad,
    required this.activo,
    required this.roles,
    this.telefono,
  });

  final int id;
  final String nombre;
  final String apellidos;
  final String correo;
  final String documentoIdentidad;
  final bool activo;
  final List<String> roles;
  final String? telefono;

  factory VehiSosUser.fromJson(Map<String, dynamic> json) {
    return VehiSosUser(
      id: (json['id'] as num).toInt(),
      nombre: json['nombre'] as String? ?? '',
      apellidos: json['apellidos'] as String? ?? '',
      correo: json['correo'] as String? ?? '',
      documentoIdentidad: json['documento_identidad'] as String? ?? '',
      activo: json['activo'] as bool? ?? false,
      roles: (json['roles'] as List<dynamic>? ?? <dynamic>[])
          .map((role) {
            if (role is Map<String, dynamic>) {
              return role['nombre'] as String? ?? '';
            }
            return '';
          })
          .where((name) => name.isNotEmpty)
          .toList(growable: false),
      telefono: json['telefono'] as String?,
    );
  }

  String get displayName {
    final fullName = '$nombre $apellidos'.trim();
    return fullName.isEmpty ? correo : fullName;
  }

  bool get isClientProfile {
    return roles.any((role) {
      final normalized = role.toLowerCase();
      return normalized == 'cliente' || normalized.contains('client');
    });
  }
}

class VehiSosAuthSession {
  const VehiSosAuthSession({required this.token, required this.user});

  final String token;
  final VehiSosUser user;
}

class VehiSOSAuthApi {
  VehiSOSAuthApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? _resolveBaseUrl();

  final http.Client _client;
  final String baseUrl;

  static String _resolveBaseUrl() {
    const definedBaseUrl = String.fromEnvironment('VEHISOS_API_BASE_URL');
    if (definedBaseUrl.isNotEmpty) {
      return definedBaseUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:8000';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'http://127.0.0.1:8000';
    }
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> _jsonHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
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
        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          if (first is Map<String, dynamic>) {
            final msg = first['msg'];
            if (msg is String && msg.isNotEmpty) {
              return msg;
            }
          }
        }
      }
    } catch (_) {
      // Fall back to the raw body below.
    }

    final body = response.body.trim();
    return body.isEmpty ? 'Error inesperado del servidor' : body;
  }

  Future<VehiSosUser> register({
    required String nombre,
    required String apellidos,
    required String correo,
    required String documentoIdentidad,
    required String password,
    String? telefono,
  }) async {
    final response = await _client.post(
      _uri('/api/v1/usuarios/register'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'nombre': nombre,
        'apellidos': apellidos,
        'correo': correo,
        'telefono': telefono?.trim().isEmpty ?? true ? null : telefono,
        'documento_identidad': documentoIdentidad,
        'password': password,
        'role_ids': <int>[],
      }),
    );

    if (response.statusCode != 201) {
      throw VehiSosApiException(
        _extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }

    return VehiSosUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<VehiSosAuthSession> login({
    required String identificador,
    required String password,
  }) async {
    late final http.Response response;
    try {
      response = await _client
          .post(
            _uri('/api/v1/usuarios/login'),
            headers: _jsonHeaders(),
            body: jsonEncode({
              'identificador': identificador,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 12));
    } on TimeoutException {
      throw VehiSosApiException(
        'Tiempo de espera agotado al conectar con el servidor ($baseUrl).',
      );
    } catch (_) {
      throw VehiSosApiException(
        'No se pudo conectar con el servidor ($baseUrl). Verifica que el backend este activo.',
      );
    }

    if (response.statusCode != 200) {
      throw VehiSosApiException(
        _extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }

    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final token = decoded['access_token'];
      final user = decoded['user'];
      if (token is! String || user is! Map<String, dynamic>) {
        throw const FormatException('Respuesta de login incompleta');
      }
      return VehiSosAuthSession(
        token: token,
        user: VehiSosUser.fromJson(user),
      );
    } catch (error) {
      throw VehiSosApiException(
        'El servidor respondio el login, pero la app no pudo leer la sesion: $error',
        statusCode: response.statusCode,
      );
    }
  }

  Future<VehiSosUser> updateCurrentUser({
    required String token,
    required int userId,
    String? nombre,
    String? apellidos,
    String? correo,
    String? telefono,
    String? documentoIdentidad,
  }) async {
    final response = await _client.put(
      _uri('/api/v1/usuarios/$userId'),
      headers: _jsonHeaders(token: token),
      body: jsonEncode({
        if (nombre != null) 'nombre': nombre,
        if (apellidos != null) 'apellidos': apellidos,
        if (correo != null) 'correo': correo,
        if (telefono != null) 'telefono': telefono,
        if (documentoIdentidad != null) 'documento_identidad': documentoIdentidad,
      }),
    );

    if (response.statusCode != 200) {
      throw VehiSosApiException(
        _extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }

    return VehiSosUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<VehiSosUser> fetchCurrentUser(String token) async {
    final response = await _client.get(
      _uri('/api/v1/usuarios/me'),
      headers: _jsonHeaders(token: token),
    );

    if (response.statusCode != 200) {
      throw VehiSosApiException(
        _extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }

    return VehiSosUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}

class VehiSosSessionStore {
  static const String _tokenKey = 'vehisos_access_token';
  static const String _userKey = 'vehisos_user_json';

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  Future<void> saveSession(VehiSosAuthSession session) async {
    final prefs = await _prefs();
    await prefs.setString(_tokenKey, session.token);
    await prefs.setString(_userKey, jsonEncode(_userToJson(session.user)));
  }

  Future<String?> readToken() async {
    final prefs = await _prefs();
    return prefs.getString(_tokenKey);
  }

  Future<VehiSosUser?> readUser() async {
    final prefs = await _prefs();
    final raw = prefs.getString(_userKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      return VehiSosUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await _prefs();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Map<String, dynamic> _userToJson(VehiSosUser user) {
    return {
      'id': user.id,
      'nombre': user.nombre,
      'apellidos': user.apellidos,
      'correo': user.correo,
      'documento_identidad': user.documentoIdentidad,
      'telefono': user.telefono,
      'activo': user.activo,
      'roles': user.roles
          .map((role) => <String, dynamic>{'nombre': role})
          .toList(growable: false),
    };
  }
}
