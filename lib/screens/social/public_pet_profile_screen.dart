import 'package:flutter/material.dart';
import 'dart:io' show File;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nachos_pet_care_flutter/providers/auth_provider.dart';
import 'package:nachos_pet_care_flutter/models/public_pet.dart';
import 'package:nachos_pet_care_flutter/models/public_pet_photo.dart';
import 'package:nachos_pet_care_flutter/models/public_comment.dart';
import 'package:nachos_pet_care_flutter/services/social_service.dart';
import 'package:nachos_pet_care_flutter/services/service_locator.dart';

class PublicPetProfileScreen extends StatefulWidget {
  final String petId;
  const PublicPetProfileScreen({super.key, required this.petId});

  @override
  State<PublicPetProfileScreen> createState() => _PublicPetProfileScreenState();
}

class _PublicPetProfileScreenState extends State<PublicPetProfileScreen> {
  final SocialService _social = getIt<SocialService>();
  PublicPet? _pet;
  List<PublicPetPhoto> _photos = [];
  bool _isFollowing = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final pet = await _social.getPublicPetById(widget.petId);
      if (pet == null) {
        if (mounted) {
          setState(() {
            _error = 'Mascota no encontrada en la red social';
            _isLoading = false;
          });
        }
        return;
      }

      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      bool following = false;
      if (auth.user != null) {
        following = await _social.isFollowing(auth.user!.id, pet.id);
      }

      List<PublicPetPhoto> photos = [];
      if (pet.isGalleryPublic) {
        photos = await _social.getPetPhotos(pet.id);
      }

