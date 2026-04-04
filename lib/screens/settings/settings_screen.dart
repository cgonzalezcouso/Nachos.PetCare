import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nachos_pet_care_flutter/providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Configuración'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── APARIENCIA ─────────────────────────────────────────────────────
          _SectionHeader(title: 'Apariencia'),

          // Banner visual del modo activo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: _ThemeSelectorCard(themeProvider: themeProvider),
          ),

          const Divider(height: 32),

          // ── NOTIFICACIONES ─────────────────────────────────────────────────
          _SectionHeader(title: 'Notificaciones'),
          SwitchListTile(
            title: const Text('Notificaciones push'),
            subtitle: const Text('Recibir alertas y recordatorios'),
            secondary: Icon(
              _notificationsEnabled
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
              color: colorScheme.primary,
            ),
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),

          const Divider(height: 32),

          // ── CUENTA ─────────────────────────────────────────────────────────
          _SectionHeader(title: 'Cuenta'),
          ListTile(
            leading: Icon(Icons.lock_outline, color: colorScheme.primary),
            title: const Text('Privacidad y Seguridad'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.language, color: colorScheme.primary),
            title: const Text('Idioma'),
            subtitle: const Text('Español'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          const Divider(height: 32),

          // ── INFORMACIÓN ────────────────────────────────────────────────────
          _SectionHeader(title: 'Información'),
          ListTile(
            leading:
                Icon(Icons.info_outline, color: colorScheme.primary),
            title: const Text('Sobre NachosPetCare'),
            subtitle: const Text('Versión 1.0.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'NachosPetCare',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2026 NachosPetCare',
                children: [
                  const Text('Tu compañero para el cuidado de mascotas.'),
                ],
              );
            },
          ),
          ListTile(
            leading:
                Icon(Icons.description_outlined, color: colorScheme.primary),
            title: const Text('Términos y Condiciones'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () {},
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Selector de tema ─────────────────────────────────────────────────────────

class _ThemeSelectorCard extends StatelessWidget {
  final ThemeProvider themeProvider;
  const _ThemeSelectorCard({required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final isSystem = themeProvider.themeMode == ThemeMode.system;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : isSystem
                  ? [colorScheme.primaryContainer, colorScheme.secondaryContainer]
                  : [const Color(0xFFFFF9F0), const Color(0xFFE8F4FD)],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título con icono animado
          Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isDark
                      ? Icons.dark_mode
                      : isSystem
                          ? Icons.brightness_auto
                          : Icons.light_mode,
                  key: ValueKey(themeProvider.themeMode),
                  color: isDark ? Colors.amber : colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tema de la aplicación',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    isDark
                        ? 'Modo oscuro activo'
                        : isSystem
                            ? 'Sigue al sistema'
                            : 'Modo claro activo',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.white60
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Botones de selección
          Row(
            children: [
              _ThemeButton(
                label: 'Claro',
                icon: Icons.light_mode,
                selected: themeProvider.themeMode == ThemeMode.light,
                isDarkCard: isDark,
                onTap: () => themeProvider.setThemeMode(ThemeMode.light),
              ),
              const SizedBox(width: 8),
              _ThemeButton(
                label: 'Oscuro',
                icon: Icons.dark_mode,
                selected: themeProvider.themeMode == ThemeMode.dark,
                isDarkCard: isDark,
                onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
              ),
              const SizedBox(width: 8),
              _ThemeButton(
                label: 'Sistema',
                icon: Icons.brightness_auto,
                selected: themeProvider.themeMode == ThemeMode.system,
                isDarkCard: isDark,
                onTap: () => themeProvider.setThemeMode(ThemeMode.system),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool isDarkCard;
  final VoidCallback onTap;

  const _ThemeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.isDarkCard,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? (isDarkCard ? Colors.amber : colorScheme.primary)
                : (isDarkCard
                    ? Colors.white.withValues(alpha: 0.1)
                    : colorScheme.surface.withValues(alpha: 0.7)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : (isDarkCard
                      ? Colors.white24
                      : colorScheme.outlineVariant),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? (isDarkCard ? Colors.black87 : Colors.white)
                    : (isDarkCard
                        ? Colors.white60
                        : colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
                  color: selected
                      ? (isDarkCard ? Colors.black87 : Colors.white)
                      : (isDarkCard
                          ? Colors.white60
                          : colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Cabecera de sección ──────────────────────────────────────────────────────

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
