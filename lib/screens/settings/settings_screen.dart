import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:nachos_pet_care_flutter/providers/theme_provider.dart';
import 'package:nachos_pet_care_flutter/providers/locale_provider.dart';
import 'package:nachos_pet_care_flutter/providers/subscription_provider.dart';
import 'package:nachos_pet_care_flutter/l10n/app_strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  static const String _appVersion = '3.0.0';

  void _showLanguageSelector(BuildContext context, LocaleProvider localeProvider) {
    final strings = AppStrings.of(context);
    final languages = [
      {'code': 'es', 'name': 'Español'},
      {'code': 'en', 'name': 'English'},
      {'code': 'ca', 'name': 'Català'},
      {'code': 'fr', 'name': 'Français'},
      {'code': 'de', 'name': 'Deutsch'},
      {'code': 'pt', 'name': 'Português'},
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(strings.language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((lang) {
              final isSelected = localeProvider.locale.languageCode == lang['code'];
              return ListTile(
                title: Text(lang['name']!),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  localeProvider.setLocale(Locale(lang['code']!));
                  Navigator.pop(ctx);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(strings.cancel),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final strings = AppStrings.of(context);

    final currentLanguageCode = localeProvider.locale.languageCode;
    String languageName = 'Español';
    switch (currentLanguageCode) {
      case 'es':
        languageName = 'Español';
        break;
      case 'en':
        languageName = 'English';
        break;
      case 'ca':
        languageName = 'Català';
        break;
      case 'fr':
        languageName = 'Français';
        break;
      case 'de':
        languageName = 'Deutsch';
        break;
      case 'pt':
        languageName = 'Português';
        break;
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(strings.settings),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── APARIENCIA ─────────────────────────────────────────────────────
          _SectionHeader(title: strings.appearance),

          // Banner visual del modo activo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: _ThemeSelectorCard(themeProvider: themeProvider),
          ),

          const Divider(height: 32),

          // ── PLAN DE SUSCRIPCIÓN ─────────────────────────────────────────────
          _SectionHeader(title: 'Suscripción'),
          Consumer<SubscriptionProvider>(
            builder: (context, subProvider, _) {
              final isPremium = subProvider.isPremium;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isPremium ? Colors.amber.withValues(alpha: 0.4) : colorScheme.outlineVariant,
                    width: isPremium ? 2 : 1,
                  ),
                ),
                color: isPremium ? Colors.amber.withValues(alpha: 0.05) : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            isPremium ? Icons.workspace_premium_rounded : Icons.pets_rounded,
                            color: isPremium ? Colors.amber[800] : colorScheme.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isPremium ? 'Plan Premium Activo' : 'Plan Gratuito',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isPremium ? Colors.amber[900] : colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isPremium
                                      ? 'Mascotas e historial ilimitados, exportación PDF desbloqueada.'
                                      : 'Límite de 2 mascotas y 50 eventos históricos por mascota.',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context.push('/premium-paywall'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPremium ? Colors.transparent : Colors.amber[600],
                          foregroundColor: isPremium ? Colors.amber[800] : const Color(0xFF0F111A),
                          elevation: isPremium ? 0 : 2,
                          side: isPremium ? BorderSide(color: Colors.amber[800]!) : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size.fromHeight(40),
                        ),
                        child: Text(
                          isPremium ? 'Ver detalles del plan' : 'Mejorar a Premium',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const Divider(height: 32),

          // ── NOTIFICACIONES ─────────────────────────────────────────────────
          _SectionHeader(title: strings.notifications),
          SwitchListTile(
            title: Text(strings.pushNotifications),
            subtitle: Text(strings.notificationsSub),
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
          _SectionHeader(title: strings.account),
          ListTile(
            leading: Icon(Icons.lock_outline, color: colorScheme.primary),
            title: Text(strings.privacySecurity),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/privacy-security'),
          ),
          ListTile(
            leading: Icon(Icons.language, color: colorScheme.primary),
            title: Text(strings.language),
            subtitle: Text(languageName),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageSelector(context, localeProvider),
          ),

          const Divider(height: 32),

          // ── CLÍNICAS B2B & VETERINARIOS ─────────────────────────────────────
          _SectionHeader(title: 'Ecosistema Clínico B2B'),
          ListTile(
            leading: Icon(Icons.share_location_outlined, color: colorScheme.primary),
            title: Text(strings.vetInvitations),
            subtitle: Text(strings.vetInvitationsSub),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/vet-invitations'),
          ),
          ListTile(
            leading: Icon(Icons.local_hospital_outlined, color: colorScheme.primary),
            title: Text(strings.b2bClinicPortal),
            subtitle: Text(strings.b2bClinicPortalSub),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/vet/dashboard'),
          ),
          ListTile(
            leading: Icon(Icons.watch_rounded, color: colorScheme.primary),
            title: Text(strings.wearablesTitle),
            subtitle: Text(strings.wearablesSub),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/wearables'),
          ),
          ListTile(
            leading: Icon(Icons.smart_toy_outlined, color: colorScheme.primary),
            title: Text(strings.aiAssistantTitle),
            subtitle: Text(strings.aiAssistantSub),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/ai-assistant'),
          ),

          const Divider(height: 32),

          // ── INFORMACIÓN ────────────────────────────────────────────────────
          _SectionHeader(title: strings.info),
          ListTile(
            leading:
                Icon(Icons.info_outline, color: colorScheme.primary),
            title: Text(strings.about),
            subtitle: Text('Versión $_appVersion'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'NachosPetCare',
                applicationVersion: _appVersion,
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
            title: Text(strings.terms),
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
    final strings = AppStrings.of(context);

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
                    strings.appTheme,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    isDark
                        ? strings.darkModeActive
                        : isSystem
                            ? strings.followSystem
                            : strings.lightModeActive,
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
                label: strings.themeLight,
                icon: Icons.light_mode,
                selected: themeProvider.themeMode == ThemeMode.light,
                isDarkCard: isDark,
                onTap: () => themeProvider.setThemeMode(ThemeMode.light),
              ),
              const SizedBox(width: 8),
              _ThemeButton(
                label: strings.themeDark,
                icon: Icons.dark_mode,
                selected: themeProvider.themeMode == ThemeMode.dark,
                isDarkCard: isDark,
                onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
              ),
              const SizedBox(width: 8),
              _ThemeButton(
                label: strings.themeSystem,
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