      if (mounted) {
        setState(() {
          _pet = pet;
          _isFollowing = following;
          _photos = photos;
          _isLoading = false;
        });

        // Comprobación de parámetro deep-link para abrir foto
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final uri = Uri.parse(ModalRoute.of(context)?.settings.name ?? '');
          final openPhotoId = uri.queryParameters['openPhoto'];
          if (openPhotoId != null) {
            final photoIndex = _photos.indexWhere((p) => p.id == openPhotoId);
            if (photoIndex != -1) {
              _showPhotoDetails(_photos[photoIndex]);
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar perfil público: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFollow() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para seguir mascotas')),
      );
      return;
    }

    if (_pet == null) return;

    try {
      if (_isFollowing) {
        await _social.unfollowPet(auth.user!.id, _pet!.id);
      } else {
        await _social.followPet(auth.user!.id, _pet!.id);
      }
      
      // Recargar datos para refrescar contador y estado
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar seguimiento: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _pet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil Público')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  _error ?? 'No se pudo cargar la mascota',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final auth = context.watch<AuthProvider>();
    final isOwnPet = auth.user?.id == _pet!.ownerId;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header / Portada de la mascota
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _pet!.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _pet!.photoPath != null
                      ? (_pet!.photoPath!.startsWith('http')
                          ? Image.network(_pet!.photoPath!, fit: BoxFit.cover)
                          : Image.file(File(_pet!.photoPath!), fit: BoxFit.cover))
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [colorScheme.primary, colorScheme.secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(Icons.pets, size: 100, color: Colors.white54),
                        ),
                  // Degradado inferior para legibilidad del texto
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Información básica y estadísticas
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'De ${_pet!.ownerName}',
                              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 15),
                            ),
                            if (_pet!.breed != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _pet!.breed!,
                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!isOwnPet) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _toggleFollow,
                              icon: Icon(_isFollowing ? Icons.star : Icons.star_border),
                              label: Text(_isFollowing ? 'Siguiendo' : 'Seguir'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isFollowing ? colorScheme.secondaryContainer : colorScheme.primary,
                                foregroundColor: _isFollowing ? colorScheme.onSecondaryContainer : colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filled(
                              onPressed: () {
                                context.push('/chats/${_pet!.ownerId}?name=${Uri.encodeComponent(_pet!.ownerName)}');
                              },
                              icon: const Icon(Icons.chat_bubble_outline),
                              style: IconButton.styleFrom(
                                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                                foregroundColor: colorScheme.primary,
                              ),
                              tooltip: 'Enviar Mensaje',
                            ),
                          ],
                        ),
                      ] else ...[
                        Chip(
                          label: const Text('Mi Mascota'),
                          backgroundColor: colorScheme.primaryContainer,
                          labelStyle: TextStyle(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Caja de datos / Atributos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('Seguidores', '${_pet!.followersCount}', Icons.star, Colors.amber),
                      _buildStatCard('Tipo', _pet!.typeDisplayName, Icons.category, Colors.blue),
                      if (_pet!.ageInYears != null)
                        _buildStatCard('Edad', '${_pet!.ageInYears} años', Icons.calendar_today, Colors.green),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Notas o Bio
                  if (_pet!.notes != null && _pet!.notes!.isNotEmpty) ...[
                    const Text(
                      'Sobre mí',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      color: colorScheme.surfaceContainerLow,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.format_quote, color: colorScheme.primary, size: 28),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _pet!.notes!,
                                style: const TextStyle(fontSize: 15, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Sección de Galería
                  const Text(
                    'Galería',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Contenido de la Galería
          if (!_pet!.isGalleryPublic)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
                  child: Column(
                    children: [
                      Icon(Icons.lock_outline, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      const Text(
                        'Galería Privada',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'El dueño de esta mascota ha decidido mantener su galería privada.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_photos.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Column(
                    children: [
                      Icon(Icons.photo_library_outlined, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      const Text(
                        'No hay fotos publicadas',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final photo = _photos[index];
                    return InkWell(
                      onTap: () => _showPhotoDetails(photo),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: photo.photoPath.startsWith('http')
                            ? Image.network(photo.photoPath, fit: BoxFit.cover)
                            : Image.file(File(photo.photoPath), fit: BoxFit.cover),
                      ),
                    );
                  },
                  childCount: _photos.length,
                ),
              ),
            ),
          
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIALOG DETAIL PHOTO WITH COMMENTS ---
  void _showPhotoDetails(PublicPetPhoto photo) {
    final colorScheme = Theme.of(context).colorScheme;
    final auth = context.read<AuthProvider>();
    final TextEditingController commentController = TextEditingController();
    List<PublicComment> comments = [];
    bool isLoadingComments = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Cargar comentarios una vez
            if (isLoadingComments) {
              _social.getComments(photo.id).then((list) {
                if (context.mounted) {
                  setModalState(() {
                    comments = list;
                    isLoadingComments = false;
                  });
                }
              });
            }

            Future<void> submitComment() async {
              if (commentController.text.trim().isEmpty) return;
              if (auth.user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Debes iniciar sesión para comentar')),
                );
                return;
              }

              final text = commentController.text.trim();
              commentController.clear();

              try {
                final newComment = await _social.addComment(
                  photo.id,
                  auth.user!.id,
                  auth.user!.fullName,
                  text,
                );
                
                setModalState(() {
                  comments.add(newComment);
                });
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al enviar comentario: $e')),
                );
              }
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Barra de arrastre superior
                      Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: [
                            // Foto
                            AspectRatio(
                              aspectRatio: 1.2,
                              child: photo.photoPath.startsWith('http')
                                  ? Image.network(photo.photoPath, fit: BoxFit.cover)
                                  : Image.file(File(photo.photoPath), fit: BoxFit.cover),
                            ),
                            
                            // Notas
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('dd/MM/yyyy · HH:mm').format(photo.date),
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                  if (photo.notes != null && photo.notes!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      photo.notes!,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Divider(height: 1),

                            // Comentarios cabecera
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'Comentarios',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),

                            // Lista de comentarios
                            if (isLoadingComments)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else if (comments.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: Text(
                                    'Sé el primero en comentar esta foto 🐾',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: comments.length,
                                itemBuilder: (context, index) {
                                  final comment = comments[index];
                                  return ListTile(
                                    leading: const CircleAvatar(
                                      child: Icon(Icons.person, size: 20),
                                    ),
                                    title: Text(
                                      comment.userName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    subtitle: Text(comment.commentText),
                                    trailing: Text(
                                      DateFormat('HH:mm').format(comment.createdAt),
                                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),

                      // Input Bar
                      Padding(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                          top: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: commentController,
                                decoration: InputDecoration(
                                  hintText: 'Añadir un comentario...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => submitComment(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filled(
                              onPressed: submitComment,
                              icon: const Icon(Icons.send),
                              style: IconButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
