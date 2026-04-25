import 'dart:convert';
import 'package:http/http.dart' as http;
import 'vehisos_auth_api.dart';

class HistoryEventModel {
  const HistoryEventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.timestamp,
    required this.clientId,
    this.amount,
    this.metadata,
  });

  final String id;
  final String title;
  final String description;
  final String category; // 'payment', 'garage', 'workshop', 'chat', 'general'
  final DateTime timestamp;
  final int clientId;
  final double? amount;
  final Map<String, dynamic>? metadata;

  factory HistoryEventModel.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'] ?? (json['datos'] is Map<String, dynamic> ? (json['datos'] as Map<String, dynamic>)['monto'] : null);
    return HistoryEventModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] as String?) ?? (json['titulo'] as String?) ?? '',
      description: (json['description'] as String?) ?? (json['descripcion'] as String?) ?? '',
      category: (json['category'] as String?) ?? (json['categoria'] as String?) ?? 'general',
      timestamp: DateTime.parse(
        (json['timestamp'] as String?) ??
            (json['fecha'] as String?) ??
            DateTime.now().toIso8601String(),
      ),
      clientId: (json['client_id'] as num?)?.toInt() ?? 0,
      amount: rawAmount is num ? rawAmount.toDouble() : null,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? (json['datos'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'category': category,
    'client_id': clientId,
    if (amount != null) 'amount': amount,
    if (metadata != null) 'metadata': metadata,
  };
}

class HistoryPageModel {
  const HistoryPageModel({
    required this.events,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  final List<HistoryEventModel> events;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  factory HistoryPageModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> eventsList = (json['items'] as List<dynamic>?) ??
        (json['movimientos'] as List<dynamic>?) ??
        const [];
    final pageSize = (json['page_size'] as num?)?.toInt() ?? eventsList.length;
    final total = (json['total'] as num?)?.toInt() ?? eventsList.length;
    return HistoryPageModel(
      events: eventsList
          .map((e) => HistoryEventModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: total,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: pageSize,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
    );
  }
}

class VehiSosHistoryApi {
  VehiSosHistoryApi({
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

  String _normalizeFilterCategory(String? category) {
    switch (category) {
      case null:
      case 'todos':
        return 'todos';
      case 'payment':
        return 'pagos';
      case 'workshop':
        return 'talleres';
      default:
        return category;
    }
  }

  Future<HistoryPageModel> getHistory({
    required int clientId,
    int page = 1,
    int pageSize = 20,
    String? category,
  }) async {
    if (page > 1) {
      return const HistoryPageModel(
        events: [],
        total: 0,
        page: 1,
        pageSize: 20,
        totalPages: 1,
      );
    }

    final filtro = _normalizeFilterCategory(category);
    final queryPath = '/api/v1/logistica/historial/movimientos?filtro=$filtro&limit=$pageSize';

    final response = await _client.get(
      _uri(queryPath),
      headers: _jsonHeaders(),
    );

    if (response.statusCode != 200) {
      throw VehiSosApiException(
        _extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final pageModel = HistoryPageModel.fromJson(decoded);
    return HistoryPageModel(
      events: pageModel.events,
      total: pageModel.total,
      page: 1,
      pageSize: pageSize,
      totalPages: 1,
    );
  }

  Future<HistoryEventModel> createEvent({
    required int clientId,
    required String title,
    required String description,
    required String category,
    double? amount,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _client.post(
      _uri('/api/v1/history'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'client_id': clientId,
        'title': title,
        'description': description,
        'category': category,
        if (amount != null) 'amount': amount,
        if (metadata != null) 'metadata': metadata,
      }),
    );

    if (response.statusCode != 201) {
      throw VehiSosApiException(
        _extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }

    return HistoryEventModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteEvent(int eventId) async {
    final response = await _client.delete(
      _uri('/api/v1/history/$eventId'),
      headers: _jsonHeaders(),
    );

    if (response.statusCode != 204) {
      throw VehiSosApiException(
        _extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }
  }
}
