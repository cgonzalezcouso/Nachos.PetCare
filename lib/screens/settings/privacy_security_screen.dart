import 'package:flutter/material.dart';
import 'package:nachos_pet_care_flutter/l10n/app_strings.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _biometricActive = false;
  bool _twoFactorActive = false;
  bool _locationSharingActive = true;
  bool _analyticsSharingActive = true;
  String _profileVisibility = 'Veterinarios'; // 'Público', 'Veterinarios', 'Privado'

  void _showChangePasswordDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final passController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.vpn_key_outlined, color: colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Cambiar Contraseña'),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: passController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña Actual',
                    prefixIcon: Icon(Icons.lock_open),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Introduce tu contraseña actual' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newPassController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nueva Contraseña',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Introduce la nueva contraseña';
                    if (v.length < 6) return 'Debe tener al menos 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (v) {
                    if (v != newPassController.text) return 'Las contraseñas no coinciden';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contraseña actualizada con éxito'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  void _showVisibilitySelector() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visibilidad del Perfil',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Decide quién puede ver el perfil de tus mascotas, vacunas e historial.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    RadioListTile<String>(
                      title: const Text('Público'),
                      subtitle: const Text('Cualquier usuario de la red Nachos puede ver a tus mascotas.'),
                      value: 'Público',
                      groupValue: _profileVisibility,
                      onChanged: (val) {
                        setState(() => _profileVisibility = val!);
                        setModalState(() {});
                        Navigator.pop(ctx);
                        _showSuccessToast('Visibilidad actualizada a Público');
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Solo Veterinarios'),
                      subtitle: const Text('Solo clínicas y profesionales autorizados por ti pueden ver el historial.'),
                      value: 'Veterinarios',
                      groupValue: _profileVisibility,
                      onChanged: (val) {
                        setState(() => _profileVisibility = val!);
                        setModalState(() {});
                        Navigator.pop(ctx);
                        _showSuccessToast('Visibilidad actualizada a Solo Veterinarios');
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Privado'),
                      subtitle: const Text('Solo tú puedes acceder y ver la información del perfil.'),
                      value: 'Privado',
                      groupValue: _profileVisibility,
                      onChanged: (val) {
                        setState(() => _profileVisibility = val!);
                        setModalState(() {});
                        Navigator.pop(ctx);
                        _showSuccessToast('Visibilidad actualizada a Privado');
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _exportUserData() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text('Preparando copia de seguridad de datos (JSON/PDF)...')),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.download_done_rounded, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Exportación Completa'),
                ],
              ),
              content: const Text(
                'Tu paquete de privacidad de datos personales e historial clínico ha sido generado y enviado a tu correo electrónico registrado. ¡Gracias por confiar en NachosPetCare!',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Entendido'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  void _showDeleteAccountDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: colorScheme.error),
              const SizedBox(width: 8),
              Text('¿Eliminar tu Cuenta?', style: TextStyle(color: colorScheme.error)),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¡Atención! Esta acción es definitiva e irreversible. Se borrarán permanentemente:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('• El perfil de todas tus mascotas.\n• Todos los historiales de vacunación y citas.\n• Tus credenciales de acceso.'),
                const SizedBox(height: 16),
                const Text('Para confirmar, escribe "ELIMINAR" a continuación:'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: confirmController,
                  decoration: InputDecoration(
                    hintText: 'ELIMINAR',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (v) => v != 'ELIMINAR' ? 'Debes escribir ELIMINAR para continuar' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(ctx);
                  _showSuccessToast('Cuenta eliminada correctamente (simulado)');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Eliminar Definitivamente'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final strings = AppStrings.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(strings.privacySecurity),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── SEGURIDAD ACCESO ────────────────────────────────────────────────
          _SectionHeader(title: 'Seguridad de la Cuenta'),
          ListTile(
            leading: Icon(Icons.vpn_key_outlined, color: colorScheme.primary),
            title: const Text('Cambiar Contraseña'),
            subtitle: const Text('Actualiza tus credenciales periódicamente'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showChangePasswordDialog,
          ),
          SwitchListTile(
            title: const Text('Autenticación Biométrica'),
            subtitle: const Text('Usa huella o reconocimiento facial para acceder'),
            secondary: Icon(Icons.fingerprint, color: colorScheme.primary),
            value: _biometricActive,
            onChanged: (v) {
              setState(() => _biometricActive = v);
              _showSuccessToast(v ? 'Biometría activada' : 'Biometría desactivada');
            },
          ),
          SwitchListTile(
            title: const Text('Verificación en dos pasos (2FA)'),
            subtitle: const Text('Añade un nivel extra de seguridad al iniciar sesión'),
            secondary: Icon(Icons.security, color: colorScheme.primary),
            value: _twoFactorActive,
            onChanged: (v) {
              setState(() => _twoFactorActive = v);
              _showSuccessToast(v ? 'Autenticación 2FA activada' : 'Autenticación 2FA desactivada');
            },
          ),

          const Divider(height: 32),

          // ── PRIVACIDAD DATOS ───────────────────────────────────────────────
          _SectionHeader(title: 'Privacidad de Datos'),
          ListTile(
            leading: Icon(Icons.visibility_outlined, color: colorScheme.primary),
            title: const Text('Visibilidad del Perfil'),
            subtitle: Text(_profileVisibility),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showVisibilitySelector,
          ),
          SwitchListTile(
            title: const Text('Compartir Ubicación'),
            subtitle: const Text('Necesario para encontrar clínicas de urgencia cercanas'),
            secondary: Icon(Icons.my_location, color: colorScheme.primary),
            value: _locationSharingActive,
            onChanged: (v) {
              setState(() => _locationSharingActive = v);
              _showSuccessToast(v ? 'Acceso a ubicación permitido' : 'Acceso a ubicación desactivado');
            },
          ),
          SwitchListTile(
            title: const Text('Analíticas y Diagnósticos'),
            subtitle: const Text('Envía informes de fallos y telemetría para mejorar la app'),
            secondary: Icon(Icons.analytics_outlined, color: colorScheme.primary),
            value: _analyticsSharingActive,
            onChanged: (v) {
              setState(() => _analyticsSharingActive = v);
              _showSuccessToast(v ? 'Envío de analíticas permitido' : 'Envío de analíticas denegado');
            },
          ),

          const Divider(height: 32),

          // ── GDPR & GESTIÓN DE DATOS ────────────────────────────────────────
          _SectionHeader(title: 'Gestión de tu Información'),
          ListTile(
            leading: Icon(Icons.download_for_offline_outlined, color: colorScheme.primary),
            title: const Text('Exportar mis Datos (GDPR)'),
            subtitle: const Text('Descarga una copia completa de tus mascotas e historial'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _exportUserData,
          ),

          const Divider(height: 32),

          // ── ZONA DE PELIGRO ────────────────────────────────────────────────
          _SectionHeader(title: 'Zona de Peligro'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: colorScheme.errorContainer.withValues(alpha: 0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colorScheme.error.withValues(alpha: 0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: colorScheme.error),
                      const SizedBox(width: 12),
                      Text(
                        'Acción Destructiva',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Si decides eliminar tu cuenta, todos tus registros de mascotas, vacunas y visitas veterinarias se borrarán de forma irrevocable.',
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showDeleteAccountDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size.fromHeight(42),
                    ),
                    child: const Text(
                      'Eliminar Cuenta permanentemente',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
