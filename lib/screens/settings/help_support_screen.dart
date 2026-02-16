import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda y Soporte'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Preguntas Frecuentes',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _FaqItem(
            question: '¿Cómo puedo adoptar una mascota?',
            answer: 'Puedes explorar la sección de "Adopción" en la barra de navegación inferior, seleccionar una mascota que te interese y contactar al refugio o dueño directamente.',
          ),
          _FaqItem(
            question: '¿Cómo registro a mi mascota?',
            answer: 'Ve a la sección "Mis Mascotas" y pulsa el botón "+" para añadir una nueva mascota. Completa el formulario con sus datos y foto.',
          ),
          _FaqItem(
            question: '¿Es gratuito el uso de la app?',
            answer: 'Sí, la descarga y uso de las funciones principales de NachosPetCare son completamente gratuitos.',
          ),
          _FaqItem(
            question: '¿Cómo contacto con un profesional?',
            answer: 'En el "Directorio" encontrarás una lista de veterinarios y entrenadores. Puedes ver sus detalles y contactarlos por teléfono o correo.',
          ),
          const SizedBox(height: 32),
          Text(
            '¿Necesitas más ayuda?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Contactar Soporte'),
              subtitle: const Text('Envíanos un correo a soporte@nachospetcare.com'),
              onTap: _sendEmail,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'soporte@nachospetcare.com',
      query: _encodeQueryParameters(<String, String>{
        'subject': 'Soporte NachosPetCare',
      }),
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        debugPrint('No se pudo abrir el cliente de correo');
      }
    } catch (e) {
      debugPrint('Error al intentar abrir correo: $e');
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer),
          ),
        ],
      ),
    );
  }
}
