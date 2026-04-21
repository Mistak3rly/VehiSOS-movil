import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class WorkshopSuggestion {
  const WorkshopSuggestion({
    required this.name,
    required this.address,
    required this.distanceKm,
    required this.rating,
    required this.priceTier,
    required this.reasons,
    required this.latitude,
    required this.longitude,
    this.isOpen = true,
  });

  final String name;
  final String address;
  final double distanceKm;
  final double rating;
  final String priceTier;
  final List<String> reasons;
  final double latitude;
  final double longitude;
  final bool isOpen;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'address': address,
        'distanceKm': distanceKm,
        'rating': rating,
        'priceTier': priceTier,
        'reasons': reasons,
        'latitude': latitude,
        'longitude': longitude,
        'isOpen': isOpen,
      };

  factory WorkshopSuggestion.fromJson(Map<String, dynamic> json) {
    return WorkshopSuggestion(
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      priceTier: json['priceTier'] as String? ?? 'Standard',
      reasons: (json['reasons'] as List<dynamic>?)?.map((item) => item.toString()).toList() ?? const [],
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      isOpen: json['isOpen'] as bool? ?? true,
    );
  }
}

class WorkshopAssistantResult {
  const WorkshopAssistantResult({
    required this.assistantText,
    required this.recommendations,
    required this.usedFallback,
  });

  final String assistantText;
  final List<WorkshopSuggestion> recommendations;
  final bool usedFallback;
}

class ClaudeWorkshopAssistantService {
  ClaudeWorkshopAssistantService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? _resolveBaseUrl();

  final http.Client _client;
  final String _baseUrl;

  static String _resolveBaseUrl() {
    const proxyBaseUrl = String.fromEnvironment('VEHISOS_AI_PROXY_URL');
    if (proxyBaseUrl.isNotEmpty) {
      return proxyBaseUrl;
    }

    const apiBaseUrl = String.fromEnvironment('VEHISOS_API_BASE_URL');
    if (apiBaseUrl.isNotEmpty) {
      return '$apiBaseUrl/api/v1/asignacion';
    }

    if (kIsWeb) {
      return 'http://localhost:8000/api/v1/asignacion';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000/api/v1/asignacion';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'http://127.0.0.1:8000/api/v1/asignacion';
    }
  }

  Future<WorkshopAssistantResult> recommendWorkshops({
    required String issue,
    required double userLatitude,
    required double userLongitude,
    required List<WorkshopSuggestion> candidates,
    String? token,
  }) async {
    if (_baseUrl.isEmpty) {
      final local = _rankLocally(userLatitude, userLongitude, candidates);
      return _localResult(issue, local);
    }

    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/recommend-workshops'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, dynamic>{
          'issue': issue,
          'userLatitude': userLatitude,
          'userLongitude': userLongitude,
          'candidates': candidates.map((item) => item.toJson()).toList(),
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final local = _rankLocally(userLatitude, userLongitude, candidates);
        return _localResult(issue, local);
      }

      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        final recommendations = decoded
            .whereType<Map<String, dynamic>>()
            .map(WorkshopSuggestion.fromJson)
            .toList(growable: false);
        return _localResult(issue, recommendations);
      }

      if (decoded is Map<String, dynamic>) {
        final rawRecommendations = decoded['recommendations'];
        final recommendations = rawRecommendations is List
            ? rawRecommendations
                .whereType<Map<String, dynamic>>()
                .map(WorkshopSuggestion.fromJson)
                .toList(growable: false)
            : _rankLocally(userLatitude, userLongitude, candidates);
        final assistantText = decoded['assistantText'] as String? ?? _buildLocalAssistantText(issue, recommendations);
        return WorkshopAssistantResult(
          assistantText: assistantText,
          recommendations: recommendations,
          usedFallback: decoded['fallback'] as bool? ?? false,
        );
      }
    } catch (_) {
      // Keep the tracking screen usable even when the AI service is offline.
    }

    final local = _rankLocally(userLatitude, userLongitude, candidates);
    return _localResult(issue, local);
  }

  WorkshopAssistantResult _localResult(String issue, List<WorkshopSuggestion> ranked) {
    return WorkshopAssistantResult(
      assistantText: _buildLocalAssistantText(issue, ranked),
      recommendations: ranked,
      usedFallback: true,
    );
  }

  String _buildLocalAssistantText(String issue, List<WorkshopSuggestion> ranked) {
    if (ranked.isEmpty) {
      return 'Estoy revisando talleres cercanos. En breve te muestro las mejores opciones.';
    }

    final topWorkshop = ranked.first;
    final distanceLabel = topWorkshop.distanceKm.toStringAsFixed(1);
    return 'Para "$issue" te recomiendo ${topWorkshop.name}, a $distanceLabel km. Puedes compartir tu ubicacion con un toque.';
  }

  List<WorkshopSuggestion> _rankLocally(
    double userLatitude,
    double userLongitude,
    List<WorkshopSuggestion> candidates,
  ) {
    if (candidates.isEmpty) {
      return const [];
    }

    final ranked = [...candidates];
    ranked.sort((left, right) {
      final leftScore = _score(left, userLatitude, userLongitude);
      final rightScore = _score(right, userLatitude, userLongitude);
      return leftScore.compareTo(rightScore);
    });
    return ranked;
  }

  double _score(WorkshopSuggestion suggestion, double userLatitude, double userLongitude) {
    final distancePenalty = suggestion.distanceKm;
    final ratingBonus = (5 - suggestion.rating) * 0.8;
    final openPenalty = suggestion.isOpen ? 0 : 3.0;
    return distancePenalty + ratingBonus + openPenalty;
  }
}
