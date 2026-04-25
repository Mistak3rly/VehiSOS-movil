import 'dart:convert';
import 'package:http/http.dart' as http;
import 'vehisos_auth_api.dart';

class PaymentCardModel {
  const PaymentCardModel({
    required this.id,
    required this.holderName,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    required this.brand,
    required this.clientId,
  });

  final int id;
  final String holderName;
  final String last4;
  final int expMonth;
  final int expYear;
  final String brand;
  final int clientId;

  String get expiryLabel => '$expMonth/$expYear';

  factory PaymentCardModel.fromJson(Map<String, dynamic> json) {
    return PaymentCardModel(
      id: (json['id'] as num).toInt(),
      holderName: json['holder_name'] as String? ?? '',
      last4: json['last4'] as String? ?? '0000',
      expMonth: (json['exp_month'] as num?)?.toInt() ?? 1,
      expYear: (json['exp_year'] as num?)?.toInt() ?? 2025,
      brand: json['brand'] as String? ?? 'VISA',
      clientId: (json['client_id'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'holder_name': holderName,
    'last4': last4,
    'exp_month': expMonth,
    'exp_year': expYear,
    'brand': brand,
  };
}

class PaymentTransactionModel {
  const PaymentTransactionModel({
    required this.id,
    required this.cardId,
    required this.amount,
    required this.concept,
    required this.timestamp,
    required this.clientId,
  });

  final int id;
  final int cardId;
  final double amount;
  final String concept;
  final DateTime timestamp;
  final int clientId;

  factory PaymentTransactionModel.fromJson(Map<String, dynamic> json) {
    return PaymentTransactionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      cardId: (json['card_id'] as num?)?.toInt() ?? (json['id_taller'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? (json['monto_total'] as num?)?.toDouble() ?? double.tryParse((json['monto_total'] ?? '0').toString()) ?? 0,
      concept: json['concept'] as String? ?? json['metodo_pago'] as String? ?? '',
      timestamp: DateTime.parse(
        json['timestamp'] as String? ??
            json['fecha_pago'] as String? ??
            json['fecha_creacion'] as String? ??
            DateTime.now().toIso8601String(),
      ),
      clientId: (json['client_id'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'card_id': cardId,
    'amount': amount,
    'concept': concept,
  };
}

class VehiSosPaymentApi {
  VehiSosPaymentApi({
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

  // Card Management
  Future<List<PaymentCardModel>> getPaymentCards(int clientId) async {
    final response = await _client.get(
      _uri('/api/v1/payment-cards?client_id=$clientId'),
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
        .map((c) => PaymentCardModel.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  Future<PaymentCardModel> createPaymentCard({
    required int clientId,
    required String holderName,
    required String cardNumber,
    required int expMonth,
    required int expYear,
  }) async {
    // Detect brand from card number
    final brand = _detectCardBrand(cardNumber);
    final last4 = cardNumber.substring(cardNumber.length - 4);

    final response = await _client.post(
      _uri('/api/v1/payment-cards'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'client_id': clientId,
        'holder_name': holderName,
        'card_number': cardNumber,
        'last4': last4,
        'exp_month': expMonth,
        'exp_year': expYear,
        'brand': brand,
      }),
    );

    if (response.statusCode != 201) {
      throw VehiSosApiException(
        _extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }

    return PaymentCardModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<PaymentCardModel> updatePaymentCard({
    required int cardId,
    required String holderName,
    required int expMonth,
    required int expYear,
  }) async {
    final response = await _client.put(
      _uri('/api/v1/payment-cards/$cardId'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'holder_name': holderName,
        'exp_month': expMonth,
        'exp_year': expYear,
      }),
    );

    if (response.statusCode != 200) {
      throw VehiSosApiException(
        _extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }

    return PaymentCardModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deletePaymentCard(int cardId) async {
    final response = await _client.delete(
      _uri('/api/v1/payment-cards/$cardId'),
      headers: _jsonHeaders(),
    );

    if (response.statusCode != 204) {
      throw VehiSosApiException(
        _extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }
  }

  // Transaction Management
  Future<List<PaymentTransactionModel>> getTransactions({
    required int clientId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.get(
      _uri('/api/v1/transactions?client_id=$clientId&page=$page&page_size=$pageSize'),
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
        .map((t) => PaymentTransactionModel.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  Future<PaymentTransactionModel> processPayment({
    required int incidentId,
    required int workshopId,
    required double amount,
    required String paymentMethod,
  }) async {
    final response = await _client.post(
      _uri('/api/v1/logistica/pagos'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'id_incidente': incidentId,
        'id_taller': workshopId,
        'monto_total': amount,
        'metodo_pago': paymentMethod,
        'estado_pago': 'pagado',
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw VehiSosApiException(
        _extractErrorMessage(response),
        statusCode: response.statusCode,
      );
    }

    return PaymentTransactionModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  String _detectCardBrand(String cardNumber) {
    if (cardNumber.startsWith('4')) {
      return 'VISA';
    } else if (cardNumber.startsWith('5')) {
      return 'MASTERCARD';
    } else if (cardNumber.startsWith('3')) {
      return 'AMEX';
    }
    return 'OTHER';
  }
}
