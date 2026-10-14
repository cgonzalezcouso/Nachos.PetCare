import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:nachos_pet_care_flutter/providers/subscription_provider.dart';

class PremiumPaywallScreen extends StatelessWidget {
  const PremiumPaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subProvider = context.watch<SubscriptionProvider>();
    final isDesktop = !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A1F2C), // Deep charcoal blue
              const Color(0xFF0F111A), // Near black
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- Header Bar ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48), // Spacer
                    Text(
                      'Nachos Pet Care',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.amber[600],
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- Animated Icon & Badge ---
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.amber.withValues(alpha: 0.3), width: 2),
                          ),
                          child: const Icon(
                            Icons.workspace_premium_rounded,
                            size: 64,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- Title ---
                      Center(
                        child: Text(
                          'Pásate a Premium',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          'El plan definitivo para el cuidado de tus mascotas',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Features Card ---
                      Card(
                        color: Colors.white.withValues(alpha: 0.04),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildFeatureRow(
                                context: context,
                                icon: Icons.pets_rounded,
                                title: 'Mascotas Ilimitadas',
                                description: 'Registra y gestiona más de 2 mascotas sin límites.',
                              ),
                              const Divider(color: Colors.white12, height: 24),
                              _buildFeatureRow(
                                context: context,
                                icon: Icons.history_rounded,
                                title: 'Historial Completo',
                                description: 'Guarda más de 50 eventos históricos por mascota.',
                              ),
                              const Divider(color: Colors.white12, height: 24),
                              _buildFeatureRow(
                                context: context,
                                icon: Icons.picture_as_pdf_rounded,
                                title: 'Exportación en PDF',
                                description: 'Genera informes médicos en PDF para tu veterinario.',
                              ),
                              const Divider(color: Colors.white12, height: 24),
                              _buildFeatureRow(
                                context: context,
                                icon: Icons.cloud_done_rounded,
                                title: 'Sin límites de almacenamiento',
                                description: 'Sube fotos y seguimientos de peso ilimitados.',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // --- Pricing Information ---
                      Center(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '3,99 €',
                                  style: theme.textTheme.headlineLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 40,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '/ mes',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Renovación automática · Cancela cuando quieras',
                              style: TextStyle(color: Colors.white38, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Error Feedback ---
                      if (subProvider.error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            subProvider.error!,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // --- Subscription / Status Button ---
                      if (subProvider.isPremium) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.green, Colors.teal],
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                '¡Ya eres Premium!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: subProvider.isLoading
                              ? null
                              : () async {
                                  await subProvider.manageSubscription();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.08),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                            ),
                          ),
                          child: subProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.payment_rounded, color: Colors.amber),
                                    SizedBox(width: 8),
                                    Text(
                                      'Gestionar Suscripción',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ] else ...[
                        ElevatedButton(
                          onPressed: subProvider.isLoading
                              ? null
                              : () => _handleStripeCheckout(context, subProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[600],
                            foregroundColor: const Color(0xFF0F111A),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 8,
                            shadowColor: Colors.amber.withValues(alpha: 0.4),
                          ),
                          child: subProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F111A)),
                                  ),
                                )
                              : const Text(
                                  'Suscribirse ahora',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),

                        // --- Restore Button ---
                        TextButton(
                          onPressed: subProvider.isLoading
                              ? null
                              : () async {
                                  final success = await subProvider.restorePurchases();
                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Suscripción Stripe restaurada localmente 🎉'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                },
                          child: const Text(
                            'Restaurar Suscripción',
                            style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline),
                          ),
                        ),
                      ],

                      // --- Developer Emulator Area (Desktop / Simulación) ---
                      if (isDesktop) ...[
                        const SizedBox(height: 32),
                        const Divider(color: Colors.white12),
                        const SizedBox(height: 12),
                        Card(
                          color: Colors.amber.withValues(alpha: 0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.amber.withValues(alpha: 0.2)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.developer_mode, color: Colors.amber),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Entorno de Simulación (Escritorio)',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Stripe requiere un navegador externo para completar el pago. Activa o desactiva el Plan Premium localmente para realizar tus pruebas de integración.',
                                  style: TextStyle(color: Colors.white60, fontSize: 12),
                                ),
                                const SizedBox(height: 16),
                                SwitchListTile(
                                  value: subProvider.isPremium,
                                  activeColor: Colors.amber,
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text(
                                    'Plan Premium Activo',
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                  onChanged: (val) async {
                                    await subProvider.toggleEmulatedPremium(val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Manejar el flujo de redirección a Stripe Checkout y confirmación en la app
  Future<void> _handleStripeCheckout(BuildContext context, SubscriptionProvider provider) async {
    final success = await provider.subscribe();
    if (!success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'No se pudo abrir Stripe Checkout.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    if (!context.mounted) return;

    // Mostrar modal guiando al usuario para confirmar el pago cuando regrese
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.amber.withValues(alpha: 0.3), width: 1.5),
        ),
        title: Row(
          children: [
            Icon(Icons.payment_rounded, color: Colors.amber[600]),
            const SizedBox(width: 8),
            const Text(
              'Procesando en Stripe',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hemos abierto la pasarela de pago segura de Stripe en tu navegador.',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 12),
            Text(
              '1. Completa el pago de tu suscripción en la web de Stripe.\n'
              '2. Regresa a esta pantalla.\n'
              '3. Presiona "Confirmar Pago" para activar tus ventajas Premium de inmediato.',
              style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final restored = await provider.restorePurchases();
              if (restored && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('¡Felicidades! Ya eres Premium 🎉'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[600],
              foregroundColor: const Color(0xFF0F111A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Confirmar Pago', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.amber[600], size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
