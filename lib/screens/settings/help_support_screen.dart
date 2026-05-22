import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  String _selectedCategory = 'Todos';

  final List<String> _categories = [
    'Todos',
    'Mascotas y Salud',
    'Tienda',
    'Premium',
    'Privacidad',
  ];

  final List<_FaqModel> _faqs = [
    _FaqModel(
      category: 'Mascotas y Salud',
      question: '¿Cómo registro a mi mascota?',
      answer: 'Ve a la sección "Mis Mascotas" desde tu barra de navegación o el menú superior, pulsa el botón "+" para añadir una nueva mascota y completa el formulario con sus datos básicos, peso y una foto de perfil.',
    ),
    _FaqModel(
      category: 'Mascotas y Salud',
      question: '¿Cómo puedo añadir una vacuna o un recordatorio médico?',
      answer: 'Dirígete a la pestaña "Mis Mascotas", selecciona el perfil de tu mascota y pulsa en "Vacunas e Historial". Allí podrás registrar nuevas dosis aplicadas y configurar alertas automáticas para próximas visitas al veterinario.',
    ),
    _FaqModel(
      category: 'Mascotas y Salud',
      question: '¿Qué es la "Mascota Prioritaria"?',
      answer: 'Es la mascota principal que seleccionas en tu pantalla de inicio. Al marcar una mascota como prioritaria, sus recordatorios de salud, vacunas pendientes e información recomendada aparecerán de manera destacada en la parte superior del panel principal.',
    ),
    _FaqModel(
      category: 'Tienda',
      question: '¿Cómo funcionan las recomendaciones de la Tienda?',
      answer: 'Nuestro motor de recomendaciones avanzadas analiza la edad, especie (perro o gato), peso actual y el historial veterinario de tu mascota (como vacunas o diagnósticos clínicos). Con estos datos, calcula un índice de relevancia para sugerir los alimentos, juguetes y productos de cuidado preventivo más adecuados para su bienestar.',
    ),
    _FaqModel(
      category: 'Tienda',
      question: '¿Qué significa la indicación de "Comisión de Afiliación"?',
      answer: 'NachosPetCare trabaja asociado con tiendas de confianza como Amazon, Kiwoko y Tiendanimal. Al adquirir un producto recomendado pulsando el botón "Comprar en...", la tienda nos aporta una pequeña comisión (del 8% al 12% del precio del producto) por derivar la venta, sin que esto suponga ningún recargo ni coste extra para ti. Esto nos ayuda a financiar el desarrollo continuo de la app.',
    ),
    _FaqModel(
      category: 'Premium',
      question: '¿Es gratuito el uso de la app?',
      answer: 'Sí, las funciones esenciales como el registro de hasta 2 mascotas, alertas de vacunas básicas, búsqueda en directorio y adopciones son 100% gratuitas.',
    ),
    _FaqModel(
      category: 'Premium',
      question: '¿Qué ventajas ofrece el Plan Premium?',
      answer: 'El Plan Premium elimina todos los límites del plan gratuito. Te permite registrar mascotas de forma ilimitada, guardar sin restricciones todo el historial clínico y de vacunación, conectar wearables ilimitados y exportar informes médicos en formato PDF profesional de alta fidelidad para compartir con tu veterinario.',
    ),
    _FaqModel(
      category: 'Premium',
      question: '¿Cómo se gestiona el cobro de la suscripción?',
      answer: 'Todas las transacciones y renovaciones se procesan de forma cifrada y segura a través de Stripe, una pasarela de pago líder mundial. Puedes gestionar tu suscripción y cancelar la renovación automática en cualquier momento de forma sencilla.',
    ),
    _FaqModel(
      category: 'Privacidad',
      question: '¿Cómo comparto el historial médico con mi veterinario?',
      answer: 'Puedes enlazar a tu veterinario de forma segura desde Ajustes / Invitaciones a Veterinarios ingresando su correo electrónico o escaneando su código QR. Una vez acepte, podrá registrar informes y ver la cartilla de vacunación digital directamente en tiempo real.',
    ),
    _FaqModel(
      category: 'Privacidad',
      question: '¿Están protegidos mis datos personales?',
      answer: 'Totalmente. En NachosPetCare nos tomamos la privacidad muy en serio y cumplimos estrictamente con la normativa europea GDPR de protección de datos. Tus registros de salud están encriptados y puedes descargar una copia de tus datos personales o eliminar tu cuenta desde el apartado "Privacidad y Seguridad" en cualquier momento.',
    ),
    _FaqModel(
      category: 'General',
      question: '¿Cómo puedo dar en adopción una mascota?',
      answer: 'Puedes explorar la pestaña "Adopción" en la barra de navegación, revisar los refugios disponibles o registrar un anuncio detallado con fotos, descripción e historial de salud para encontrar una familia de confianza.',
    ),
  ];

  List<_FaqModel> _getFilteredFaqs() {
    if (_selectedCategory == 'Todos') {
      return _faqs;
    }
    return _faqs.where((faq) => faq.category == _selectedCategory).toList();
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Mascotas y Salud':
        return Icons.pets_rounded;
      case 'Tienda':
        return Icons.shopping_bag_outlined;
      case 'Premium':
        return Icons.workspace_premium_rounded;
      case 'Privacidad':
        return Icons.security_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Color _getCategoryColor(String category, ColorScheme colorScheme) {
    switch (category) {
      case 'Mascotas y Salud':
        return Colors.teal;
      case 'Tienda':
        return Colors.orange;
      case 'Premium':
        return Colors.amber[800]!;
      case 'Privacidad':
        return Colors.blue;
      default:
        return colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filteredFaqs = _getFilteredFaqs();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Ayuda y Soporte'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header Decorative Gradient Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer.withValues(alpha: 0.25),
                  colorScheme.secondaryContainer.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Cómo podemos ayudarte hoy?',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Explora nuestras categorías de ayuda o ponte en contacto con nuestro equipo de soporte.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),

          // Horizontal Category filter chips
          Container(
            height: 52,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    avatar: cat != 'Todos' ? Icon(
                      _getCategoryIcon(cat), 
                      size: 14, 
                      color: isSelected ? Colors.white : _getCategoryColor(cat, colorScheme),
                    ) : null,
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              },
            ),
          ),

          // FAQ List View
          Expanded(
            child: filteredFaqs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: colorScheme.outline),
                        const SizedBox(height: 16),
                        Text(
                          'No hay preguntas en esta categoría',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: filteredFaqs.length,
                    itemBuilder: (context, index) {
                      final faq = filteredFaqs[index];
                      final catColor = _getCategoryColor(faq.category, colorScheme);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                        ),
                        elevation: 0.5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: ExpansionTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getCategoryIcon(faq.category),
                                size: 18,
                                color: catColor,
                              ),
                            ),
                            title: Text(
                              faq.question,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),
                            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            expandedAlignment: Alignment.topLeft,
                            children: [
                              Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.3), height: 16),
                              Text(
                                faq.answer,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.45,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Bottom support section
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.2)),
              ),
              color: colorScheme.primaryContainer.withValues(alpha: 0.15),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.email_outlined, color: Colors.white),
                ),
                title: Text(
                  '¿Sigues con dudas?',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Envía un correo a soporte@nachospetcare.com',
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: colorScheme.primary),
                onTap: _sendEmail,
              ),
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

class _FaqModel {
  final String category;
  final String question;
  final String answer;

  _FaqModel({
    required this.category,
    required this.question,
    required this.answer,
  });
}
