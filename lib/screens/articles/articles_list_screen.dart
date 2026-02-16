import 'package:flutter/material.dart';
import 'package:nachos_pet_care_flutter/models/article.dart';

class ArticlesListScreen extends StatefulWidget {
  const ArticlesListScreen({super.key});

  @override
  State<ArticlesListScreen> createState() => _ArticlesListScreenState();
}

class _ArticlesListScreenState extends State<ArticlesListScreen> {
  final List<Article> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    // TODO: Cargar desde la base de datos
    setState(() {
      _articles.addAll(_getDemoArticles());
      _isLoading = false;
    });
  }

  List<Article> _getDemoArticles() {
    return [
      Article(
        id: '1',
        title: '10 Consejos para Adoptar de Forma Responsable',
        summary:
            'Adoptar una mascota es una decisión importante que requiere preparación y compromiso.',
        content: '''
Adoptar una mascota es una decisión maravillosa que puede cambiar tu vida y la del animal. Sin embargo, es importante hacerlo de forma responsable.

1. **Investiga antes de adoptar**: Conoce las necesidades específicas del animal.
2. **Considera tu estilo de vida**: ¿Tienes tiempo suficiente?
3. **Presupuesto**: Los animales requieren gastos veterinarios, comida y cuidados.
4. **Espacio adecuado**: Asegúrate de tener el espacio necesario.
5. **Compromiso a largo plazo**: Las mascotas pueden vivir muchos años.

[Continúa con más consejos...]
        ''',
        author: 'Dr. María González',
        publishedAt: DateTime.now().subtract(const Duration(days: 5)),
        tags: ['adopción', 'responsabilidad', 'consejos'],
      ),
      Article(
        id: '2',
        title: 'La Importancia de Esterilizar a tu Mascota',
        summary:
            'La esterilización ayuda a controlar la sobrepoblación y mejora la salud de tu mascota.',
        content: '''
La esterilización es un procedimiento quirúrgico que tiene múltiples beneficios tanto para tu mascota como para la comunidad.

**Beneficios de la esterilización:**
- Reduce el riesgo de cáncer
- Elimina el celo en hembras
- Reduce comportamientos agresivos
- Controla la sobrepoblación

[Más información...]
        ''',
        author: 'Dra. Ana Martínez',
        publishedAt: DateTime.now().subtract(const Duration(days: 12)),
        tags: ['salud', 'esterilización', 'prevención'],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artículos sobre Adopción'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _articles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.article,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay artículos disponibles',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _articles.length,
                  itemBuilder: (context, index) {
                    final article = _articles[index];
                    return _ArticleCard(article: article);
                  },
                ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;

  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _ArticleDetailScreen(article: article),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                article.summary,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    article.author,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(article.publishedAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    if (difference == 0) return 'Hoy';
    if (difference == 1) return 'Ayer';
    if (difference < 7) return 'Hace $difference días';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const _ArticleDetailScreen({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artículo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  article.author,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              article.content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
