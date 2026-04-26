import 'package:flutter/material.dart';
import '../theme/brand_colors.dart';

/// Widget que muestra un badge indicando qué proveedor de IA se está usando
class AIProviderBadge extends StatelessWidget {
  final String provider;
  final String? model;
  final bool isFallback;

  const AIProviderBadge({
    super.key,
    required this.provider,
    this.model,
    this.isFallback = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getBorderColor(),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getIcon(),
          const SizedBox(width: 6),
          Text(
            _getLabel(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
          if (model != null && model!.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              '• $model',
              style: TextStyle(
                fontSize: 10,
                color: _getTextColor().withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _getIcon() {
    final iconData = switch (provider.toLowerCase()) {
      'openai' => Icons.psychology,
      'anthropic' || 'claude' => Icons.auto_fix_high,
      _ => Icons.computer,
    };

    return Icon(
      iconData,
      size: 14,
      color: _getTextColor(),
    );
  }

  String _getLabel() {
    if (isFallback) {
      return 'Modo Local';
    }
    return switch (provider.toLowerCase()) {
      'openai' => 'OpenAI',
      'anthropic' || 'claude' => 'Claude',
      _ => 'Local',
    };
  }

  Color _getBackgroundColor() {
    if (isFallback) {
      return const Color(0xFFFFF3E0); // Naranja claro para fallback
    }
    return switch (provider.toLowerCase()) {
      'openai' => const Color(0xFFE3F2FD), // Azul claro
      'anthropic' || 'claude' => const Color(0xFFF3E5F5), // Púrpura claro
      _ => const Color(0xFFE8E8E8), // Gris
    };
  }

  Color _getBorderColor() {
    if (isFallback) {
      return const Color(0xFFFFCC80);
    }
    return switch (provider.toLowerCase()) {
      'openai' => const Color(0xFF90CAF9),
      'anthropic' || 'claude' => const Color(0xFFCE93D8),
      _ => const Color(0xFFBDBDBD),
    };
  }

  Color _getTextColor() {
    if (isFallback) {
      return const Color(0xFFE65100);
    }
    return switch (provider.toLowerCase()) {
      'openai' => const Color(0xFF1565C0),
      'anthropic' || 'claude' => const Color(0xFF7B1FA2),
      _ => const Color(0xFF616161),
    };
  }
}

/// Widget para mostrar el mensaje del asistente IA con estilo destacado
class AssistantMessageBubble extends StatelessWidget {
  final String text;
  final String provider;
  final bool isFallback;

  const AssistantMessageBubble({
    super.key,
    required this.text,
    required this.provider,
    this.isFallback = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getGradientColors(),
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getBorderColor(),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _getProviderIcon(),
              const SizedBox(width: 8),
              Text(
                'Asistente ${_getProviderName()}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _getTextColor(),
                ),
              ),
              if (isFallback) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Local',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: _getTextColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getProviderIcon() {
    final iconData = switch (provider.toLowerCase()) {
      'openai' => Icons.psychology,
      'anthropic' || 'claude' => Icons.auto_fix_high,
      _ => Icons.computer,
    };

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _getIconBackgroundColor(),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: 16,
        color: _getIconColor(),
      ),
    );
  }

  String _getProviderName() {
    return switch (provider.toLowerCase()) {
      'openai' => 'OpenAI',
      'anthropic' || 'claude' => 'Claude',
      _ => 'VehiSOS',
    };
  }

  List<Color> _getGradientColors() {
    if (isFallback) {
      return [
        const Color(0xFFFFF8E1),
        const Color(0xFFFFECB3),
      ];
    }
    return switch (provider.toLowerCase()) {
      'openai' => [
          const Color(0xFFE3F2FD),
          const Color(0xFFBBDEFB),
        ],
      'anthropic' || 'claude' => [
          const Color(0xFFF3E5F5),
          const Color(0xFFE1BEE7),
        ],
      _ => [
          const Color(0xFFF5F5F5),
          const Color(0xFFE0E0E0),
        ],
    };
  }

  Color _getBorderColor() {
    if (isFallback) {
      return const Color(0xFFFFCC80);
    }
    return switch (provider.toLowerCase()) {
      'openai' => const Color(0xFF90CAF9),
      'anthropic' || 'claude' => const Color(0xFFCE93D8),
      _ => const Color(0xFFBDBDBD),
    };
  }

  Color _getTextColor() {
    if (isFallback) {
      return const Color(0xFF5D4037);
    }
    return switch (provider.toLowerCase()) {
      'openai' => const Color(0xFF0D47A1),
      'anthropic' || 'claude' => const Color(0xFF4A148C),
      _ => const Color(0xFF212121),
    };
  }

  Color _getIconBackgroundColor() {
    if (isFallback) {
      return const Color(0xFFFFCC80);
    }
    return switch (provider.toLowerCase()) {
      'openai' => const Color(0xFF90CAF9),
      'anthropic' || 'claude' => const Color(0xFFCE93D8),
      _ => const Color(0xFFBDBDBD),
    };
  }

  Color _getIconColor() {
    if (isFallback) {
      return const Color(0xFFE65100);
    }
    return switch (provider.toLowerCase()) {
      'openai' => const Color(0xFF1565C0),
      'anthropic' || 'claude' => const Color(0xFF7B1FA2),
      _ => const Color(0xFF424242),
    };
  }
}
