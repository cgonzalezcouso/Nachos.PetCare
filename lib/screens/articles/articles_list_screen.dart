import 'package:flutter/material.dart';
import 'package:nachos_pet_care_flutter/models/article.dart';

// ─── Pantalla de listado ──────────────────────────────────────────────────────

class ArticlesListScreen extends StatelessWidget {
  const ArticlesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final articles = _allArticles();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Artículos sobre Adopción'),
        centerTitle: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          final isFirst = index == 0;
          return isFirst
              ? _FeaturedArticleCard(article: article)
              : _ArticleCard(article: article);
        },
      ),
    );
  }
}

// ─── Tarjeta destacada (primer artículo) ─────────────────────────────────────

class _FeaturedArticleCard extends StatelessWidget {
  final Article article;
  const _FeaturedArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => _openDetail(context, article),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.primary.withValues(alpha: 0.75),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Patrón decorativo
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              right: 40,
              bottom: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            // Contenido
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'DESTACADO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        article.author,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward,
                          color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        'Leer más',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tarjeta normal ───────────────────────────────────────────────────────────

class _ArticleCard extends StatelessWidget {
  final Article article;
  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () => _openDetail(context, article),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono del tema
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconForTags(article.tags),
                  color: colorScheme.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tags
                    if (article.tags.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        children: article.tags
                            .take(2)
                            .map((tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color:
                                          colorScheme.onSecondaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      article.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.summary,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            size: 12, color: colorScheme.secondary),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            article.author,
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.secondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatDate(article.publishedAt),
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

void _openDetail(BuildContext context, Article article) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ArticleDetailScreen(article: article),
    ),
  );
}

IconData _iconForTags(List<String> tags) {
  for (final tag in tags) {
    if (tag.contains('salud') || tag.contains('veterinaria')) {
      return Icons.health_and_safety_outlined;
    }
    if (tag.contains('adopción') || tag.contains('responsabilidad')) {
      return Icons.favorite_outline;
    }
    if (tag.contains('esterilización') || tag.contains('prevención')) {
      return Icons.medical_services_outlined;
    }
    if (tag.contains('comportamiento') || tag.contains('educación')) {
      return Icons.psychology_outlined;
    }
    if (tag.contains('nutrición') || tag.contains('alimentación')) {
      return Icons.restaurant_outlined;
    }
    if (tag.contains('bienestar') || tag.contains('maltrato')) {
      return Icons.shield_outlined;
    }
  }
  return Icons.article_outlined;
}

String _formatDate(DateTime date) {
  const months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
  ];
  return '${date.day} ${months[date.month - 1]}. ${date.year}';
}

// ─── Pantalla de detalle del artículo ────────────────────────────────────────

class ArticleDetailScreen extends StatelessWidget {
  final Article article;
  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ─────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Fondo degradado
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  // Círculos decorativos
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -10,
                    bottom: -40,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  // Tags en la parte inferior
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Wrap(
                      spacing: 6,
                      children: article.tags
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Contenido ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    article.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Autor y fecha
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(Icons.person,
                            size: 18, color: colorScheme.primary),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.author,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatDate(article.publishedAt),
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Divider(color: colorScheme.outlineVariant),
                  const SizedBox(height: 16),

                  // Resumen destacado
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.format_quote,
                            color: colorScheme.primary, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            article.summary,
                            style:
                                theme.textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Contenido completo
                  _ArticleContent(content: article.content),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Renderiza el contenido con soporte para **negrita** y secciones
class _ArticleContent extends StatelessWidget {
  final String content;
  const _ArticleContent({required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paragraphs = content.trim().split('\n\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((paragraph) {
        final trimmed = paragraph.trim();
        if (trimmed.isEmpty) return const SizedBox.shrink();

        // Sección con encabezado ## Título
        if (trimmed.startsWith('## ')) {
          final heading = trimmed.substring(3);
          return Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 10),
            child: Text(
              heading,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }

        // Elemento de lista: - Texto
        if (trimmed.startsWith('- ')) {
          final items = trimmed
              .split('\n')
              .where((l) => l.trim().startsWith('- '))
              .toList();
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items
                  .map((item) => Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 6, right: 8),
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Expanded(
                              child: _RichParagraph(
                                  text: item.trim().substring(2),
                                  style: theme.textTheme.bodyMedium!
                                      .copyWith(height: 1.6)),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          );
        }

        // Párrafo normal
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _RichParagraph(
            text: trimmed,
            style: theme.textTheme.bodyMedium!.copyWith(height: 1.7),
          ),
        );
      }).toList(),
    );
  }
}

// Renderiza **texto en negrita** dentro de un párrafo
class _RichParagraph extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _RichParagraph({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return RichText(
      text: TextSpan(style: style, children: spans),
    );
  }
}

// ─── Datos de los artículos ───────────────────────────────────────────────────

