import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nachos_pet_care_flutter/models/marketplace_product.dart';

class AffiliateRedirectDialog extends StatefulWidget {
  final MarketplaceProduct product;

  const AffiliateRedirectDialog({
    super.key,
    required this.product,
  });

  @override
  State<AffiliateRedirectDialog> createState() => _AffiliateRedirectDialogState();
}

class _AffiliateRedirectDialogState extends State<AffiliateRedirectDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  Timer? _timer;
  int _secondsLeft = 3;
  bool _isRedirecting = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _progressController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsLeft > 1) {
            _secondsLeft--;
          } else {
            _timer?.cancel();
            _secondsLeft = 0;
            _performRedirect();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _performRedirect() async {
    if (_isRedirecting) return;
    setState(() {
      _isRedirecting = true;
    });

    final url = Uri.parse(widget.product.affiliateUrl);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'No se pudo abrir la URL';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo redirigir automáticamente a ${widget.product.source}. Enlace: ${widget.product.affiliateUrl}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Color _getSourceColor(String source) {
    switch (source.toLowerCase()) {
      case 'amazon':
        return Colors.orange;
      case 'kiwoko':
        return Colors.deepOrangeAccent;
      case 'tiendanimal':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sourceColor = _getSourceColor(widget.product.source);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 8,
      backgroundColor: colorScheme.surface,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Visual: Secure connection
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(Icons.pets, size: 28, color: colorScheme.primary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          final value = _progressController.value;
                          final highlightIndex = (value * 5).floor();
                          final isHighlighted = index == highlightIndex;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isHighlighted ? colorScheme.primary : colorScheme.outlineVariant,
                              shape: BoxShape.circle,
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: sourceColor.withValues(alpha: 0.15),
                  child: Icon(
                    widget.product.source.toLowerCase() == 'amazon' 
                        ? Icons.shopping_cart_outlined 
                        : Icons.storefront_outlined,
                    size: 28,
                    color: sourceColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Redirigiendo a ${widget.product.source}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.product.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Countdown Indicator
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: _progressController.value,
                    strokeWidth: 6,
                    backgroundColor: colorScheme.outlineVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_secondsLeft',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      'segundos',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Commission info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.volunteer_activism_outlined, size: 18, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Soporte a NachosPetCare',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.product.commissionPercentage}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Esta compra genera una comisión de de afiliación estimada de \$${widget.product.commissionAmount.toStringAsFixed(2)} para ayudar a financiar el mantenimiento de la aplicación. ¡No tiene ningún costo adicional para ti!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.4,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _timer?.cancel();
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _performRedirect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Ir ahora'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
