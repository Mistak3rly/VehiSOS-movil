import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/brand_colors.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.isLight = false});

  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final iconColor = isLight ? Colors.white : Colors.white;
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: isLight ? Colors.white.withValues(alpha: 0.12) : BrandColors.primary,
      ),
      child: Center(
        child: Icon(
          Icons.wifi_tethering_rounded,
          color: iconColor,
          size: 34,
        ),
      ),
    );
  }
}

class RoadsideBackdrop extends StatelessWidget {
  const RoadsideBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF584229),
                Color(0xFFB47626),
                Color(0xFF5A2A1D),
              ],
            ),
          ),
        ),
        Positioned(
          left: -70,
          bottom: 250,
          child: Container(
            width: 300,
            height: 300,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0xFFE5B65A), Color(0x00E5B65A)],
              ),
            ),
          ),
        ),
        Positioned(
          right: -24,
          bottom: 50,
          child: Icon(
            Icons.local_shipping_rounded,
            size: 300,
            color: Colors.black.withValues(alpha: 0.25),
          ),
        ),
        Positioned(
          left: -30,
          bottom: 20,
          child: Icon(
            Icons.directions_car_filled_rounded,
            size: 280,
            color: Colors.black.withValues(alpha: 0.28),
          ),
        ),
      ],
    );
  }
}

class GradientActionButton extends StatefulWidget {
  const GradientActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.compact = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool compact;

  @override
  State<GradientActionButton> createState() => _GradientActionButtonState();
}

class _GradientActionButtonState extends State<GradientActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = widget.compact ? 52.0 : 82.0;
    final textSize = widget.compact ? 26 * 0.62 : 40 * 0.58;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        height: buttonHeight,
        decoration: BoxDecoration(
          gradient: _pressed ? BrandColors.ctaGradientPressed : BrandColors.ctaGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14291714),
              offset: Offset(0, 12),
              blurRadius: 32,
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: textSize,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (widget.icon != null) ...[
                const SizedBox(width: 8),
                Icon(widget.icon, color: Colors.white, size: widget.compact ? 18 : 26),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class GlassSecondaryButton extends StatelessWidget {
  const GlassSecondaryButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Material(
          color: const Color(0x66EFE2DE),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 82,
              child: Center(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 40 * 0.58,
                    color: Colors.white.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EditorialTextField extends StatefulWidget {
  const EditorialTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.compact = false,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool compact;

  @override
  State<EditorialTextField> createState() => _EditorialTextFieldState();
}

class _EditorialTextFieldState extends State<EditorialTextField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;
    final height = widget.compact ? 42.0 : 68.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFFF1D5D0),
        boxShadow: [
          if (isFocused)
            BoxShadow(
              color: BrandColors.primary.withValues(alpha: 0.20),
              blurRadius: 0,
              spreadRadius: 2,
            ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        focusNode: _focusNode,
        style: GoogleFonts.workSans(
          fontSize: widget.compact ? 13 : 18,
          fontWeight: FontWeight.w500,
          color: BrandColors.onSurface,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: widget.hintText,
          hintStyle: GoogleFonts.workSans(
            color: const Color(0xC7D7A7A0),
            fontSize: widget.compact ? 13 : 18,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: widget.compact ? 8 : 16),
        ),
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel({super.key, required this.text, this.isCompact = false});

  final String text;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.workSans(
        color: BrandColors.onSurface.withValues(alpha: 0.88),
        fontSize: isCompact ? 10 : 34 * 0.45,
        letterSpacing: isCompact ? 1.8 : 0,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class CircularIconButton extends StatelessWidget {
  const CircularIconButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.5),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 68,
          height: 68,
          child: Icon(icon, color: BrandColors.onSurface, size: 34 * 0.7),
        ),
      ),
    );
  }
}

class SocialChip extends StatelessWidget {
  const SocialChip({super.key, required this.label, this.compact = false});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 38.0 : 74.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(compact ? 10 : 18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C291714),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: compact ? 11 : 20,
          color: BrandColors.onSurface,
        ),
      ),
    );
  }
}

class BottomMetaItem extends StatelessWidget {
  const BottomMetaItem({super.key, this.icon, required this.label});

  final IconData? icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: Colors.white.withValues(alpha: 0.72), size: 19),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: GoogleFonts.workSans(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 40 * 0.46,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
