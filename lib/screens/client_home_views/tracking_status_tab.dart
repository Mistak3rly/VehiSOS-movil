part of '../client_home_screen.dart';

enum _ChatMessageType { assistant, text, location, file, audio, status }

class _TrackingStatusTab extends StatefulWidget {
  const _TrackingStatusTab({
    required this.initialToken,
    required this.onOpenNotifications,
    required this.onWorkshopAssigned,
    required this.onHistoryEvent,
  });

  final String initialToken;
  final VoidCallback onOpenNotifications;
  final ValueChanged<WorkshopSuggestion> onWorkshopAssigned;
  final void Function({
    required String title,
    required String description,
    required String category,
  }) onHistoryEvent;

  @override
  State<_TrackingStatusTab> createState() => _TrackingStatusTabState();
}

class _TrackingStatusTabState extends State<_TrackingStatusTab> {
  final ClaudeWorkshopAssistantService _assistantService = ClaudeWorkshopAssistantService();
  final TextEditingController _composerController = TextEditingController();
  final FlutterSoundRecord _audioRecorder = FlutterSoundRecord();

  GoogleMapController? _mapController;

  final LatLng _fallbackLocation = const LatLng(19.4326, -99.1332);
  final List<_WorkshopSeed> _workshopSeeds = const [
    _WorkshopSeed(
      name: 'Silverstone Auto Center',
      address: 'Av. Reforma 102, Centro',
      phoneNumber: '+525511100101',
      latitude: 19.4378,
      longitude: -99.1498,
      rating: 4.9,
      priceTier: 'Premium',
      reasons: ['Fastest arrival', 'Certified tow partner', 'Open 24/7'],
    ),
    _WorkshopSeed(
      name: 'Guardian Repair Hub',
      address: 'Calle Insurgentes 880',
      phoneNumber: '+525511100202',
      latitude: 19.4285,
      longitude: -99.1388,
      rating: 4.8,
      priceTier: 'Balanced',
      reasons: ['Closest to you', 'Great price', 'Real-time status'],
    ),
    _WorkshopSeed(
      name: 'QuickTow Express',
      address: 'Calzada Sur 210',
      phoneNumber: '+525511100303',
      latitude: 19.4212,
      longitude: -99.1214,
      rating: 4.7,
      priceTier: 'Budget',
      reasons: ['Lowest cost', 'Audio updates', 'Good reviews'],
    ),
  ];

  late LatLng _currentLocation = _fallbackLocation;
  bool _loadingLocation = true;
  String _locationLabel = 'Detecting your live location...';
  WorkshopSuggestion? _selectedWorkshop;
  List<WorkshopSuggestion> _recommendedWorkshops = const [];
  final List<_ChatMessage> _messages = [];
  bool _isRecordingAudio = false;

  // Estado de la IA
  String _aiProvider = 'local';
  String? _aiModel;
  bool _isAiFallback = true;

  @override
  void initState() {
    super.initState();
    _messages.addAll([
      const _ChatMessage.assistant(
        text:
            'Hola, soy VehiSOS Assistant. Puedo ayudarte a comparar talleres, compartir tu ubicacion y enviar archivos, audio o texto al taller.',
      ),
      const _ChatMessage.status(
        text: 'Live tracking activated. The nearest workshop will be suggested below.',
      ),
    ]);
    _bootstrap();
  }

  @override
  void dispose() {
    _composerController.dispose();
    _mapController?.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _resolveLocation();
    await _refreshRecommendations();
  }

  Future<void> _resolveLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (!mounted) {
        return;
      }

