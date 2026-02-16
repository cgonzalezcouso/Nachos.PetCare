import 'package:flutter/material.dart';

// import 'package:provider/provider.dart';
// import 'package:nachos_pet_care_flutter/providers/theme_provider.dart'; // Future provider

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local state for UI demonstration until providers are implemented
  bool _notificationsEnabled = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'General'),
          SwitchListTile(
            title: const Text('Modo Oscuro'),
            subtitle: const Text('Cambiar apariencia de la app'),
            secondary: const Icon(Icons.dark_mode),
            value: _darkMode,
            onChanged: (bool value) {
              setState(() {
                _darkMode = value;
                // TODO: Update ThemeProvider
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidad en desarrollo')),
              );
            },
          ),
          SwitchListTile(
            title: const Text('Notificaciones'),
            subtitle: const Text('Recibir alertas y recordatorios'),
            secondary: const Icon(Icons.notifications),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          const Divider(),
          
          _buildSectionHeader(context, 'Cuenta'),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Privacidad y Seguridad'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to Privacy settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Idioma'),
            subtitle: const Text('Español'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Change language
            },
          ),
          const Divider(),

          _buildSectionHeader(context, 'Información'),
          ListTile(
            leading: const Icon(Icons.info_outline),
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
            leading: const Icon(Icons.description),
            title: const Text('Términos y Condiciones'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
               // TODO: Open URL
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
