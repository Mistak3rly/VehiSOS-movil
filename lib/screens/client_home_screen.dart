import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/vehisos_auth_api.dart';
import '../services/vehisos_vehicle_api.dart';
import '../services/vehisos_payment_api.dart';
import '../services/vehisos_history_api.dart';
import '../services/workshop_assistant_service.dart';
import '../theme/brand_colors.dart';
import '../widgets/common_widgets.dart';
import 'auth_gate.dart';
import 'client_profile_screen.dart';

part 'client_home_views/shared_top_bar.dart';
part 'client_home_views/bottom_nav.dart';
part 'client_home_views/sos_dashboard_tab.dart';
part 'client_home_views/sos_report_tab.dart';
part 'client_home_views/tracking_status_tab.dart';
part 'client_home_views/profile_tab.dart';
part 'client_home_views/garage_tab.dart';
part 'client_home_views/history_tab.dart';
part 'client_home_views/payments_tab.dart';
part 'client_home_views/notifications_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({
    super.key,
    required this.user,
    required this.sessionStore,
    required this.initialToken,
    this.fallbackUser,
  });

  final VehiSosUser user;
  final VehiSosUser? fallbackUser;
  final VehiSosSessionStore sessionStore;
  final String initialToken;

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class ClientVehicle {
  const ClientVehicle({
    required this.nickname,
    required this.plate,
    required this.model,
    required this.color,
    this.isPrimary = false,
  });

  final String nickname;
  final String plate;
  final String model;
  final String color;
  final bool isPrimary;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'nickname': nickname,
        'plate': plate,
        'model': model,
        'color': color,
        'isPrimary': isPrimary,
      };

  factory ClientVehicle.fromJson(Map<String, dynamic> json) {
    return ClientVehicle(
      nickname: json['nickname'] as String? ?? '',
      plate: json['plate'] as String? ?? '',
      model: json['model'] as String? ?? '',
      color: json['color'] as String? ?? '',
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }
}

class ClientPaymentCard {
  const ClientPaymentCard({
    this.id = 0,
    required this.holder,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    required this.brand,
  });

  final int id;
  final String holder;
  final String last4;
  final int expMonth;
  final int expYear;
  final String brand;

  String get expiryLabel => '${expMonth.toString().padLeft(2, '0')}/$expYear';

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'holder': holder,
        'last4': last4,
        'expMonth': expMonth,
        'expYear': expYear,
        'brand': brand,
      };

  factory ClientPaymentCard.fromJson(Map<String, dynamic> json) {
    return ClientPaymentCard(
      id: (json['id'] as num?)?.toInt() ?? 0,
      holder: json['holder'] as String? ?? '',
      last4: json['last4'] as String? ?? '',
      expMonth: (json['expMonth'] as num?)?.toInt() ?? 1,
      expYear: (json['expYear'] as num?)?.toInt() ?? 24,
      brand: json['brand'] as String? ?? 'Card',
    );
  }
}

class ClientHistoryEntry {
  const ClientHistoryEntry({
    required this.title,
    required this.description,
    required this.category,
    required this.timestamp,
    this.amount,
  });