List<Article> _allArticles() {
  return [
    Article(
      id: '1',
      title: 'Guía completa para adoptar una mascota de forma responsable',
      summary:
          'Adoptar es un acto de amor que cambia dos vidas: la tuya y la del animal. Pero implica mucho más que querer tener compañía. Te explicamos paso a paso cómo hacerlo bien.',
      author: 'Dr. Carlos Fernández, veterinario',
      publishedAt: DateTime.now().subtract(const Duration(days: 3)),
      tags: ['adopción', 'responsabilidad', 'consejos'],
      content: '''
## ¿Por qué adoptar en lugar de comprar?

Cada año, millones de animales acaban en perreras y refugios de todo el mundo. En España, según la RSPCA, se abandonan más de **300.000 animales domésticos al año**. Adoptar un animal del refugio no solo salva su vida, sino que libera espacio para que el refugio pueda ayudar a otro animal necesitado.

Cuando adoptas en lugar de comprar, también te posicionas en contra de las granjas de cría intensiva y las tiendas de animales que solo buscan beneficio económico.

## Antes de adoptar: hazte estas preguntas

Antes de dar el paso, es esencial que reflexiones honestamente sobre tu situación:

- **¿Tienes tiempo suficiente?** Un perro necesita entre 2 y 4 horas diarias de atención activa, paseos y socialización.
- **¿Tu vivienda es adecuada?** Un perro grande en un piso pequeño sin acceso a jardín puede sufrir estrés crónico.
- **¿Puedes asumir los gastos?** Los veterinarios, la alimentación, el seguro y los accesorios pueden suponer entre 800 € y 2.000 € al año.
- **¿Tienes el apoyo de todos los convivientes?** Una mascota afecta a toda la familia o los compañeros de piso.
- **¿Viajas mucho?** Necesitas una red de apoyo (cuidadores, residencias) para cuando te ausentes.

## El proceso de adopción paso a paso

**Paso 1: Investiga qué tipo de animal se adapta a ti.**
No todos los animales son iguales. Un Bóxer necesita mucho ejercicio; un gato mayor puede ser perfecto para alguien con jornadas largas en el trabajo. Habla con el personal del refugio: ellos conocen a fondo a cada animal.

**Paso 2: Visita el refugio con calma.**
No vayas con prisa. Pasa tiempo con el animal antes de decidir. Algunos se muestran nerviosos al principio; otros tardan semanas en mostrar su verdadero carácter una vez en un hogar tranquilo.

**Paso 3: Prepara tu hogar antes de que llegue.**
Compra cama, comedero, bebedero, juguetes y lo necesario para su especie. Si es un perro, asegura balcones y vallas. Si es un gato, coloca redes en las ventanas.

**Paso 4: El período de adaptación.**
Los primeros 30 días son críticos. El animal puede mostrarse asustado, encogido o incluso agresivo. Esto es completamente normal. Deja que marque su ritmo, no lo fuerces a socializar antes de que esté listo.

## Errores comunes que debes evitar

- **Adoptar por impulso**, especialmente en Navidad o verano. Las tasas de abandono se disparan tras estas fechas.
- **No informarse sobre las necesidades de la especie** antes de adoptar.
- **Rendirse en las primeras semanas** porque el animal no se comporta como esperabas.
- **No acudir al veterinario** en las primeras semanas para una revisión completa.

Adoptar con responsabilidad es un compromiso para toda la vida del animal. Si lo haces bien, recibirás a cambio una lealtad y un cariño incondicionales.
''',
    ),

    Article(
      id: '2',
      title: 'Por qué esterilizar a tu mascota es el mayor acto de amor',
      summary:
          'La esterilización no solo previene camadas no deseadas: alarga la vida de tu mascota, mejora su comportamiento y reduce el riesgo de enfermedades graves.',
      author: 'Dra. Ana Martínez, cirujana veterinaria',
      publishedAt: DateTime.now().subtract(const Duration(days: 10)),
      tags: ['salud', 'esterilización', 'prevención'],
      content: '''
## El gran malentendido

Muchos propietarios creen que esterilizar a su mascota es "quitarle algo natural". Sin embargo, los veterinarios coincidimos en que es uno de los procedimientos más beneficiosos que puedes hacer por tu animal, tanto desde el punto de vista sanitario como conductual.

## Beneficios para la hembra

Las hembras no esterilizadas tienen un riesgo muy elevado de desarrollar **piometra** (infección uterina potencialmente mortal), **tumores mamarios** y otras complicaciones hormonales. Esterilizar antes del primer celo reduce el riesgo de tumores mamarios en un **99,5%**. Después del segundo celo, la protección cae al 74%.

Otros beneficios para las hembras:
- **Eliminación del celo**: No más vocalizaciones, manchas de sangre ni intentos de escaparse.
- **Equilibrio emocional**: Muchas hembras muestran una conducta más estable fuera del ciclo hormonal.
- **Vida más larga**: Los estudios indican que las hembras esterilizadas viven entre un 23% y un 26% más.

## Beneficios para el macho

En los machos, la castración reduce el riesgo de **tumor testicular** a cero y disminuye significativamente la hiperplasia prostática benigna, muy común en perros mayores no castrados.

Beneficios conductuales:
- **Reducción de la agresividad** hacia otros machos.
- **Menor marcaje territorial** con orina dentro del hogar.
- **Menor tendencia a escaparse** en busca de hembras en celo.
- **Reducción de la monta** sobre personas u objetos.

## ¿Cuándo es el mejor momento?

Para perros de tamaño pequeño y mediano, se recomienda entre los **6 y 8 meses**, antes del primer celo en las hembras. Para razas grandes, puede esperarse hasta los 12-18 meses para no interferir en el desarrollo óseo. Habla siempre con tu veterinario para valorar el momento óptimo según la raza y el estado de salud.

## El procedimiento es seguro

La esterilización es una de las cirugías más practicadas en veterinaria. Se realiza bajo anestesia general con monitorización constante. La recuperación suele ser de **5 a 10 días**, y la mayoría de los animales están activos al día siguiente de la operación.

## El impacto social

En España, cada hembra sin esterilizar puede ser responsable, en cinco años, de **hasta 67.000 descendientes** directos e indirectos (incluyendo a su descendencia). Esterilizar a tu mascota es también un acto de responsabilidad hacia la comunidad: menos animales abandonados, menos recursos para los refugios, menos sufrimiento.
''',
    ),

    Article(
      id: '3',
      title:
          'Cómo ayudar a un animal adoptado a superar el trauma del abandono',
      summary:
          'Los animales rescatados a menudo cargan con heridas emocionales profundas. Aprender a leer sus señales y darles el espacio que necesitan es clave para una recuperación exitosa.',
      author: 'Laura Sánchez, etóloga y educadora canina',
      publishedAt: DateTime.now().subtract(const Duration(days: 18)),
      tags: ['comportamiento', 'educación', 'bienestar'],
      content: '''
## El trauma no se ve, pero existe

Un animal que ha sido abandonado, maltratado o socializado de forma deficiente no llega a tu hogar como una página en blanco. Llega con miedo, desconfianza y, en muchos casos, con respuestas de estrés cronificadas que se manifiestan de forma inesperada.

Puede que tu perro adoptado gruña sin aparente motivo, se esconda durante días, no quiera comer, destroce objetos o no sepa cómo interactuar con otros perros. Esto no significa que el animal sea "malo" o que la adopción haya sido un error. Significa que necesita tiempo, paciencia y la guía adecuada.

## La regla de los tres 3

Los etólogos empleamos la "regla de los tres 3" para describir las fases de adaptación:

- **Primeros 3 días**: El animal está en estado de shock. Puede estar paralizado, no comer o intentar escapar. Deja que explore a su ritmo. No lo abrumes con visitas ni ruido.
- **Primeras 3 semanas**: Empieza a entender la rutina del hogar. Muestra su carácter más auténtico. Pueden aparecer comportamientos problemáticos.
- **Primeros 3 meses**: Se siente más seguro. Afianza el vínculo con su nueva familia. Es el momento de empezar el trabajo de educación y enriquecimiento.

## Señales de estrés que debes reconocer

Conocer el lenguaje corporal de tu mascota te permitirá actuar a tiempo:

- **Perros**: jadeo excesivo sin calor, bostezos frecuentes, orejas hacia atrás, cola entre las patas, evitar el contacto visual, lamido de labios.
- **Gatos**: pupilas muy dilatadas, orejas aplastadas, cola inflada, bufidos, esconderse durante días sin salir.
- **Aves y exóticos**: plumas erizadas, picaje (arrancarse plumas), vocalizaciones repetitivas, movimientos estereotipados.

## Estrategias que funcionan

**Establece rutinas firmes.** Los animales traumatizados necesitan predecibilidad. Come a la misma hora, sál a pasear en los mismos momentos, usa las mismas palabras para las mismas acciones.

**Usa el refuerzo positivo exclusivamente.** Nunca el castigo físico ni el regaño agresivo. El castigo agrava el miedo y rompe la confianza. Cada comportamiento correcto merece un premio: comida, caricias o juego.

**Dale espacio personal.** Coloca una cama o refugio donde el animal pueda retirarse cuando se sienta abrumado. Ese espacio es suyo: nadie debe molestarle allí.

**Socializaci&oacute;n gradual.** Si el animal tiene miedo a personas o perros, no lo expongas a situaciones de alta intensidad. Empieza desde lejos, a su ritmo, asociando la presencia del estímulo con cosas positivas.

## Cuándo pedir ayuda profesional

Si tras tres meses el animal sigue sin comer con normalidad, muestra agresión frecuente o no es capaz de estar solo sin destrozar el entorno, es el momento de acudir a un etólogo o educador canino certificado. En algunos casos, el veterinario puede valorar un apoyo farmacológico temporal para reducir el nivel basal de ansiedad.

Recuerda: sanar a un animal traumatizado es un proceso largo. Pero los resultados son de los más gratificantes que puedes experimentar como cuidador.
''',
    ),

    Article(
      id: '4',
      title: 'Alimentación natural vs pienso: qué dicen los expertos',
      summary:
          'El debate entre la dieta BARF, la comida casera y el pienso de calidad es uno de los más candentes en nutrición veterinaria. Analizamos la evidencia disponible.',
      author: 'Dra. Marta López, especialista en nutrición veterinaria',
      publishedAt: DateTime.now().subtract(const Duration(days: 25)),
      tags: ['nutrición', 'alimentación', 'salud'],
      content: '''
## El debate está servido

Nunca como ahora hemos tenido tanta información sobre nutrición animal. Y paradójicamente, nunca ha habido tanta confusión. Hay quienes defienden la dieta BARF (carne cruda y verduras) como la única opción natural; otros son fans incondicionales de los piensos premium; y un tercer grupo apuesta por la comida casera cocinada.

¿Quién tiene razón? La respuesta, como casi siempre en medicina veterinaria, es: **depende**.

## Pienso comercial: ventajas e inconvenientes

Los piensos de alta gama están formulados para cumplir los estándares nutricionales de la FEDIAF (Federación Europea de Fabricantes de Alimentos para Animales de Compañía). Esto garantiza un equilibrio de nutrientes adecuado para cada etapa vital.

**Ventajas:**
- Formulación equilibrada y estudiada.
- Fácil almacenamiento y uso.
- Coste predecible.
- Variedades para cada condición (renal, intestinal, articular...).

**Inconvenientes:**
- Algunos contienen subproductos de baja calidad, colorantes y conservantes artificiales.
- El procesado a alta temperatura destruye parte de las vitaminas y enzimas originales.
- Puede generar dependencia si el animal no acepta otros alimentos.

La clave está en **elegir piensos con ingredientes de calidad**: que la carne o el pescado sea el primer componente, sin cereales refinados como primer ingrediente y sin colorantes artificiales.

## Dieta BARF: qué dice la ciencia

La dieta BARF (Biologically Appropriate Raw Food) propone alimentar a los perros y gatos con carne cruda, huesos carnosos, vísceras, verduras y frutas. Sus defensores argumentan que es la alimentación más cercana a la dieta ancestral del animal.

**Beneficios reportados:**
- Mejora del pelaje y la piel.
- Heces más pequeñas y consistentes.
- Menor nivel de procesado de los alimentos.

**Riesgos que no debes ignorar:**
- **Contaminación bacteriana**: La carne cruda puede contener Salmonella, Listeria o E. coli, con riesgo para el animal y para los humanos del hogar, especialmente niños y personas inmunodeprimidas.
- **Desequilibrios nutricionales**: Si no está bien formulada, puede provocar deficiencias graves de calcio, vitaminas o minerales.
- **Huesos**: Los huesos crudos pueden ser seguros, pero los cocinados son peligrosos (se astillan y pueden perforar el tracto digestivo).

## Comida casera cocinada

La comida casera cocinada puede ser una excelente opción **siempre que esté supervisada por un veterinario nutricionista**. Las recetas genéricas que circulan por internet no garantizan el equilibrio nutricional que necesita tu perro o gato.

Un menú casero equilibrado debe incluir una fuente proteica (pollo, pescado, ternera), una fuente de carbohidratos (arroz, boniato) y verduras, más un suplemento vitamínico y mineral prescrito por el veterinario.

## Nuestra recomendación

No existe una dieta universalmente perfecta. La mejor dieta para tu mascota es aquella que:
- Se adapta a su edad, condición física y posibles patologías.
- Está supervisada por un profesional.
- El animal digiere bien (heces normales, pelo en buen estado, energía adecuada).
- Puedes mantener de forma sostenida en el tiempo.

Consulta siempre con tu veterinario antes de cambiar radicalmente la dieta de tu mascota.
''',
    ),

    Article(
      id: '5',
      title: 'Animales exóticos en adopción: lo que nadie te cuenta',
      summary:
          'Tortugas, reptiles, aves exóticas y pequeños mamíferos también llenan los refugios. Conoce sus necesidades especiales antes de dar el paso.',
      author: 'Jorge Ruiz, biólogo y especialista en fauna exótica',
      publishedAt: DateTime.now().subtract(const Duration(days: 35)),
      tags: ['adopción', 'exóticos', 'bienestar'],
      content: '''
## El animal exótico no es una moda

Las redes sociales han popularizado animales como los erizos africanos, las chinchillas, los camaleones, las serpientes de maíz o las tortugas mediterráneas. Muchas personas los adquieren sin saber que detrás hay necesidades muy complejas, y acaban abandonándolos en refugios o incluso en el campo, donde pueden convertirse en una especie invasora.

En España, el abandono de tortugas de Florida (Trachemys scripta) está provocando graves desequilibrios ecológicos en zonas húmedas, ya que compiten con la tortuga de estanque autóctona.

## Las necesidades especiales que nadie menciona

**Reptiles**: Necesitan sistemas de calefacción específicos (placas calefactoras, lámparas UVB), terrarios de un tamaño determinado y dietas muy concretas. Un dragón barbudo, por ejemplo, requiere una temperatura de entre 38 y 42 °C en su zona de termorregulación. Sin UVB adecuada, desarrollará enfermedad metabólica ósea en pocos meses.

**Aves psitácidas (loros, cotorras, cacatúas)**: Son animales altamente inteligentes y sociales. Un loro solo en una jaula pequeña durante horas puede desarrollar trastornos compulsivos severos: picaje, vocalizaciones repetitivas, automutilación. Necesitan estimulación mental constante, interacción diaria y, en muchos casos, compañía de otro ejemplar de su especie.

**Conejos y cobayas**: Son los más abandonados tras los perros y gatos. Contrariamente a la creencia popular, **no son buenas mascotas para niños pequeños**: son animales frágiles, asustadizos, y la manipulación brusca puede causarles un estrés grave. Necesitan espacio para correr (mínimo 2 m²), compañía de su especie, heno ad libitum y visitas veterinarias especializadas.

**Tortugas terrestres**: Su longevidad (pueden vivir 80-100 años) obliga a reflexionar muy seriamente. Una tortuga mediterránea adoptada hoy puede sobrevivir a varios de sus propietarios. Necesita un recinto exterior con substrato natural, acceso a sol directo (no a través de cristal), agua para bañarse y una hibernación adecuada en invierno.

## Antes de adoptar un animal exótico, comprueba:

- ¿Está la especie legalmente permitida como mascota en España y en tu comunidad autónoma?
- ¿Existe un veterinario especializado en fauna exótica relativamente cerca?
- ¿Cuánto espacio real necesita el animal durante toda su vida?
- ¿Cuánto cuesta su alimentación, mantenimiento e instalaciones?
- ¿Quién cuidará al animal si enfermedad, viaje o circunstancias de vida te lo impiden?

## Los refugios especializados en exóticos

Hay refugios en España especializados en fauna exótica, como GREFA (Grupo de Rehabilitación de la Fauna Autóctona) o varios centros de recuperación autonómicos. Muchos de estos animales no pueden ser liberados y buscan hogares preparados para recibirlos.

Si estás convencido de que puedes ofrecer el hogar adecuado, habla con el personal del refugio, visita al animal varias veces y, si es posible, habla con el veterinario que lo trata actualmente. La información es tu mejor aliada.
''',
    ),

    Article(
      id: '6',
      title:
          'El bienestar animal en España: avances legales y retos pendientes',
      summary:
          'La Ley de Bienestar Animal de 2023 ha supuesto un hito histórico. Pero entre la ley y la realidad hay una brecha importante que todos debemos conocer.',
      author: 'Elena Torres, abogada especializada en derecho animal',
      publishedAt: DateTime.now().subtract(const Duration(days: 45)),
      tags: ['bienestar', 'legislación', 'maltrato'],
      content: '''
## Un antes y un después: la Ley 7/2023

El 29 de marzo de 2023 entró en vigor en España la **Ley 7/2023 de Protección de los Derechos y el Bienestar de los Animales**, la más ambiciosa en materia de protección animal de la historia del país. Entre sus medidas más destacadas:

- **Prohibición del sacrificio de animales sanos** en perreras y refugios públicos.
- **Obligación de microchip y registro** para perros, gatos y hurones en un registro unificado nacional.
- **Prohibición de la venta de perros, gatos y hurones** en tiendas de animales.
- **Multas de hasta 200.000 euros** para infracciones muy graves, incluyendo el maltrato.
- **Obligación de seguro de responsabilidad civil** para perros.
- **Cursos obligatorios** para la tenencia de perros.

## Avances innegables

Antes de esta ley, España era uno de los países con mayores tasas de abandono animal de Europa occidental. La prohibición de sacrificio en refugios públicos ha obligado a muchos ayuntamientos a invertir en adopción, acogida temporal y esterilización como estrategias de control poblacional.

La prohibición de venta en tiendas ha impulsado la adopción responsable: ya no es posible comprar un cachorro de forma impulsiva al verlo en el escaparate de una tienda. Ahora el proceso requiere más reflexión.

## Los retos que quedan

**La aplicación desigual.** La ley es de ámbito estatal, pero su aplicación depende de las comunidades autónomas y los municipios. In muchos pueblos pequeños, los recursos para inspección y control son mínimos, y las infracciones no se sancionan.

**El tráfico ilegal.** A pesar de la prohibición de venta en tiendas, el comercio online de cachorros sin garantías continúa. Muchos de estos animales proceden de granjas de cría intensiva en países sin regulación, y llegan a España con documentación falsificada.

**Los animales "no incluidos".** La ley protege principalmente a perros, gatos y hurones. Los animales de granja, los utilisados en experimentación o los animales de espectáculo tienen una protección mucho más limitada.

**La cultura del abandono.** Las leyes cambian normas, pero no mentalidades de la noche a la mañana. El porcentaje de perros recogidos en verano y en período navideño sigue siendo desproporcionadamente alto.

## ¿Qué puedes hacer tú?

- **Adoptar, no comprar.** Cada adopción reduce la demanda del mercado de cría.
- **Denunciar** situaciones de maltrato o abandono a la policía local, guardia civil o asociaciones de protección animal.
- **Esterilizar** a tus mascotas para no contribuir a la superpoblación.
- **Apoyar económicamente** a los refugios y asociaciones de tu zona.
- **Educarte y educar** a tu entorno sobre tenencia responsable.

El bienestar animal es, en última instancia, un reflejo del bienestar de una sociedad. Un país que trata bien a sus animales es un país más compasivo y más justo.
''',
    ),

    // ── Artículos 7-20 ────────────────────────────────────────────────────────

    Article(
      id: '7',
      title: 'El período de acogida temporal: salvar una vida sin adoptarla',
      summary:
          'Las familias de acogida son el eslabón más importante de la cadena de rescate. Descubre qué implica acoger, qué no implica y cómo empezar.',
      author: 'Patricia Gómez, coordinadora de Red de Acogidas AnimalMadrid',
      publishedAt: DateTime.now().subtract(const Duration(days: 50)),
      tags: ['adopción', 'acogida', 'voluntariado'],
      content: '''
## Qué es una familia de acogida

Una familia de acogida ofrece a un animal rescatado un hogar temporal mientras espera ser adoptado de forma definitiva. Puede ser cuestión de días, semanas o incluso meses. Durante ese tiempo, la familia de acogida proporciona al animal alimentación, cuidados veterinarios básicos (gestionados por la asociación), socialización y, sobre todo, la posibilidad de aprender a vivir en un hogar.

**El acogimiento no implica adopción**, aunque muchas familias de acogida terminan quedándose con el animal. A estos casos los llamamos cariñosamente "fracasos de acogida", aunque en realidad son el mejor de los resultados posibles.

## Por qué las acogidas son tan necesarias

Los refugios y perreras tienen capacidad limitada. Un animal que pasa semanas o meses en un espacio reducido, rodeado de ruido y otros animales estresados, puede desarrollar comportamientos que dificultan su adopción: regresión en la limpieza, miedo extremo, hiperactividad o depresión.

En cambio, un animal que ha vivido en un hogar de acogida llega al proceso de adopción:
- **Socializado** con personas y otros animales domésticos.
- **Con rutinas establecidas**, sabe dormir en cama o cesta, salir a pasear y hacer sus necesidades fuera.
- **Con información real** sobre su carácter, miedos y necesidades específicas.

Esto multiplica sus posibilidades de ser adoptado y de que esa adopción sea exitosa y duradera.

## ¿Qué implica ser familia de acogida?

**Tiempo**: Especialmente al principio. El animal necesita supervisión, atención y paciencia durante las primeras semanas.

**Espacio**: No es necesario tener jardín, pero sí un hogar donde el animal pueda moverse con libertad y seguridad.

**Otros animales en casa**: Muchas asociaciones hacen convivencias de prueba antes de cerrar la acogida. No siempre tiene que haber compatibilidad perfecta desde el primer día.

**Voluntad de informar**: La familia de acogida observa al animal y traslada esa información a la asociación: qué le gusta, qué le asusta, si convive bien con niños, con gatos, con perros de distintos tamaños.

**Lo que NO implica**: Pagar los gastos veterinarios (la asociación los asume), tener que quedarte con el animal si encuentran familia adoptante, ni comprometerte indefinidamente.

## Cómo empezar

1. Busca asociaciones de protección animal en tu ciudad o comunidad autónoma.
2. Rellena su formulario de acogida: te preguntarán sobre tu vivienda, horarios, convivientes y experiencia previa con animales.
3. Asiste (si lo ofrecen) a una charla o taller de acogida.
4. La asociación te asignará un animal compatible con tu perfil.

El primer animal que acoges suele ser el más difícil. A partir del segundo, ya sabes qué esperar y el proceso fluye mucho mejor.

## El duelo de la despedida

Sí: desprenderte del animal cuando encuentra familia adoptante puede doler. Especialmente si has estado varios meses juntos. Es completamente normal y no significa que hayas hecho algo mal.

Lo que ayuda a muchas acogedoras es recordar que ese espacio libre significa que pueden acoger a otro animal que también necesita urgentemente un hogar temporal. El duelo de la acogida es el precio —pequeño— de salvar muchas vidas.
''',
    ),

    Article(
      id: '8',
      title: 'Cómo presentar a tu perro adoptado y tu gato residente',
      summary:
          'La convivencia entre perros y gatos no está condenada al fracaso. Con la introducción correcta, muchas parejas acaban siendo inseparables.',
      author: 'Silvia Moreno, etóloga felina y canina',
      publishedAt: DateTime.now().subtract(const Duration(days: 58)),
      tags: ['comportamiento', 'convivencia', 'educación'],
      content: '''
## El mayor error: el "que se las arreglen"

El error más común al introducir un perro en un hogar con gato (o viceversa) es dejar que ambos animales se encuentren directamente y "que se las arreglen solos". Esto casi siempre termina mal: el gato se asusta, el perro se excita, el gato arañó al perro, el perro persiguió al gato, y ahora tienes dos animales que se odian y un problema conductual de meses por delante.

La clave es la **introducción gradual y controlada**, que puede llevar entre 1 y 4 semanas según los animales, pero que garantiza una convivencia pacífica y duradera.

## Fase 1: Separación total con intercambio de olores (días 1-3)

Instala al recién llegado en una habitación con puerta cerrada. Que cada animal explore las zonas del otro sin contacto visual. Intercambia mantas o cojines entre los dos para que se acostumbren al olor del otro. Si el perro huele la manta del gato sin agitarse, es una buena señal.

Dale a cada animal sus comidas cerca de la puerta que los separa, a distancia suficiente para que no se estresen. Con el tiempo, ve acercando los comederos a la puerta.

## Fase 2: Contacto visual a través de una barrera (días 4-7)

Abre la puerta con una barrera (una valla de bebé, por ejemplo) que impida el paso físico pero permita el contacto visual. Premia a ambos animales con golosinas cuando se miren sin reaccionar de forma intensa.

Señales de que va bien: ambos animales se miran brevemente y se alejan sin tensión aparente.

Señales de que hay que ralentizar: el perro ladra, intenta derribar la barrera o está obsesionado con la presencia del gato. El gato siseó, bufó, orinó fuera del arenero o dejó de comer.

## Fase 3: Contacto físico supervisado (días 8-14)

Permite que el gato tenga acceso libre a la zona del perro, pero no al revés. El gato debe poder salir si lo necesita. El perro debe estar en correa o en un lugar acotado. Nunca dejes solo al perro con libertad de movimiento y al gato sin escapatoria.

**Asegúrate de que el gato siempre tiene zonas elevadas** a las que el perro no pueda llegar: estanterías, árboles para gatos, encimeras. Esto le da al gato sensación de control y seguridad.

## Razas con más dificultades

Las razas con alto instinto de presa (Greyhound, Husky, Malinois, Jack Russell) requieren un proceso más largo y supervisión más estricta de forma indefinida. Esto no significa que no puedan convivir con gatos, pero el trabajo inicial es mayor.

Los gatos que han convivido con perros previamente se adaptan mucho más rápido que los que no han tenido ningún contacto.

## Cuándo pedir ayuda profesional

Si tras 4 semanas siguiendo el protocolo el perro sigue obsesionado con el gato o el gato sigue sin comer, escondido o sin usar el arenero, es momento de consultar a un etólogo. No significa fracaso: algunos perfiles de animales necesitan un plan personalizado.
''',
    ),

    Article(
      id: '9',
      title: 'Perros senior en adopción: el amor más ignorado',
      summary:
          'Los perros mayores de 7 años son los menos adoptados de los refugios y los primeros en ser sacrificados. Sin embargo, tienen ventajas enormes como mascotas.',
      author: 'Dr. Roberto Iglesias, veterinario geriátrico',
      publishedAt: DateTime.now().subtract(const Duration(days: 65)),
      tags: ['adopción', 'senior', 'bienestar'],
      content: '''
## La injusticia de los cachorros

En cualquier refugio, el patrón es siempre el mismo: los cachorros se adoptan en días; los adultos jóvenes, en semanas; y los perros senior esperan meses o años. Muchos mueren en el refugio sin haber encontrado nunca un hogar definitivo.

El motivo es comprensible emocionalmente —nadie quiere enfrentarse al duelo antes de tiempo— pero la premisa está basada en un malentendido: **adoptar un perro senior no es adoptar un perro enfermo, es adoptar sabiduría, calma y un amor ya formado**.

## Qué es un perro "senior"

Depende de la raza y el tamaño. Un perro gigante (Dogo de Burdeos, San Bernardo) puede considerarse senior a los 5-6 años. Un perro de tamaño pequeño (Chihuahua, Yorkshire) puede tener plena vitalidad hasta los 10-12 años. En general, los veterinarios consideramos "senior" a los perros a partir de los 7-8 años en razas medianas.

## Las ventajas reales de adoptar un perro mayor

**Carácter ya formado.** Con un cachorro, nunca sabes cómo va a ser de adulto. Con un perro mayor, lo que ves es lo que hay: ya conoces su nivel de energía, su relación con niños, gatos u otros perros, si ladra mucho, si es tranquilo o activo.

**Sin fase destructiva.** Los cachorros mascan todo lo que encuentran durante meses. Los perros adultos ya han superado esa fase.

**Educación básica.** La mayoría de los perros adultos en refugios ya saben hacer sus necesidades fuera, caminar con correa y responder a comandos básicos.

**Requieren menos ejercicio intenso.** Perfectos para personas mayores, personas con movilidad reducida o estilos de vida más tranquilos.

**Gratitud palpable.** Muchos propietarios de perros adoptados en edad avanzada describen un vínculo especial: como si el perro supiera que le has salvado la vida.

## Su salud: qué esperar

Un perro senior bien cuidado puede tener muchos años de vida de calidad por delante. Los problemas más comunes:
- **Artritis**: muy manejable con antiinflamatorios, fisioterapia y adaptaciones del hogar (rampas, camas ortopédicas).
- **Deterioro dental**: revisiones dentales periódicas y limpieza profesional bajo anestesia.
- **Cambios metabólicos**: posible hipotiroidismo, enfermedad de Cushing, diabetes. Todos manejables con diagnóstico temprano.

Una revisión veterinaria completa al adoptarle y controles semestrales son suficientes para detectar y manejar la mayoría de condiciones.

## El regalo del tiempo

Sí, es posible que un perro adoptado con 9 años viva contigo solo 4 o 5 más. Pero esos años serán años plenos, llenos de amor y de una gratitud que los cachorros aún no saben dar. Y cuando llegue el momento de la despedida, lo harás sabiendo que le diste lo mejor que podías darle: un hogar, una familia y dignidad en su última etapa de vida.
''',
    ),

    Article(
      id: '10',
      title: 'Vacunación y desparasitación: el calendario que todo adoptante debe conocer',
      summary:
          'Entender el calendario vacunal y los protocolos de desparasitación te permitirá proteger a tu mascota adoptada desde el primer día y prevenir enfermedades graves.',
      author: 'Dra. Carmen Vidal, veterinaria de medicina preventiva',
      publishedAt: DateTime.now().subtract(const Duration(days: 72)),
      tags: ['salud', 'vacunación', 'prevención'],
      content: '''
## La primera visita al veterinario

Cuando adoptas un animal, **la primera visita al veterinario debe realizarse en los primeros 3-5 días**. Aunque el refugio te haya entregado un historial vacunal, es esencial que tu veterinario de confianza realice una exploración completa: peso, temperatura, auscultación cardíaca y pulmonar, revisión dental y parasitológica.

Esta visita también sirve para establecer la relación médico-paciente y programar los controles futuros.

## El calendario vacunal del perro

Las vacunas obligatorias y recomendadas varían según la comunidad autónoma, pero el esquema básico es:

**Cachorros (si adoptas uno sin vacunar):**
- A las 6-8 semanas: vacuna polivalente (moquillo, hepatitis, parvovirus, parainfluenza).
- A las 10-12 semanas: refuerzo polivalente + Leptospirosis.
- A las 14-16 semanas: otro refuerzo + antirrábica (obligatoria en muchas CC.AA.).
- Al año: primera revacunación anual.

**Adultos:**
- Rabia: obligatoria en muchas comunidades. Anual o trienal según la vacuna.
- Polivalente: anual o según el fabricante.
- Leptospirosis: anual (especialmente si el perro tiene contacto con agua estancada o roedores).

## El calendario vacunal del gato

**Vacunas esenciales:**
- Trivalente felina (rinotraqueitis, calicivirus, panleucopenia): anual o trienal según el producto.
- Leucemia felina (FeLV): especialmente importante en gatos con acceso al exterior. Anual.
- Rabia: obligatoria si el gato viaja o según normativa local.

## Desparasitación interna

Los parásitos intestinales (toxocara, tenias, giardia) son muy comunes en animales de refugio.

- **Cachorros**: cada 2 semanas hasta los 3 meses, luego mensual hasta los 6 meses.
- **Adultos**: cada 3 meses como norma general. En animales que cazan o comen carne cruda, mensual.
- **Gestantes y lactantes**: protocolo específico con el veterinario.

## Desparasitación externa

Pulgas, garrapatas y sarna requieren tratamiento preventivo continuado:
- **Antiparasitarios spot-on** (pipetas): mensuales o trimestrales según el producto.
- **Collares antiparasitarios**: duración de 4-8 meses según la marca.
- **Comprimidos orales** (como Bravecto o Simparica): de 1 a 3 meses de protección.

**Importante**: Nunca uses productos antiparasitarios de perro en gatos. Algunos principios activos como la permetrina son letales para los felinos aunque sean pequeñas dosis.

## El chip y el registro: obligatorios desde el primer día

Si el animal no viene identificado del refugio (poco probable, pues es obligatorio por ley), **la colocación del microchip y el registro en el censo municipal son tus primeras obligaciones legales** como nuevo propietario. La identificación es la única garantía de que podrás recuperar al animal si se pierde.
''',
    ),

    Article(
      id: '11',
      title: 'Cómo preparar tu hogar antes de que llegue tu nueva mascota',
      summary:
          'El "pet-proofing" del hogar es tan importante como elegir al animal adecuado. Estas adaptaciones pueden salvarle la vida durante las primeras semanas.',
      author: 'Isabel Ramos, consultora de bienestar animal',
      publishedAt: DateTime.now().subtract(const Duration(days: 80)),
      tags: ['adopción', 'bienestar', 'consejos'],
      content: '''
## Por qué preparar el hogar antes, no después

Cada año se producen miles de accidentes domésticos en mascotas recién adoptadas: intoxicaciones con plantas de interior, caídas desde alturas, electrocuciones por morder cables, o animales que se escapan por puertas o ventanas sin protección.

Un animal nuevo en un entorno desconocido está en estado de alerta máxima. Su comportamiento es impredecible: puede esconderse en lugares inaccesibles, saltar desde alturas que no evaluaría en condiciones normales, o intentar huir.

Preparar el hogar antes de su llegada es mucho más fácil que hacerlo mientras el animal ya está dentro y desorientado.

## Zonas a revisar

**Ventanas y balcones:**
Los gatos mueren cada año por el síndrome del gato volador: caídas desde pisos elevados. A diferencia de lo que se cree, un gato **no siempre cae de pie** y no siempre sobrevive. Instala redes específicas para gatos en todas las ventanas y balcones antes de que llegue.

Para perros medianos y grandes en jardines o terrazas, verifica que la valla perimetral no tiene huecos y que la altura es suficiente para la raza.

**Cables eléctricos:**
Los cachorros y algunos adultos muerden cables por exploración o por ansiedad. Usa fundas protectoras de cable o recoge los cables con canaletas. Un mordisco a un cable bajo tensión puede provocar quemaduras graves en la boca e incluso electrocución.

**Plantas tóxicas:**
Muchas plantas de interior comunes son tóxicas para perros y gatos:
- **Difenbaquia**: toxicidad alta, provoca inflamación oral grave.
- **Pothos (Epipremnum)**: muy tóxico para gatos.
- **Adelfa**: extremadamente tóxica, puede ser mortal.
- **Lirios**: nefrotóxicos para gatos, insuficiencia renal aguda.
- **Filodendro**: irritación gastrointestinal y oral.

Retira o coloca fuera de su alcance cualquier planta que no hayas verificado como segura.

**Productos de limpieza y medicamentos:**
Guárdalos en armarios cerrados con cierre de seguridad. El ibuprofeno, el paracetamol y muchos antiinflamatorios humanos son letales para perros y gatos incluso en dosis pequeñas.

**Pequeños objetos:**
Alfileres, gomas elásticas, clips, pilas de botón, monedas: todo objeto pequeño es potencialmente ingestible. Un cuerpo extraño en el tracto digestivo puede requerir cirugía urgente.

## Crea un espacio propio desde el primer día

Prepara una zona específica donde el animal pueda retirarse y sentirse seguro: una cama o casita en una esquina tranquila, alejada del paso frecuente de personas. Durante las primeras semanas, ese será su refugio cuando se sienta abrumado.

Para los gatos, añade rascadores y zonas elevadas: estanterías, árboles para gatos. El gato necesita altura para sentirse seguro y observar su entorno antes de integrarse.

## Lista de compra mínima antes de la llegada

- Cama o manta suave y lavable.
- Comedero y bebedero (de acero inoxidable, más higiénicos que los de plástico).
- Collar con chapa identificativa (incluso si tiene chip).
- Correa y arnés (para perros).
- Arenero con arena natural (para gatos). Uno por gato más uno extra.
- Transportín para el traslado y para visitas al veterinario.
- Juguetes seguros y adaptados a la especie y el tamaño.
- Alimento recomendado por el refugio (mantén el mismo durante 2 semanas antes de cambiar gradualmente).
''',
    ),

    Article(
      id: '12',
      title: 'La adopción internacional: rescates de Turquía, Rumanía y otros países',
      summary:
          'Cada vez más personas adoptan perros procedentes del exterior de España. Analizamos la realidad de estos rescates, sus ventajas y los riegos que nadie menciona.',
      author: 'Nora Blanco, veterinaria de control de importaciones',
      publishedAt: DateTime.now().subtract(const Duration(days: 88)),
      tags: ['adopción', 'internacional', 'salud'],
      content: '''
## El fenómeno de los "rescates" del exterior

En la última década, ha crecido exponencialmente la adopción de perros procedentes de países como Turquía, Rumanía, Georgia, Bosnia o Grecia. Las redes sociales han difundido imágenes desgarradoras de perreras masificadas y animales en condiciones precarias, generando una ola de solidaridad que en muchos casos es genuina y bien intencionada.

Sin embargo, detrás de esta tendencia hay realidades muy diversas que el futuro adoptante debe conocer.

## La realidad positiva: animales que realmente necesitan ayuda

Es innegable que en algunos países del este de Europa y de Oriente Próximo, las condiciones de vida de los animales callejeros son muy duras. Perreras con hacinamiento extremo, sacrificios masivos, falta de veterinaria básica. Hay organizaciones serias y transparentes que trabajan en esos países y traen animales a España con toda la documentación en regla.

Un perro adoptado a través de una organización rigurosa llegará con:
- Pasaporte europeo para animales.
- Microchip registrado.
- Vacuna antirrábica con la antigüedad requerida por la normativa europea.
- Test negativo de leishmaniasis y otras enfermedades endémicas.
- Desparasitación interna y externa reciente.

## Las señales de alerta

No todas las organizaciones operan con la misma transparencia. Algunas utilizan imágenes emotivas para recaudar fondos sin garantizar condiciones sanitarias adecuadas. Las señales de alerta incluyen:

- **No permiten visitas** al lugar de origen ni videollamadas para ver las instalaciones.
- **Solo operan por redes sociales** sin web oficial, número fiscal ni sede física.
- **Presionan** para que la decisión de adopción se tome muy rápido.
- **El perro llega sin la documentación en regla** o con papeles que no coinciden con el animal.
- **El precio de "gestión"** es muy elevado sin justificación transparente.

## Enfermedades endémicas que debes conocer

Los perros procedentes de ciertos países pueden ser portadores de enfermedades no presentes o infrecuentes en España:

- **Leishmaniasis**: transmitida por la picadura de flebótomos. Crónica e incurable (aunque manejable). Obligatorio hacer el test antes de la adopción.
- **Ehrlichia canis**: babesiosis. Transmitida por garrapatas. Puede ser grave si no se detecta a tiempo.
- **Dirofilaria (filaria cardiaca)**: gusano del corazón. Endémica en muchas zonas del Mediterráneo y el este de Europa.
- **Brucella canis**: zoonosis (transmisible a humanos). Las hembras reproductoras de países con control escaso tienen más riesgo.

**Recomendación**: Antes de que el perro internacional conviva con otros perros o con niños en casa, realiza un panel serológico completo con tu veterinario.

## ¿Es una buena opción?

Sí, con las garantías adecuadas. Si la organización es transparente, el animal viene correctamente documentado y has hecho las pruebas de salud pertinentes a la llegada, adoptar un perro del extranjero es un acto de solidaridad real.

Pero antes de mirar fuera de tu ciudad, considera si hay animales en refugios locales que necesitan igualmente un hogar. En muchos casos, la respuesta es afirmativa.
''',
    ),

    Article(
      id: '13',
      title: 'El contrato de adopción: qué debes leer antes de firmar',
      summary:
          'El contrato de adopción protege tanto al animal como al adoptante. Conocer sus cláusulas más importantes evita malentendidos y asegura el bienestar del animal.',
      author: 'Miguel Ángel Ortiz, jurista especializado en derecho animal',
      publishedAt: DateTime.now().subtract(const Duration(days: 95)),
      tags: ['adopción', 'responsabilidad', 'legislación'],
      content: '''
## Por qué existe el contrato de adopción

El contrato de adopción es el documento que formaliza la entrega de un animal entre una asociación protectora o refugio y una persona particular. No es burocracia: es la garantía de que el animal tiene un seguimiento y que el adoptante comprende sus responsabilidades.

Para la asociación, es también una herramienta legal que le permite recuperar al animal si detecta incumplimiento grave de las condiciones pactadas.

## Cláusulas habituales que debes comprender

**1. Uso del animal:**
La mayoría de contratos prohíben explícitamente usar al animal con fines de cría, para espectáculos, como reclamo publicitario o para el intercambio o venta posterior. Si firmas esto, aceptas que el animal es una mascota y no un recurso económico.

**2. Condiciones de vida:**
El contrato puede especificar que el animal debe vivir dentro del domicilio (no atado en el exterior de forma permanente), que debe tener acceso a veterinario cuando sea necesario y que no puede ser sometido a situaciones de negligencia o maltrato.

**3. Notificación de cambios vitales:**
Si cambias de domicilio, si el animal enferma gravemente, si la situación familiar cambia drásticamente (separación, mudanza al extranjero, fallecimiento del propietario), muchos contratos obligan a notificarlo a la asociación cedente.

**4. Derecho de retorno preferente:**
Si por cualquier circunstancia ya no puedes hacerte cargo del animal, el contrato habitualmente obliga a devolverlo primero a la asociación de origen, en lugar de entregarlo a un tercero o abandonarlo.

**5. Visitas de seguimiento:**
Algunas asociaciones se reservan el derecho a realizar visitas domiciliarias o a solicitar fotografías recientes del animal para verificar su bienestar. Es una cláusula legal y perfectamente razonable.

**6. Consecuencias del incumplimiento:**
El incumplimiento grave puede dar lugar a la rescisión del contrato y la recuperación del animal por parte de la asociación. En casos de maltrato, la asociación puede también interponer denuncia penal.

## Lo que el contrato no puede exigirte

El contrato de adopción no puede limitarte derechos fundamentales desproporcionadamente. Una cláusula que prohíba, por ejemplo, que el animal salga nunca de tu piso, o que te obligue a cambiar de trabajo para estar más tiempo en casa, sería abusiva y probablemente nula.

Si algo del contrato te parece desproporcionado, habla con la asociación. Las organizaciones serias están abiertas al diálogo y buscan ante todo garantizar el bienestar del animal, no dificultar la adopción.

## Guarda siempre una copia

Parece obvio, pero muchos adoptantes no lo hacen. Guarda una copia firmada del contrato junto con el historial veterinario y el número de microchip. Son documentos que podrías necesitar en el futuro, especialmente si el animal se pierde o si surge alguna disputa.
''',
    ),

    Article(
      id: '14',
      title: 'Adoptar con niños en casa: cómo hacer la presentación correctamente',
      summary:
          'Tener hijos no es un impedimento para adoptar, pero sí implica una preparación adicional. La seguridad de los niños y el bienestar del animal deben ser las prioridades.',
      author: 'Andrea Castillo, psicóloga infantil y educadora canina',
      publishedAt: DateTime.now().subtract(const Duration(days: 103)),
      tags: ['adopción', 'niños', 'comportamiento'],
      content: '''
## El mito de "una mascota educará a mis hijos"

Es una frase que los profesionales escuchamos demasiado a menudo. Los animales pueden ser un elemento valioso en el desarrollo emocional de los niños —fomentan la empatía, la responsabilidad y el vínculo afectivo—, pero **no son herramientas pedagógicas**. Son seres vivos con necesidades, miedos y límites propios.

Un hogar con niños puede ser perfectamente compatible con la adopción, pero requiere trabajo previo con los niños igual que con el animal.

## Antes de adoptar: habla con tus hijos

Antes de traer cualquier animal a casa, asegúrate de que tus hijos entienden algunas reglas básicas:
- **El animal no es un juguete**: tiene momentos en que quiere estar solo y hay que respetarlo.
- **Nunca molestar a un animal que come, duerme o está en su cama**: estos son los momentos de más riesgo de mordedura defensiva.
- **No correr ni gritar cerca del perro nuevo**: los movimientos bruscos pueden asustarlo y provocar una respuesta de miedo.
- **Siempre bajo supervisión de un adulto** durante las primeras semanas.

Los niños menores de 6 años no pueden responsabilizarse del cumplimiento de estas normas de forma autónoma. El adulto debe estar presente siempre que el niño interactúe con el animal.

## La presentación: paso a paso

**Día 1**: El animal llega a casa y necesita explorar con calma. Pide a los niños que estén tranquilos, a ser posible en otra habitación o sentados en el suelo. Deja que el animal se acerque a los niños por iniciativa propia, sin forzar el contacto.

**Primera semana**: Permite interacciones breves y supervisadas. Si el perro se aleja, los niños deben dejarlo ir sin perseguirle. Si el gato se esconde, no intentéis sacarlo de su escondite.

**Señal de alerta**: Si el animal gruñe, muestra los dientes o arquea el lomo, es una señal de que se siente amenazado. Aleja a los niños calmadamente y dale espacio. Un gruñido es comunicación, no agresión; no lo castigues o le quitarás su única señal de advertencia.

## Razas más recomendadas para familias con niños

No existe ninguna raza "segura al 100%" ni ninguna "peligrosa por naturaleza". El comportamiento depende principalmente de la historia individual del animal, su educación y el contexto. Dicho esto, algunas razas tienen perfiles más adecuados para entornos con niños muy activos:

**Perros con carácter generalmente tranquilo y tolerante**: Labrador, Golden Retriever, Beagle, Bichón Maltés, Cocker Spaniel.

**Perros que requieren más supervisión con niños pequeños**: razas de trabajo con alto instinto de presa o de pastoreo (Border Collie, Pastor Alemán, Malinois), y razas pequeñas nerviosas (Chihuahua) que pueden morder por miedo.

**En adopciones de adultos**: Pide al refugio información específica sobre cómo ha reaccionado el animal previamente con niños. Esta información vale más que cualquier generalización sobre razas.

## El beneficio real para los niños

Cuando la adopción se hace correctamente, los beneficios para los niños son enormes:
- Aprenden a leer el lenguaje corporal y a respetar los límites de otro ser vivo.
- Desarrollan empatía y responsabilidad.
- Tienen un compañero incondicional durante su infancia.
- Las investigaciones muestran que los niños que crecen con mascotas tienen sistemas inmunitarios más fuertes y menor riesgo de alergias.

La clave está en la preparación, la supervisión y el respeto mutuo.
''',
    ),

    Article(
      id: '15',
      title: 'Los gatos de colonia: TNR y coexistencia urbana',
      summary:
          'Las colonias de gatos callejeros son una realidad en todas las ciudades españolas. El método TNR (Trampa, Neuter, Retorno) es hoy el más respaldado por la ciencia y la legislación.',
      author: 'Dra. Lucía Herrera, veterinaria municipal y gestora de colonias',
      publishedAt: DateTime.now().subtract(const Duration(days: 112)),
      tags: ['gatos', 'TNR', 'bienestar'],
      content: '''
## Qué es una colonia de gatos

Una colonia de gatos es un grupo de gatos domésticos (Felis catus) que viven en libertad en un territorio urbano o periurbano, sin ser propiedad de ninguna persona en particular, aunque habitualmente hay vecinos que les proporcionan alimento y cuidados básicos.

En España, se estima que hay entre 3 y 5 millones de gatos callejeros. Son el resultado acumulado de décadas de abandonos y reproducción incontrolada.

## Por qué el sacrificio masivo no funciona

Durante décadas, la respuesta municipal al problema de los gatos callejeros fue la captura y el sacrificio. Los datos demuestran que esta estrategia es ineficaz: eliminar a los gatos de una zona solo crea un vacío ecológico que otros gatos —o ratas— se apresuran a ocupar. El fenómeno se llama **efecto vacío** y está documentado en decenas de estudios internacionales.

Además, el sacrificio masivo tiene un coste social y económico muy elevado, y genera un enorme rechazo ciudadano.

## El método TNR: en qué consiste

**TNR** son las siglas de **Trap, Neuter, Return** (Trampa, Esterilización, Retorno). Consiste en:

1. **Capturar** a los gatos de la colonia con trampas humanitarias.
2. **Esterilizarlos** quirúrgicamente.
3. **Vacunarlos** contra la rabia y el panleucopenia.
4. **Marcarlos** (habitualmente recortando la punta de la oreja izquierda bajo anestesia, lo que se llama "ear-tipping").
5. **Devolverlos** a su territorio.

El resultado a medio plazo (5-10 años) es una reducción gradual y estable de la colonia por envejecimiento natural, sin que se reponga con nuevos individuos.

## La ley de bienestar de 2023 y las colonias

La Ley 7/2023 de Bienestar Animal reconoce por primera vez a nivel estatal el método TNR como estrategia válida de gestión de colonias felinas, y obliga a los municipios a desarrollar registros de colonias y programas de gestión. Esto ha supuesto un enorme avance, aunque la implementación real varía mucho según el municipio.

## Quiénes son los coloneros y las coloneras

Los **gestores de colonia** (popularmente, "coloneros" o "coloneras") son voluntarios —en su inmensa mayoría mujeres— que de forma totalmente altruista alimentan, esterilizan y cuidan a las colonias de su barrio. Muchos de ellos invierten cientos de euros al año de su propio bolsillo en comida y veterinaria.

Lejos del estereotipo negativo que a veces reciben, los gestores de colonia son un servicio público no remunerado que ahorra millones de euros a los ayuntamientos en gestión de fauna urbana.

## Cómo puedes colaborar

- Contacta con tu asociación local de protección de gatos para saber si hay colonias registradas en tu zona.
- Si encuentras una colonia sin gestionar, puedes denunciarla a la protectora local o al servicio municipal de animales para que inicien el protocolo TNR.
- Apoya económicamente las clínicas de esterilización de bajo coste que trabajan con colonias.
- Si encuentras a un gatito de pocos días sin madre, contacta con una asociación: no lo críes en casa sin orientación profesional, es mucho más complicado de lo que parece.
''',
    ),

    Article(
      id: '16',
      title: 'Adoptar un conejo: el animal más abandonado tras perros y gatos',
      summary:
          'Los conejos son el tercer animal doméstico más abandonado en España y el más incomprendido. Conocer sus verdaderas necesidades es el primer paso para cuidarlos bien.',
      author: 'Patricia Leal, coordinadora de AdoConejos España',
      publishedAt: DateTime.now().subtract(const Duration(days: 120)),
      tags: ['adopción', 'conejos', 'bienestar'],
      content: '''
## Por qué se abandona tanto a los conejos

El conejo es la víctima perfecta de expectativas erróneas. Se vende como un animal "fácil", "barato" y "silencioso", perfecto para niños pequeños. La realidad es completamente distinta:

- **No son silenciosos**: Golpean el suelo con fuerza cuando están asustados o descontentos. Por la noche, pueden ser muy activos.
- **No les gusta que los cojan en brazos**: Son presas en la naturaleza y el ser levantados del suelo les genera un terror instintivo. Si forcejean, pueden fracturarse la columna vertebral.
- **No son baratos**: Requieren veterinario especializado en exóticos (más caro que uno generalista), esterilización, alojamiento amplio y una dieta específica.
- **Viven entre 8 y 12 años**: No son un compromiso de "solo unos años".

El resultado previsible: el conejo que se regaló por Navidad o Pascua acaba en un refugio antes del verano.

## Sus necesidades reales

**Espacio**: Un conejo adulto necesita como mínimo **4 m² de espacio para moverse libremente**. Una jaula pequeña, sin libertad de movimiento durante horas, es una forma de maltrato aunque esté llena de comida y agua.

**Compañía de su especie**: Los conejos son animales sociales. Un conejo solo pasa muchas horas sin estímulos y puede desarrollar depresión. La solución ideal es adoptar en pareja (macho-hembra esterilizados).

**Dieta correcta**: El 80% de la dieta debe ser **heno de calidad ad libitum** (siempre disponible). El heno es esencial para su sistema digestivo y para el desgaste dental. Sin heno suficiente, desarrollan problemas dentales graves en pocos meses. El resto: verduras de hoja verde (lechuga romana, achicoria, perejil) y pienso en pequeña cantidad.

**Alimentos prohibidos**: Lechuga iceberg, todas las frutas en exceso, carbohidratos, semillas, muesli para conejos (muy azucarado), aguacate, cebolla, ajo, rábano.

**Veterinario especialista**: NO todos los veterinarios tratan a los conejos correctamente. Busca uno especializado en animales exóticos. La anestesia, la cirugía y el diagnóstico en conejos requieren formación específica.

## La esterilización es imprescindible

Las conejas no esterilizadas tienen un **riesgo del 80% de desarrollar cáncer de útero antes de los 5 años**. La esterilización elimina este riesgo y mejora notablemente su carácter. Los machos esterilizados marcan menos con orina y monturas, y conviven mejor con otros conejos.

## La personalidad del conejo: lo que pocos saben

Un conejo que vive en condiciones adecuadas tiene una personalidad fascinante: tiene humor, reconoce a sus cuidadores, solicita caricias, juega con objetos y se comunica de formas muy precisas. El "binky" —ese salto y giro en el aire— es su manera de expresar alegría pura.

Si alguna vez has visto hacer "binky" a un conejo, entiendes por qué merece la pena aprender a cuidarlos bien.
''',
    ),

    Article(
      id: '17',
      title: 'Viajar con tu mascota adoptada: guía práctica para España y Europa',
      summary:
          'El verano ya no es excusa para el abandono. Cada vez más medios de transporte y alojamientos admiten mascotas. Te explicamos cómo planificarlo sin complicaciones.',
      author: 'Marta Espinosa, veterinaria y viajera con tres perros adoptados',
      publishedAt: DateTime.now().subtract(const Duration(days: 130)),
      tags: ['consejos', 'viajes', 'bienestar'],
      content: '''
## El abandono estival: una vergüenza evitable

España tiene el triste honor de ser uno de los países con mayor tasa de abandono estival de Europa. Cada verano, decenas de miles de animales son abandonados en carreteras, refugios saturados o directamente en la naturaleza cuando sus propietarios se marchan de vacaciones.

La buena noticia es que la situación ha mejorado mucho en los últimos años: hay más opciones que nunca para viajar con tu mascota o para dejarla bien cuidada durante tu ausencia.

## Viajar en coche con tu perro o gato

El coche es el medio más flexible y cómodo para viajar con mascotas. Sin embargo, hay normas legales que debes conocer:

La **DGT española** exige que los animales vayan correctamente sujetos o contenidos durante la conducción. Las opciones válidas son:
- **Transportín homologado** en el asiento trasero o en el maletero con rejilla de separación.
- **Arnés de seguridad** homologado conectado al cinturón de seguridad.
- **Rejilla divisoria** entre el habitáculo y el maletero.

Llevar al perro suelto en el coche está prohibido. Las multas pueden llegar a 200 €, pero sobre todo, en caso de accidente, un perro suelto se convierte en un proyectil que puede matar tanto al animal como a los ocupantes.

## Viajar en avión

La mayoría de aerolíneas permiten viajar con mascotas, pero las condiciones varían mucho según la compañía:

- **En cabina**: Solo para perros y gatos cuyo transportín no supere dimensiones establecidas por la aerolínea (habitualmente 45x25x25 cm) y cuyo peso total (animal + transportín) sea inferior a 8-10 kg.
- **En bodega presurizada**: Para animales más grandes. Requiere transportín homologado IATA y gestión especial.

**Importante**: El transporte en bodega no está exento de riesgos, especialmente para razas braquicéfalas (Bulldog, Pug, Boston Terrier). Consulta con tu veterinario antes de decidir.

## Documentación necesaria para viajar dentro de la UE

Para viajar con tu mascota a otro país de la Unión Europea necesitas:
- **Pasaporte europeo para animales**, tramitado por tu veterinario.
- **Microchip** implantado y registrado.
- **Vacuna antirrábica** en vigor, administrada por un veterinario habilitado.

Para algunos países (Reino Unido, Irlanda, Malta, Finlandia, Noruega) existen requisitos adicionales, como tratamiento antiparasitario certificado. Consulta con tu veterinario o en la web de la UE con al menos 3 meses de antelación.

## Alojamientos pet-friendly

La oferta de alojamientos que admiten mascotas ha crecido enormemente. Busca en:
- **Booking.com** con filtro "se admiten mascotas".
- **Bringfido.com**: directorio internacional de alojamientos y actividades pet-friendly.
- **Casas rurales**: muchas en España son pet-friendly, especialmente para perros medianos y grandes.

Llama siempre antes de reservar para confirmar las condiciones exactas: algunos alojamientos tienen restricciones de tamaño o número de animales, o cobran un suplemento.

## Si no puedes viajar con tu mascota

Existen varias alternativas serias al abandono:
- **Residencias caninas y felinas**: Muchas tienen estándares muy altos. Pide referencias y visita las instalaciones antes de temporada alta.
- **Cuidadores a domicilio (pet sitters)**: Plataformas como Rover o Gudog permiten encontrar cuidadores verificados que atienden al animal en su propio hogar.
- **Red de amigos y familia**: La opción más económica, siempre que la persona conozca al animal y tenga experiencia.

El abandono nunca es una opción. Es un delito tipificado en el Código Penal español con penas de hasta 18 meses de prisión.
''',
    ),

    Article(
      id: '18',
      title: 'La salud mental de los animales adoptados: ansiedad por separación',
      summary:
          'La ansiedad por separación es el trastorno conductual más común en perros adoptados. Aprende a reconocerla, prevenirla y tratarla sin medicación en muchos casos.',
      author: 'Dr. Alejandro Fuentes, médico veterinario conductista',
      publishedAt: DateTime.now().subtract(const Duration(days: 140)),
      tags: ['comportamiento', 'ansiedad', 'salud'],
      content: '''
## ¿Qué es la ansiedad por separación?

La ansiedad por separación (APS) es un trastorno en el que el animal experimenta un nivel de angustia desproporcionado cuando se queda solo o se anticipa que va a quedarse solo. No es capricho ni "venganza": es sufrimiento real que el animal no puede controlar.

Es extremadamente común en perros adoptados, especialmente en aquellos que han pasado por varias casas, han estado mucho tiempo en perreras o han sufrido abandono.

## Señales que debes reconocer

No toda conducta destructiva es ansiedad por separación. Las señales específicas incluyen:

- Destrucción que ocurre **exclusivamente cuando el perro está solo** (no cuando estás en casa).
- Vocalizaciones (ladridos, aullidos, llantos) que comienzan justo después de que te vas o poco antes.
- Escapismo: intentos de escapar del hogar, rasguños en puertas y ventanas.
- Micción o defecación en casa **solo cuando está solo** y en un perro que normalmente controla sus esfínteres.
- Inapetencia: no come ni bebe cuando se queda solo.
- Comportamientos de seguimiento ("sombra"): el perro te sigue a todas partes dentro del hogar y se agita cuando anticipas salir (coges las llaves, te pones los zapatos).

## El diagnóstico diferencial

Antes de concluir que es APS, debes descartar:
- **Problemas médicos** que generen dolor o incontinencia.
- **Aburrimiento** o falta de estimulación: un perro que destruye pero solo cuando hay algo interesante cerca, no es APS.
- **Miedo a estímulos específicos** (truenos, coches) que no tienen relación con tu ausencia.

Si es posible, instala una cámara y graba lo que ocurre mientras estás fuera. Ver las imágenes te dará mucha más información que cualquier suposición.

## Plan de tratamiento: la desensibilización gradual

El tratamiento de elección (sin medicación en casos leves-moderados) es la **desensibilización gradual a la soledad**:

**Paso 1**: Trabaja la independencia dentro del hogar. Deja que el perro se quede en otra habitación mientras tú estás en casa. Premia que esté tranquilo en su cama sin seguirte.

**Paso 2**: Practica salidas ultracortas. Sal de casa 30 segundos, vuelve. Repite. Aumenta gradualmente a 1 minuto, 2, 5, 10. Todo sin drama: no te despidas efusivamente ni al salir ni al volver.

**Paso 3**: Desasocia las señales de salida de la angustia. Coge las llaves varias veces al día sin salir. Ponte los zapatos y siéntate en el sofá. El perro aprenderá que estas señales no predicen automáticamente tu marcha.

**Paso 4**: Enriquecimiento ambiental. Kongs rellenos congelados, juguetes de actividad mental, música relajante, olfateo outdoor antes de dejarlo solo. Un perro físicamente cansado y mentalmente estimulado tolera mejor la soledad.

## Cuándo la medicación ayuda

En casos graves (el perro se hace daño intentando escapar, panics totales), la medicación puede usarse como apoyo temporal al trabajo conductual. Los ansiolíticos no curan la APS pero reducen el nivel de angustia lo suficiente para que el aprendizaje progrese. Nunca deben usarse solos sin trabajo conductual paralelo. Consulta con un veterinario conductista, no con uno generalista.
''',
    ),

    Article(
      id: '19',
      title: 'El duelo por la pérdida de una mascota adoptada: validar el dolor',
      summary:
          'Perder a un animal adoptado es una pérdida real que merece un duelo real. La ciencia avala que el vínculo humano-animal activa los mismos circuitos cerebrales que las pérdidas humanas.',
      author: 'Sofía Navarro, psicóloga especializada en duelo por animales',
      publishedAt: DateTime.now().subtract(const Duration(days: 150)),
      tags: ['bienestar', 'vínculo', 'salud'],
      content: '''
## "Solo era un perro"

Es la frase más cruel que puede escuchar alguien que acaba de perder a su mascota. Y es, además, una frase que la neurociencia desmiente completamente.

Los estudios de neuroimagen muestran que el vínculo con una mascota activa en el cerebro humano los mismos sistemas de apego que el vínculo con otros humanos cercanos. La pérdida de ese vínculo genera un duelo que los investigadores describen como comparable a la pérdida de un familiar o un amigo íntimo.

Esto no es debilidad emocional: es biología.

## Por qué el duelo por un animal adoptado puede ser más intenso

El vínculo con un animal adoptado tiene características específicas que pueden intensificar el duelo:

- **La historia compartida de rescate**: Muchos propietarios de animales adoptados sienten que "salvaron" a ese animal o que "el animal los salvó a ellos". Esto crea una narrativa emocional muy potente.
- **La culpa del "podría haber hecho más"**: Cuando el animal muere de enfermedad, muchos propietarios se preguntan si deberían haber detectado los síntomas antes, haber invertido en otro tratamiento, haber tomado otra decisión.
- **La invisibilidad social del duelo**: La sociedad todavía no reconoce plenamente el duelo por animales, lo que deja a las personas sin el apoyo social que sí obtendrían ante otra pérdida.

## Las fases del duelo: no son lineales

El modelo de Kübler-Ross (negación, ira, negociación, depresión, aceptación) es útil como marco general, pero el duelo real no sigue un orden fijo. Es perfectamente normal:

- Llorar desconsoladamente un día y sentirse relativamente bien al siguiente.
- Sentir ira (hacia el veterinario, hacia uno mismo, hacia la enfermedad) como parte del proceso.
- Tener "momentos de olvido" en los que por un instante te olvidas de la pérdida y luego el recuerdo vuelve con más intensidad.
- Extrañar objetos concretos: el sonido de sus pasos, su olor, su peso en la cama.

## Cómo acompañar el duelo propio

**Permítete sentir.** No te exijas "superarlo" en un tiempo determinado. El duelo por una mascota puede durar meses. Cada persona, cada vínculo y cada pérdida es única.

**Crea un ritual de despedida.** Un funeral sencillo, enterrar sus cenizas en un lugar significativo, plantar un árbol, hacer un álbum de fotos. Los rituales ayudan al cerebro a procesar la realidad de la pérdida.

**Habla con alguien que entienda.** Existen grupos de apoyo para personas que han perdido mascotas, tanto presenciales como online. Compartir el dolor con quienes lo comprenden alivia el aislamiento.

**Cuida tu cuerpo.** El duelo tiene manifestaciones físicas: alteraciones del sueño, inapetencia, fatiga. Come, duerme y muévete aunque no tengas ganas.

## ¿Cuándo me planteo adoptar de nuevo?

No hay una respuesta correcta. Algunas personas se sienten listas al cabo de semanas, otras necesitan años. La señal más fiable no es el tiempo transcurrido, sino cómo te planteas la nueva adopción: si es para "sustituir" al animal perdido y callar el dolor, probablemente es demasiado pronto. Si es porque has procesado la pérdida y sientes que tienes de nuevo amor y energía para dar a un nuevo ser vivo, entonces el momento puede ser el adecuado.

Un nuevo animal no borra la memoria del anterior. Lo honra.
''',
    ),

    Article(
      id: '20',
      title: 'Voluntariado en refugios de animales: cómo empezar y qué esperar',
      summary:
          'El voluntariado en protectoras es una de las formas más directas de ayudar a los animales mientras esperan su hogar definitivo. Pero también tiene su lado duro.',
      author: 'David Morales, coordinador de voluntarios en Refugio Animal Castilla',
      publishedAt: DateTime.now().subtract(const Duration(days: 160)),
      tags: ['voluntariado', 'adopción', 'bienestar'],
      content: '''
## Por qué los refugios necesitan voluntarios

La mayoría de los refugios de animales en España son entidades sin ánimo de lucro que operan con presupuestos muy ajustados. El número de empleados remunerados suele ser mínimo: uno o dos cuidadores, tal vez un veterinario a tiempo parcial. El resto del trabajo lo sostienen los voluntarios.

Sin voluntarios, muchos refugios serían incapaces de ofrecer a los animales algo más que comida y agua. Los paseos, la socialización, los juegos, el entrenamiento básico, la fotografía para la ficha de adopción, la gestión de redes sociales, el transporte al veterinario: todo eso depende en gran medida del voluntariado.

## Qué hace un voluntario en un refugio

**Con los animales:**
- Paseos individuales o en grupos pequeños (perros).
- Sesiones de juego y enriquecimiento ambiental.
- Socialización con personas y con otros animales.
- Entrenamiento básico con refuerzo positivo.
- Simplemente pasar tiempo con ellos: acariciarlos, hablarles, que sientan que no están solos.

**Tareas de apoyo:**
- Fotografía y vídeo para perfiles de adopción.
- Gestión de redes sociales y difusión de animales adoptables.
- Organización de eventos de adopción y recaudación.
- Transporte de animales a citas veterinarias.
- Limpieza y mantenimiento de instalaciones.

## El lado duro que nadie te cuenta

El voluntariado en refugios es una experiencia profundamente enriquecedora. También puede ser emocionalmente agotadora.

Verás animales que llevan meses o años esperando. Vivirás la alegría de una adopción y, a veces, el dolor del regreso de un animal a quien creías ya colocado. Si el refugio no tiene política de no-sacrificio, podrías enfrentarte a situaciones muy duras.

Es fundamental que los refugios ofrezcan a sus voluntarios formación y apoyo emocional. Si un refugio no lo hace, plantéatelo antes de comprometerte a largo plazo.

## Cómo empezar

1. **Busca refugios en tu zona**: Muchas protectoras tienen formulario de alta de voluntarios en su web.
2. **Asiste a una jornada de orientación**: La mayoría realizan sesiones de bienvenida para nuevos voluntarios.
3. **Empieza despacio**: Comprométete con una frecuencia realista y sostenible. Dos horas a la semana de forma constante es más valioso que ir todos los fines de semana durante dos meses y luego desaparecer.
4. **Sé puntual y comunicativo**: Los animales esperan a sus voluntarios. La continuidad importa.

## Otras formas de ayudar sin ir en persona

Si tu situación no te permite ir físicamente, hay otras formas valiosas de colaborar:
- **Donaciones económicas** —incluso pequeñas— que ayudan a costear veterinaria.
- **Donaciones en especie**: comida, mantas, medicamentos indicados por el refugio.
- **Difusión en redes sociales** de animales en adopción: cada compartir puede ser la diferencia entre encontrar hogar en semanas o en meses.
- **Acogida temporal**: como se explicó en otro artículo, es una de las formas más directas e impactantes de ayudar.

El mundo es un lugar mejor gracias a las personas que cada día, sin cámaras ni reconocimiento, entran en un refugio y le dan a cada animal un poco de tiempo, de cariño y de dignidad.
''',
    ),
  ];
}