      final liveLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLocation = liveLocation;
        _loadingLocation = false;
        _locationLabel =
            'Lat ${position.latitude.toStringAsFixed(4)}, Lng ${position.longitude.toStringAsFixed(4)}';
      });

      _moveCamera(liveLocation, 15.0);
      return;
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingLocation = false;
        _locationLabel = 'Using preview location while GPS is unavailable';
      });
    }
  }

  Future<void> _refreshRecommendations() async {
    final candidates = _buildCandidatesFor(_currentLocation);
    final issue = _selectedWorkshop == null ? 'Flat tire assistance' : 'Route follow-up';
    final result = await _assistantService.recommendWorkshops(
      issue: issue,
      userLatitude: _currentLocation.latitude,
      userLongitude: _currentLocation.longitude,
      candidates: candidates,
      token: widget.initialToken,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _recommendedWorkshops = result.recommendations;
      _selectedWorkshop ??=
          result.recommendations.isNotEmpty ? result.recommendations.first : null;
      _messages.add(_ChatMessage.assistant(text: result.assistantText));
      // Actualizar estado de la IA
      _aiProvider = result.provider;
      _aiModel = result.model;
      _isAiFallback = result.usedFallback;
    });

    if (_selectedWorkshop != null) {
      _moveCamera(
        LatLng(_selectedWorkshop!.latitude, _selectedWorkshop!.longitude),
        14.2,
      );
    }
  }

  List<WorkshopSuggestion> _buildCandidatesFor(LatLng userLocation) {
    return _workshopSeeds.map((seed) {
      final distanceKm = Geolocator.distanceBetween(
            userLocation.latitude,
            userLocation.longitude,
            seed.latitude,
            seed.longitude,
          ) /
          1000;

      return WorkshopSuggestion(
        name: seed.name,
        address: seed.address,
        distanceKm: distanceKm,
        rating: seed.rating,
        priceTier: seed.priceTier,
        reasons: seed.reasons,
        latitude: seed.latitude,
        longitude: seed.longitude,
        phoneNumber: seed.phoneNumber,
        isOpen: true,
      );
    }).toList(growable: false);
  }

  void _selectWorkshop(WorkshopSuggestion workshop) {
    setState(() {
      _selectedWorkshop = workshop;
      _messages.add(
        _ChatMessage.status(
          text:
              'Workshop selected: ${workshop.name}. Incident details and location were shared with the workshop.',
        ),
      );
    });

    widget.onWorkshopAssigned(workshop);
    widget.onHistoryEvent(
      title: 'Incidente enviado',
      description: 'Solicitud enviada a ${workshop.name}.',
      category: 'workshop',
    );

    _moveCamera(LatLng(workshop.latitude, workshop.longitude), 14.2);
  }

  void _sendTextMessage() {
    final text = _composerController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _messages.add(_ChatMessage.text(text: text, fromUser: true));
      _composerController.clear();
    });

    widget.onHistoryEvent(
      title: 'Mensaje enviado',
      description: 'Mensaje enviado al chat de asistencia.',
      category: 'chat',
    );

    _appendAssistantReply(text);
  }

  Future<void> _toggleAudioRecording() async {
    if (_isRecordingAudio) {
      final path = await _audioRecorder.stop();
      if (!mounted) {
        return;
      }

      setState(() {
        _isRecordingAudio = false;
      });

      if (path == null || path.isEmpty) {
        return;
      }

      setState(() {
        _messages.add(
          _ChatMessage.audio(
            filePath: path,
            fileName: path.split(RegExp(r'[\\/]')).last,
          ),
        );
        _messages.add(const _ChatMessage.status(text: 'Audio message sent to the workshop.'));
      });

      widget.onHistoryEvent(
        title: 'Audio enviado',
        description: 'Audio compartido con el taller seleccionado.',
        category: 'chat',
      );
      return;
    }

    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      if (!mounted) {
        return;
      }
      setState(() {
        _messages.add(
          const _ChatMessage.status(text: 'Microphone permission is required to send audio.'),
        );
      });
      return;
    }

    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/vehisos_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _audioRecorder.start(
      path: filePath,
      encoder: AudioEncoder.AAC,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isRecordingAudio = true;
      _messages.add(
        const _ChatMessage.status(text: 'Recording audio... tap again to send.'),
      );
    });
  }

  void _appendAssistantReply(String prompt) {
    final topWorkshop =
        _recommendedWorkshops.isNotEmpty ? _recommendedWorkshops.first : null;
    final workshopName = topWorkshop?.name ?? 'el taller mas cercano';
    final distanceLabel = topWorkshop?.distanceKm.toStringAsFixed(1) ?? '0.0';
    final reply = topWorkshop == null
        ? 'Estoy revisando talleres cercanos. En breve te muestro las mejores opciones.'
        : 'Para "$prompt" te recomiendo $workshopName, a $distanceLabel km. Puedes compartir tu ubicacion con un toque.';

    setState(() {
      _messages.add(_ChatMessage.assistant(text: reply));
    });
  }

  Future<void> _shareLocation() async {
    final label = _selectedWorkshop == null
        ? 'Ubicacion actual compartida: $_locationLabel.'
        : 'Ubicacion actual compartida con ${_selectedWorkshop!.name}: $_locationLabel.';

    setState(() {
      _messages.add(
        _ChatMessage.location(
          label: label,
          latitude: _currentLocation.latitude,
          longitude: _currentLocation.longitude,
        ),
      );
    });

    widget.onHistoryEvent(
      title: 'Ubicacion compartida',
      description: label,
      category: 'workshop',
    );
  }

  Future<void> _attachFiles({bool audioOnly = false}) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: audioOnly ? FileType.audio : FileType.any,
      withData: false,
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      for (final file in result.files) {
        final label = audioOnly ? 'Audio' : 'Archivo';
        _messages.add(
          _ChatMessage.file(
            fileName: file.name,
            label: label,
          ),
        );
      }
    });

    widget.onHistoryEvent(
      title: audioOnly ? 'Audio adjunto' : 'Archivo adjunto',
      description: 'Se enviaron ${result.files.length} archivo(s) al chat.',
      category: 'chat',
    );
  }

  Future<void> _callSelectedWorkshop() async {
    final phone = _selectedWorkshop?.phoneNumber;
    if (phone == null || phone.isEmpty) {
      setState(() {
        _messages.add(
          const _ChatMessage.status(
            text: 'El taller seleccionado no tiene numero disponible para llamada.',
          ),
        );
      });
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);
    final launched = await launchUrl(uri);
    if (!mounted) {
      return;
    }

    if (launched) {
      widget.onHistoryEvent(
        title: 'Llamada al taller',
        description: 'Llamada iniciada a ${_selectedWorkshop!.name} ($phone).',
        category: 'workshop',
      );
      setState(() {
        _messages.add(_ChatMessage.status(text: 'Calling ${_selectedWorkshop!.name} at $phone...'));
      });
    } else {
      setState(() {
        _messages.add(
          const _ChatMessage.status(
            text: 'No se pudo iniciar la llamada en este dispositivo.',
          ),
        );
      });
    }
  }

  Future<void> _useAssistantForSuggestions() async {
    await _refreshRecommendations();
  }

  Future<void> _moveCamera(LatLng target, double zoom) async {
    final controller = _mapController;
    if (controller == null) {
      return;
    }

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  void _focusUserLocation() {
    _moveCamera(_currentLocation, 15.0);
  }

  @override
  Widget build(BuildContext context) {
    final mapMarkers = <Marker>{
      Marker(
        markerId: const MarkerId('user-location'),
        position: _currentLocation,
        infoWindow: const InfoWindow(title: 'Tu ubicacion actual'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
      ..._recommendedWorkshops.take(3).map(
            (workshop) => Marker(
              markerId: MarkerId('workshop-${workshop.name}'),
              position: LatLng(workshop.latitude, workshop.longitude),
              infoWindow: InfoWindow(
                title: workshop.name,
                snippet: '${workshop.distanceKm.toStringAsFixed(1)} km',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                _selectedWorkshop?.name == workshop.name
                    ? BitmapDescriptor.hueAzure
                    : BitmapDescriptor.hueViolet,
              ),
            ),
          ),
    };

    final mapPolylines = <Polyline>{
      if (_selectedWorkshop != null)
        Polyline(
          polylineId: const PolylineId('selected-route'),
          points: [
            _currentLocation,
            LatLng(_selectedWorkshop!.latitude, _selectedWorkshop!.longitude),
          ],
          width: 5,
          color: BrandColors.primary.withValues(alpha: 0.72),
        ),
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3F2),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(bottom: 280 + MediaQuery.of(context).padding.bottom),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF6E6A77)),
                  ),
                  const Spacer(),
                  Text(
                    'Tracking Assistance',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 39 * 0.56,
                      color: const Color(0xFF6E6A77),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: widget.onOpenNotifications,
                    icon: const Icon(Icons.notifications_rounded, color: Color(0xFF6E6A77)),
                  ),
                ],
              ),
            ),
            // AI Provider Status Badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildAIStatusBadge(),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(color: Color(0x14291714), blurRadius: 24, offset: Offset(0, 10)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBECE8),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.gps_fixed_rounded, color: BrandColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _loadingLocation ? 'Detecting your live location...' : _locationLabel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: BrandColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your location is shared only when you tap the share button.',
                            style: GoogleFonts.workSans(
                              fontSize: 13,
                              color: BrandColors.onSurface.withValues(alpha: 0.68),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _focusUserLocation,
                      icon: const Icon(Icons.center_focus_strong_rounded, color: BrandColors.primary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: SizedBox(
                  height: 265,
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _currentLocation,
                          zoom: 15,
                        ),
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        markers: mapMarkers,
                        polylines: mapPolylines,
                        zoomControlsEnabled: false,
                        myLocationEnabled: false,
                        compassEnabled: true,
                        mapToolbarEnabled: true,
                      ),
                      Positioned(
                        left: 16,
                        top: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'LIVE MAP',
                            style: GoogleFonts.workSans(
                              fontWeight: FontWeight.w800,
                              color: BrandColors.primary,
                              letterSpacing: 2.2,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 16,
                        top: 16,
                        child: Column(
                          children: [
                            _MapActionChip(
                              icon: Icons.my_location_rounded,
                              label: 'Locate me',
                              onTap: _focusUserLocation,
                            ),
                            const SizedBox(height: 10),
                            _MapActionChip(
                              icon: Icons.share_location_rounded,
                              label: 'Share',
                              onTap: _shareLocation,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionPill(
                      icon: Icons.auto_awesome_rounded,
                      label: 'Ask assistant',
                      onTap: _useAssistantForSuggestions,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionPill(
                      icon: Icons.file_copy_rounded,
                      label: 'Attach file',
                      onTap: _attachFiles,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionPill(
                      icon: _isRecordingAudio ? Icons.stop_rounded : Icons.mic_rounded,
                      label: _isRecordingAudio ? 'Stop audio' : 'Send audio',
                      onTap: _toggleAudioRecording,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _RecommendationsPanel(
                workshops: _recommendedWorkshops,
                selectedWorkshop: _selectedWorkshop,
                onSelectWorkshop: _selectWorkshop,
              ),
            ),
            if (_selectedWorkshop?.phoneNumber != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDECE9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF0D5D0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Numero del taller asignado',
                              style: GoogleFonts.workSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: BrandColors.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_selectedWorkshop!.name} • ${_selectedWorkshop!.phoneNumber}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: BrandColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _ActionPill(
                        icon: Icons.mic_rounded,
                        label: 'Audio',
                        onTap: _toggleAudioRecording,
                      ),
                      const SizedBox(width: 8),
                      _ActionPill(
                        icon: Icons.call_rounded,
                        label: 'Llamar',
                        onTap: _callSelectedWorkshop,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                height: 420,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(color: Color(0x14291714), blurRadius: 24, offset: Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFBECE8),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.support_agent_rounded, color: BrandColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'VehiSOS Assistant',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: BrandColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'I can route your request to the best workshop and share your location.',
                                    style: GoogleFonts.workSans(
                                      fontSize: 12,
                                      color: BrandColors.onSurface.withValues(alpha: 0.65),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            return _ChatBubble(message: message);
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8F3F2),
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 260),
                              child: _isRecordingAudio
                                  ? Container(
                                      key: const ValueKey('recording-indicator'),
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFECE9),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: const Color(0xFFFFCDC6)),
                                      ),
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.2,
                                              valueColor: AlwaysStoppedAnimation<Color>(BrandColors.primary),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'Grabando audio... toca "Stop audio" para enviarlo',
                                              style: GoogleFonts.workSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: BrandColors.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _ComposerIconButton(
                                  icon: Icons.attach_file_rounded,
                                  onTap: _attachFiles,
                                ),
                                const SizedBox(width: 8),
                                _ComposerIconButton(
                                  icon: Icons.location_on_rounded,
                                  onTap: _shareLocation,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: const Color(0xFFE9D8D4)),
                                    ),
                                    child: TextField(
                                      controller: _composerController,
                                      minLines: 1,
                                      maxLines: 4,
                                      textInputAction: TextInputAction.send,
                                      onSubmitted: (_) => _sendTextMessage(),
                                      decoration: InputDecoration.collapsed(
                                        hintText: 'Message the workshop or assistant...',
                                        hintStyle: GoogleFonts.workSans(
                                          color: BrandColors.onSurface.withValues(alpha: 0.45),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: _sendTextMessage,
                                  child: Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      gradient: BrandColors.ctaGradient,
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x30BB000E),
                                          blurRadius: 14,
                                          offset: Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.send_rounded, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  // Widget para mostrar el estado de la IA (OpenAI, Claude o Local)
  Widget _buildAIStatusBadge() {
    final bool isRealAI = !_isAiFallback && _aiProvider != 'local';

    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData icon;
    String providerName;
    String subtitle;

    if (isRealAI) {
      switch (_aiProvider.toLowerCase()) {
        case 'openai':
          bgColor = const Color(0xFFE3F2FD);
          borderColor = const Color(0xFF90CAF9);
          textColor = const Color(0xFF1565C0);
          icon = Icons.psychology;
          providerName = 'OpenAI';
          subtitle = _aiModel ?? 'GPT';
          break;
        case 'anthropic':
        case 'claude':
          bgColor = const Color(0xFFF3E5F5);
          borderColor = const Color(0xFFCE93D8);
          textColor = const Color(0xFF7B1FA2);
          icon = Icons.auto_fix_high;
          providerName = 'Claude';
          subtitle = _aiModel ?? 'Anthropic';
          break;
        default:
          bgColor = const Color(0xFFE8F5E9);
          borderColor = const Color(0xFFA5D6A7);
          textColor = const Color(0xFF2E7D32);
          icon = Icons.smart_toy;
          providerName = 'IA Real';
          subtitle = _aiModel ?? _aiProvider;
      }
    } else {
      // Modo local/fallback
      bgColor = const Color(0xFFFFF3E0);
      borderColor = const Color(0xFFFFCC80);
      textColor = const Color(0xFFEF6C00);
      icon = Icons.computer;
      providerName = 'Modo Local';
      subtitle = 'Sin conexión a IA';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: borderColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: textColor,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isRealAI ? '🤖 $providerName' : '💻 $providerName',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              Text(
                isRealAI ? 'Respuestas generadas por IA real' : subtitle,
                style: GoogleFonts.workSans(
                  fontSize: 11,
                  color: textColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
          if (isRealAI) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WorkshopSeed {
  const _WorkshopSeed({
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.priceTier,
    required this.reasons,
  });

  final String name;
  final String address;
  final String phoneNumber;
  final double latitude;
  final double longitude;
  final double rating;
  final String priceTier;
  final List<String> reasons;
}

class _ChatMessage {
  const _ChatMessage._({
    required this.type,
    required this.text,
    required this.fromUser,
    this.latitude,
    this.longitude,
    this.fileName,
    this.label,
  });

  const _ChatMessage.assistant({required String text})
      : this._(type: _ChatMessageType.assistant, text: text, fromUser: false);

  const _ChatMessage.text({required String text, required bool fromUser})
      : this._(type: _ChatMessageType.text, text: text, fromUser: fromUser);

  const _ChatMessage.location({
    required String label,
    required double latitude,
    required double longitude,
  }) : this._(
          type: _ChatMessageType.location,
          text: label,
          fromUser: true,
          latitude: latitude,
          longitude: longitude,
        );

  const _ChatMessage.audio({required String filePath, required String fileName})
      : this._(
          type: _ChatMessageType.audio,
          text: fileName,
          fromUser: true,
          fileName: fileName,
          label: filePath,
        );

  const _ChatMessage.file({required String fileName, required String label})
      : this._(
          type: _ChatMessageType.file,
          text: fileName,
          fromUser: true,
          fileName: fileName,
          label: label,
        );

  const _ChatMessage.status({required String text})
      : this._(type: _ChatMessageType.status, text: text, fromUser: false);

  final _ChatMessageType type;
  final String text;
  final bool fromUser;
  final double? latitude;
  final double? longitude;
  final String? fileName;
  final String? label;
}

class _RecommendationsPanel extends StatelessWidget {
  const _RecommendationsPanel({
    required this.workshops,
    required this.selectedWorkshop,
    required this.onSelectWorkshop,
  });

  final List<WorkshopSuggestion> workshops;
  final WorkshopSuggestion? selectedWorkshop;
  final ValueChanged<WorkshopSuggestion> onSelectWorkshop;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF7F5),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFF1DDD8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Best workshop recommendations',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: BrandColors.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                'AI ranked',
                style: GoogleFonts.workSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: BrandColors.primary,
                  letterSpacing: 1.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 178,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: workshops.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final workshop = workshops[index];
                final isSelected = selectedWorkshop?.name == workshop.name;
                final workshopRating = workshop.rating.toStringAsFixed(1);
                final distanceText = workshop.distanceKm.toStringAsFixed(1);

                return GestureDetector(
                  onTap: () => onSelectWorkshop(workshop),
                  child: Container(
                    width: 230,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF6D6D1) : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isSelected ? BrandColors.primary : const Color(0xFFE9DDD9),
                        width: isSelected ? 1.6 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                workshop.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: BrandColors.onSurface,
                                ),
                              ),
                            ),
                            Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: isSelected
                                  ? BrandColors.primary
                                  : BrandColors.onSurface.withValues(alpha: 0.38),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          workshop.address,
                          style: GoogleFonts.workSans(
                            fontSize: 12,
                            height: 1.35,
                            color: BrandColors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFC26A00), size: 18),
                            const SizedBox(width: 4),
                            Text(
                              workshopRating,
                              style: GoogleFonts.workSans(
                                fontWeight: FontWeight.w800,
                                color: BrandColors.onSurface,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.route_rounded,
                              color: BrandColors.primary.withValues(alpha: 0.8),
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$distanceText km',
                              style: GoogleFonts.workSans(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: workshop.reasons
                              .take(2)
                              .map(
                                (reason) => Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    reason,
                                    style: GoogleFonts.workSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: BrandColors.onSurface.withValues(alpha: 0.72),
                                    ),
                                  ),
                                ),
                              )
                              .toList(growable: false),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            isSelected ? 'Selected' : 'Tap to choose',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? BrandColors.primary
                                  : BrandColors.onSurface.withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.fromUser;
    final bubbleColor = isUser ? const Color(0xFFF6D6D1) : const Color(0xFFFDF7F5);
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: alignment,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFECE0DC)),
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (message.type) {
      case _ChatMessageType.assistant:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.support_agent_rounded, size: 16, color: BrandColors.primary),
                const SizedBox(width: 6),
                Text(
                  'VehiSOS Assistant',
                  style: GoogleFonts.workSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: BrandColors.primary,
                    letterSpacing: 1.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              message.text,
              style: GoogleFonts.workSans(
                fontSize: 14,
                height: 1.45,
                color: BrandColors.onSurface,
              ),
            ),
          ],
        );
      case _ChatMessageType.location:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on_rounded, color: BrandColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Live location shared',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: BrandColors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              message.text,
              style: GoogleFonts.workSans(
                fontSize: 13,
                height: 1.45,
                color: BrandColors.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${message.latitude!.toStringAsFixed(4)}, ${message.longitude!.toStringAsFixed(4)}',
              style: GoogleFonts.workSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: BrandColors.primary,
              ),
            ),
          ],
        );
      case _ChatMessageType.file:
        return Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                message.label == 'Audio' ? Icons.graphic_eq_rounded : Icons.description_rounded,
                color: BrandColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${message.label} attached',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: BrandColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.text,
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      color: BrandColors.onSurface.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case _ChatMessageType.audio:
        return _AudioBubble(filePath: message.label ?? '', fileName: message.fileName ?? 'Audio message');
      case _ChatMessageType.status:
        return Text(
          message.text,
          style: GoogleFonts.workSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: BrandColors.onSurface.withValues(alpha: 0.76),
            height: 1.4,
          ),
        );
      case _ChatMessageType.text:
        return Text(
          message.text,
          style: GoogleFonts.workSans(
            fontSize: 14,
            height: 1.45,
            color: BrandColors.onSurface,
          ),
        );
    }
  }
}

class _MapActionChip extends StatelessWidget {
  const _MapActionChip({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: BrandColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.workSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: BrandColors.onSurface,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF7F5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8DAD6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: BrandColors.primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.workSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: BrandColors.onSurface,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComposerIconButton extends StatelessWidget {
  const _ComposerIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9D8D4)),
        ),
        child: Icon(icon, color: BrandColors.primary, size: 20),
      ),
    );
  }
}

class _AudioBubble extends StatefulWidget {
  const _AudioBubble({required this.filePath, required this.fileName});

  final String filePath;
  final String fileName;

  @override
  State<_AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<_AudioBubble> {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_playing) {
      await _player.pause();
      if (mounted) {
        setState(() => _playing = false);
      }
      return;
    }

    await _player.stop();
    setState(() => _playing = true);
    await _player.play(DeviceFileSource(widget.filePath));
    await _player.onPlayerComplete.first;
    if (mounted) {
      setState(() => _playing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF7F5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFECE0DC)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _togglePlayback,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: BrandColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Audio message',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: BrandColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.fileName,
                  style: GoogleFonts.workSans(
                    fontSize: 12,
                    color: BrandColors.onSurface.withValues(alpha: 0.72),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