  final String title;
  final String description;
  final String category;
  final DateTime timestamp;
  final double? amount;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'description': description,
        'category': category,
        'timestamp': timestamp.toIso8601String(),
        'amount': amount,
      };

  factory ClientHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ClientHistoryEntry(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      amount: (json['amount'] as num?)?.toDouble(),
    );
  }
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _currentIndex = 0;
  bool _showSosReport = false;
  bool _loadingClientData = true;

  late VehiSosVehicleApi _vehicleApi;
  late VehiSosPaymentApi _paymentApi;
  late VehiSosHistoryApi _historyApi;

  WorkshopSuggestion? _assignedWorkshop;
  List<ClientVehicle> _vehicles = const [];
  List<ClientPaymentCard> _cards = const [];
  List<ClientHistoryEntry> _historySource = const [];
  List<ClientHistoryEntry> _history = const [];
  int _historyPage = 1;
  int _historyTotalPages = 1;
  String _historyFilterCategory = 'todos';

  @override
  void initState() {
    super.initState();
    _initializeApis();
    _loadClientData();
  }

  void _initializeApis() {
    final apiBaseUrl = _resolveApiBaseUrl();
    _vehicleApi = VehiSosVehicleApi(
      baseUrl: apiBaseUrl,
      token: widget.initialToken,
    );
    _paymentApi = VehiSosPaymentApi(
      baseUrl: apiBaseUrl,
      token: widget.initialToken,
    );
    _historyApi = VehiSosHistoryApi(
      baseUrl: apiBaseUrl,
      token: widget.initialToken,
    );
  }

  String _resolveApiBaseUrl() {
    const configuredBaseUrl = String.fromEnvironment('VEHISOS_API_BASE_URL');
    if (configuredBaseUrl.isNotEmpty) {
      return configuredBaseUrl;
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
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

  List<ClientHistoryEntry> _filterHistoryEntries(
    List<ClientHistoryEntry> source,
    String category,
  ) {
    if (category == 'todos') {
      return source;
    }

    return source
        .where((entry) => entry.category == category)
        .toList(growable: false);
  }

  String _scopedKey(String suffix) => 'vehisos.client.${widget.user.id}.$suffix';

  Future<void> _loadClientData() async {
    try {
      // Load vehicles from API
      final apiVehicles = await _vehicleApi.getVehicles(widget.user.id);
      final vehicles = apiVehicles
          .map((v) => ClientVehicle(
                nickname: v.nickname,
                plate: v.plate,
                model: v.model,
                color: v.color,
                isPrimary: v.isPrimary,
              ))
          .toList();

      // Load cards from API
      final apiCards = await _paymentApi.getPaymentCards(widget.user.id);
      final cards = apiCards
          .map((c) => ClientPaymentCard(
            id: c.id,
                holder: c.holderName,
                last4: c.last4,
                expMonth: c.expMonth,
                expYear: c.expYear,
                brand: c.brand,
              ))
          .toList();

      // Load history from API (first page)
      final historyPage = await _historyApi.getHistory(
        clientId: widget.user.id,
        page: 1,
        category: _historyFilterCategory != 'todos' ? _historyFilterCategory : null,
      );
      final history = historyPage.events
          .map((e) => ClientHistoryEntry(
                title: e.title,
                description: e.description,
                category: e.category,
                timestamp: e.timestamp,
                amount: e.amount,
              ))
          .toList();

      if (!mounted) return;

      setState(() {
        _vehicles = vehicles.isEmpty
            ? const [
                ClientVehicle(
                  nickname: 'Auto principal',
                  plate: 'ABC-1234',
                  model: 'Toyota Corolla',
                  color: 'Plata',
                  isPrimary: true,
                )
              ]
            : vehicles;
        _cards = cards.isEmpty
            ? const [
                ClientPaymentCard(
                  holder: 'USUARIO VEHISOS',
                  last4: '4492',
                  expMonth: 9,
                  expYear: 27,
                  brand: 'VISA',
                )
              ]
            : cards;
        _historySource = history;
        _history = _filterHistoryEntries(history, _historyFilterCategory);
        _historyTotalPages = historyPage.totalPages;
        _loadingClientData = false;
      });
    } catch (e) {
      // Fallback to SharedPreferences if API fails
      await _loadClientDataFallback();
    }
  }

  Future<void> _loadClientDataFallback() async {
    final prefs = await SharedPreferences.getInstance();
    final rawVehicles = prefs.getString(_scopedKey('garage'));
    final rawCards = prefs.getString(_scopedKey('cards'));
    final rawHistory = prefs.getString(_scopedKey('history'));

    List<ClientVehicle> vehicles = const [
      ClientVehicle(
        nickname: 'Auto principal',
        plate: 'ABC-1234',
        model: 'Toyota Corolla',
        color: 'Plata',
        isPrimary: true,
      ),
    ];
    List<ClientPaymentCard> cards = const [
      ClientPaymentCard(
        holder: 'USUARIO VEHISOS',
        last4: '4492',
        expMonth: 9,
        expYear: 27,
        brand: 'VISA',
      ),
    ];
    List<ClientHistoryEntry> history = const [];

    if (rawVehicles != null && rawVehicles.isNotEmpty) {
      final decoded = jsonDecode(rawVehicles) as List<dynamic>;
      vehicles = decoded
          .whereType<Map<String, dynamic>>()
          .map(ClientVehicle.fromJson)
          .toList(growable: false);
    }

    if (rawCards != null && rawCards.isNotEmpty) {
      final decoded = jsonDecode(rawCards) as List<dynamic>;
      cards = decoded
          .whereType<Map<String, dynamic>>()
          .map(ClientPaymentCard.fromJson)
          .toList(growable: false);
    }

    if (rawHistory != null && rawHistory.isNotEmpty) {
      final decoded = jsonDecode(rawHistory) as List<dynamic>;
      history = decoded
          .whereType<Map<String, dynamic>>()
          .map(ClientHistoryEntry.fromJson)
          .toList(growable: false);
    }

    if (!mounted) return;

    setState(() {
      _vehicles = vehicles;
      _cards = cards;
      _historySource = history;
      _history = _filterHistoryEntries(history, _historyFilterCategory);
      _loadingClientData = false;
    });
  }

  Future<void> _addVehicleViaApi(ClientVehicle vehicle) async {
    try {
      await _vehicleApi.createVehicle(
        clientId: widget.user.id,
        nickname: vehicle.nickname,
        plate: vehicle.plate,
        model: vehicle.model,
        color: vehicle.color,
        isPrimary: vehicle.isPrimary,
      );

      setState(() {
        _vehicles = [vehicle, ..._vehicles];
      });

      await _appendHistoryViaApi(
        title: 'Vehiculo agregado',
        description: '${vehicle.model} (${vehicle.plate}) agregado a My Garage.',
        category: 'garage',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar vehículo: $e')),
        );
      }
    }
  }

  Future<void> _editVehicleViaApi({
    required int vehicleId,
    required ClientVehicle updatedVehicle,
  }) async {
    try {
      await _vehicleApi.updateVehicle(
        vehicleId: vehicleId,
        nickname: updatedVehicle.nickname,
        plate: updatedVehicle.plate,
        model: updatedVehicle.model,
        color: updatedVehicle.color,
        isPrimary: updatedVehicle.isPrimary,
      );

      final index = _vehicles.indexWhere((v) => v.model == updatedVehicle.model && v.plate == updatedVehicle.plate);
      if (index != -1) {
        final updated = [..._vehicles];
        updated[index] = updatedVehicle;
        setState(() {
          _vehicles = updated;
        });
      }

      await _appendHistoryViaApi(
        title: 'Vehículo actualizado',
        description: '${updatedVehicle.model} (${updatedVehicle.plate}) ha sido actualizado.',
        category: 'garage',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al editar vehículo: $e')),
        );
      }
    }
  }

  Future<void> _deleteVehicleViaApi({
    required int vehicleId,
    required ClientVehicle vehicle,
  }) async {
    try {
      await _vehicleApi.deleteVehicle(vehicleId);

      setState(() {
        _vehicles = _vehicles.where((v) => v.plate != vehicle.plate).toList();
      });

      await _appendHistoryViaApi(
        title: 'Vehículo eliminado',
        description: '${vehicle.model} (${vehicle.plate}) ha sido eliminado de My Garage.',
        category: 'garage',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar vehículo: $e')),
        );
      }
    }
  }

  Future<void> _addCardViaApi(ClientPaymentCard card) async {
    try {
      // Note: Full card number would be needed here in production
      // For now we're working with the last4 digits
      final createdCard = await _paymentApi.createPaymentCard(
        clientId: widget.user.id,
        holderName: card.holder,
        cardNumber: '****${card.last4}',
        expMonth: card.expMonth,
        expYear: card.expYear,
      );

      setState(() {
        _cards = [
          ClientPaymentCard(
            id: createdCard.id,
            holder: createdCard.holderName,
            last4: createdCard.last4,
            expMonth: createdCard.expMonth,
            expYear: createdCard.expYear,
            brand: createdCard.brand,
          ),
          ..._cards,
        ];
      });

      await _appendHistoryViaApi(
        title: 'Tarjeta registrada',
        description: '${card.brand} terminada en ${card.last4} guardada para pagos.',
        category: 'payment',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar tarjeta: $e')),
        );
      }
    }
  }

  Future<void> _editCardViaApi({
    required int cardId,
    required ClientPaymentCard updatedCard,
  }) async {
    try {
      await _paymentApi.updatePaymentCard(
        cardId: cardId,
        holderName: updatedCard.holder,
        expMonth: updatedCard.expMonth,
        expYear: updatedCard.expYear,
      );

      final index = _cards.indexWhere((c) => c.id == cardId);
      if (index != -1) {
        final updated = [..._cards];
        updated[index] = ClientPaymentCard(
          id: cardId,
          holder: updatedCard.holder,
          last4: updatedCard.last4,
          expMonth: updatedCard.expMonth,
          expYear: updatedCard.expYear,
          brand: updatedCard.brand,
        );
        setState(() {
          _cards = updated;
        });
      }

      await _appendHistoryViaApi(
        title: 'Tarjeta actualizada',
        description: '${updatedCard.brand} terminada en ${updatedCard.last4} actualizada.',
        category: 'payment',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al editar tarjeta: $e')),
        );
      }
    }
  }

  Future<void> _deleteCardViaApi({
    required int cardId,
    required ClientPaymentCard card,
  }) async {
    try {
      await _paymentApi.deletePaymentCard(cardId);

      setState(() {
        _cards = _cards.where((c) => c.id != cardId).toList();
      });

      await _appendHistoryViaApi(
        title: 'Tarjeta eliminada',
        description: '${card.brand} terminada en ${card.last4} ha sido eliminada.',
        category: 'payment',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar tarjeta: $e')),
        );
      }
    }
  }

  Future<void> _processPaymentViaApi({
    required ClientPaymentCard card,
    required double amount,
    required String concept,
  }) async {
    try {
      if (card.id <= 0) {
        _appendHistoryLocal(
          title: 'Pago realizado (local)',
          description: '$concept pagado con ${card.brand} **** ${card.last4}.',
          category: 'payment',
          amount: amount,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pago registrado localmente. Registra nuevamente la tarjeta para sincronizar con API.'),
            ),
          );
        }
        return;
      }

      await _paymentApi.processPayment(
        clientId: widget.user.id,
        cardId: card.id,
        amount: amount,
        concept: concept,
      );

      await _appendHistoryViaApi(
        title: 'Pago realizado',
        description: '$concept pagado con ${card.brand} **** ${card.last4}.',
        category: 'payment',
        amount: amount,
      );
    } on VehiSosApiException catch (e) {
      if (e.statusCode == 404) {
        _appendHistoryLocal(
          title: 'Pago realizado (local)',
          description: '$concept pagado con ${card.brand} **** ${card.last4}.',
          category: 'payment',
          amount: amount,
        );
      }
      if (mounted) {
        final message = e.statusCode == 404
            ? 'Endpoint de pago no encontrado en backend. El pago se guardó localmente.'
            : 'Error al procesar pago: ${e.message}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar pago: $e')),
        );
      }
    }
  }

  Future<void> _loadMoreHistory() async {
    if (_historyPage >= _historyTotalPages) return;

    try {
      final nextPage = _historyPage + 1;
      final historyPage = await _historyApi.getHistory(
        clientId: widget.user.id,
        page: nextPage,
        category: _historyFilterCategory != 'todos' ? _historyFilterCategory : null,
      );

      final newEvents = historyPage.events
          .map((e) => ClientHistoryEntry(
                title: e.title,
                description: e.description,
                category: e.category,
                timestamp: e.timestamp,
                amount: e.amount,
              ))
          .toList();

      final merged = [..._historySource, ...newEvents];

      setState(() {
        _historySource = merged;
        _history = _filterHistoryEntries(merged, _historyFilterCategory);
        _historyPage = nextPage;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar más historial: $e')),
        );
      }
    }
  }

  Future<void> _filterHistoryByCategory(String category) async {
    try {
      _historyPage = 1;
      final historyPage = await _historyApi.getHistory(
        clientId: widget.user.id,
        page: 1,
        category: null,
      );

      final allHistory = historyPage.events
          .map((e) => ClientHistoryEntry(
                title: e.title,
                description: e.description,
                category: e.category,
                timestamp: e.timestamp,
                amount: e.amount,
              ))
          .toList();

      setState(() {
        _historySource = allHistory;
        _history = _filterHistoryEntries(allHistory, category);
        _historyFilterCategory = category;
        _historyTotalPages = historyPage.totalPages;
      });
    } on VehiSosApiException catch (e) {
      if (e.statusCode == 404) {
        _applyHistoryFilterLocally(category);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Filtro aplicado localmente (endpoint de historial no disponible en backend).'),
            ),
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al filtrar historial: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al filtrar historial: $e')),
        );
      }
    }
  }

  void _applyHistoryFilterLocally(String category) {
    final filtered = _filterHistoryEntries(_historySource, category);

    setState(() {
      _history = filtered;
      _historyFilterCategory = category;
      _historyPage = 1;
      _historyTotalPages = 1;
    });
  }

  void _appendHistoryLocal({
    required String title,
    required String description,
    required String category,
    double? amount,
  }) {
    final entry = ClientHistoryEntry(
      title: title,
      description: description,
      category: category,
      timestamp: DateTime.now(),
      amount: amount,
    );
    final updatedSource = [entry, ..._historySource];

    setState(() {
      _historySource = updatedSource;
      _history = _filterHistoryEntries(updatedSource, _historyFilterCategory);
    });
  }

  Future<void> _appendHistoryViaApi({
    required String title,
    required String description,
    required String category,
    double? amount,
  }) async {
    try {
      final event = await _historyApi.createEvent(
        clientId: widget.user.id,
        title: title,
        description: description,
        category: category,
        amount: amount,
      );

      final entry = ClientHistoryEntry(
        title: event.title,
        description: event.description,
        category: event.category,
        timestamp: event.timestamp,
        amount: event.amount,
      );
      final updatedSource = [entry, ..._historySource];

      setState(() {
        _historySource = updatedSource;
        _history = _filterHistoryEntries(updatedSource, _historyFilterCategory);
      });
    } catch (e) {
      _appendHistoryLocal(
        title: title,
        description: description,
        category: category,
        amount: amount,
      );
    }
  }

  void _onWorkshopAssigned(WorkshopSuggestion workshop) {
    setState(() {
      _assignedWorkshop = workshop;
    });

    _appendHistoryViaApi(
      title: 'Taller contactado',
      description: 'Se envio el incidente a ${workshop.name}.',
      category: 'workshop',
    );
  }

  void _onTrackingEvent({
    required String title,
    required String description,
    required String category,
  }) {
    _appendHistoryViaApi(title: title, description: description, category: category);
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ClientNotificationsScreen(),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await widget.sessionStore.clear();
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const AuthGate()),
      (route) => false,
    );
  }

  void _openProfileEditor(BuildContext context, VehiSosUser user) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ClientProfileScreen(
          user: user,
          sessionStore: widget.sessionStore,
          initialToken: widget.initialToken,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayUser = widget.fallbackUser ?? widget.user;

    if (_loadingClientData) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F3F2),
        body: Center(child: CircularProgressIndicator(color: BrandColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3F2),
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _showSosReport
                    ? _SosReportTab(
                        onBack: () => setState(() => _showSosReport = false),
                        onOpenNotifications: _openNotifications,
                      )
                    : _SosDashboardTab(
                        onOpenReport: () => setState(() => _showSosReport = true),
                        onOpenStatus: () => setState(() => _currentIndex = 1),
                        onOpenNotifications: _openNotifications,
                      ),
                _TrackingStatusTab(
                  initialToken: widget.initialToken,
                  onOpenNotifications: _openNotifications,
                  onWorkshopAssigned: _onWorkshopAssigned,
                  onHistoryEvent: _onTrackingEvent,
                ),
                _ProfileTab(
                  user: displayUser,
                  onEditProfile: () => _openProfileEditor(context, displayUser),
                  onLogout: () => _signOut(context),
                  onOpenNotifications: _openNotifications,
                ),
                GarageTab(
                  onOpenNotifications: _openNotifications,
                  vehicles: _vehicles,
                  onAddVehicle: _addVehicleViaApi,
                  onEditVehicle: _editVehicleViaApi,
                  onDeleteVehicle: _deleteVehicleViaApi,
                ),
                HistoryTab(
                  onOpenNotifications: _openNotifications,
                  history: _history,
                  onLoadMore: _loadMoreHistory,
                  onFilterByCategory: _filterHistoryByCategory,
                  currentFilter: _historyFilterCategory,
                  hasMorePages: _historyPage < _historyTotalPages,
                ),
                PaymentsTab(
                  onOpenNotifications: _openNotifications,
                  assignedWorkshop: _assignedWorkshop,
                  cards: _cards,
                  onAddCard: _addCardViaApi,
                  onEditCard: _editCardViaApi,
                  onDeleteCard: _deleteCardViaApi,
                  onPay: _processPaymentViaApi,
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _ClientBottomNav(
              currentIndex: _currentIndex,
              onChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  if (index != 0) {
                    _showSosReport = false;
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
