import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/vehisos_auth_api.dart';
import '../theme/brand_colors.dart';
import '../widgets/common_widgets.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({
    super.key,
    required this.user,
    required this.sessionStore,
    required this.initialToken,
  });

  final VehiSosUser user;
  final VehiSosSessionStore sessionStore;
  final String initialToken;

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  final _api = VehiSOSAuthApi();
  late final TextEditingController _nombreController;
  late final TextEditingController _apellidosController;
  late final TextEditingController _correoController;
  late final TextEditingController _telefonoController;
  late final TextEditingController _documentoController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.user.nombre);
    _apellidosController = TextEditingController(text: widget.user.apellidos);
    _correoController = TextEditingController(text: widget.user.correo);
    _telefonoController = TextEditingController(text: widget.user.telefono ?? '');
    _documentoController = TextEditingController(text: widget.user.documentoIdentidad);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _documentoController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final nombre = _nombreController.text.trim();
    final apellidos = _apellidosController.text.trim();
    final correo = _correoController.text.trim();
    final telefono = _telefonoController.text.trim();
    final documento = _documentoController.text.trim();

    if (nombre.isEmpty || apellidos.isEmpty || correo.isEmpty || documento.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa nombres, apellidos, correo y documento.')),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final updatedUser = await _api.updateCurrentUser(
        token: widget.initialToken,
        userId: widget.user.id,
        nombre: nombre,
        apellidos: apellidos,
        correo: correo,
        telefono: telefono.isEmpty ? null : telefono,
        documentoIdentidad: documento,
      );

      await widget.sessionStore.saveSession(
        VehiSosAuthSession(token: widget.initialToken, user: updatedUser),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente.')),
      );
      Navigator.of(context).pop(updatedUser);
    } on VehiSosApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7EFED),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircularIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 18),
              Text(
                'Mi Perfil',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: BrandColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Datos del cliente para asistencia vehicular',
                style: GoogleFonts.workSans(
                  fontSize: 16,
                  color: BrandColors.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 24),
              const FieldLabel(text: 'Nombres'),
              const SizedBox(height: 10),
              EditorialTextField(controller: _nombreController, hintText: 'Nombres'),
              const SizedBox(height: 20),
              const FieldLabel(text: 'Apellidos'),
              const SizedBox(height: 10),
              EditorialTextField(controller: _apellidosController, hintText: 'Apellidos'),
              const SizedBox(height: 20),
              const FieldLabel(text: 'Correo'),
              const SizedBox(height: 10),
              EditorialTextField(
                controller: _correoController,
                hintText: 'correo@ejemplo.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              const FieldLabel(text: 'Telefono'),
              const SizedBox(height: 10),
              EditorialTextField(
                controller: _telefonoController,
                hintText: 'Telefono opcional',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              const FieldLabel(text: 'Documento'),
              const SizedBox(height: 10),
              EditorialTextField(
                controller: _documentoController,
                hintText: 'Documento de identidad',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 26),
              IgnorePointer(
                ignoring: _saving,
                child: Opacity(
                  opacity: _saving ? 0.72 : 1,
                  child: GradientActionButton(
                    label: _saving ? 'Guardando...' : 'Guardar Cambios',
                    onTap: _saveProfile,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
