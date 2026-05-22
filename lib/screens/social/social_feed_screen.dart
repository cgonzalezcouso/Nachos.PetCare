import 'package:flutter/material.dart';
import 'dart:io' show File;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:nachos_pet_care_flutter/providers/auth_provider.dart';
import 'package:nachos_pet_care_flutter/providers/pet_provider.dart';
import 'package:nachos_pet_care_flutter/models/pet.dart';
import 'package:nachos_pet_care_flutter/models/public_pet.dart';
import 'package:nachos_pet_care_flutter/models/public_pet_photo.dart';
import 'package:nachos_pet_care_flutter/services/social_service.dart';
import 'package:nachos_pet_care_flutter/services/service_locator.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> with SingleTickerProviderStateMixin {
  final SocialService _social = getIt<SocialService>();
  late TabController _tabController;

  // Descubrir State
  List<PublicPet> _publicPets = [];
  bool _isLoadingDiscover = true;
  final TextEditingController _searchController = TextEditingController();

  // Siguiendo State
  List<Map<String, dynamic>> _feedItems = [];
  bool _isLoadingFeed = true;

  // Mis Mascotas State
  Map<String, bool> _publishedStatus = {};
  Map<String, bool> _galleryStatus = {};
  bool _isLoadingMyPetsStatus = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadDiscover();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == 0) {
      _loadDiscover();
    } else if (_tabController.index == 1) {
      _loadFeed();
    } else if (_tabController.index == 2) {
      _loadMyPetsStatus();
    }
  }

  // --- DISCOVER TAB LOGIC ---
  Future<void> _loadDiscover() async {
    if (!mounted) return;
    setState(() => _isLoadingDiscover = true);
    try {
      final pets = await _social.getPublicPets(query: _searchController.text);
      if (mounted) {
        setState(() {
          _publicPets = pets;
          _isLoadingDiscover = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingDiscover = false);
    }
  }

  // --- FEED TAB LOGIC ---
  Future<void> _loadFeed() async {
    if (!mounted) return;
    setState(() => _isLoadingFeed = true);
    try {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        final feed = await _social.getFollowedFeed(auth.user!.id);
        if (mounted) {
          setState(() {
            _feedItems = feed;
            _isLoadingFeed = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingFeed = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingFeed = false);
    }
  }

  // --- MY PETS STATUS LOGIC ---
  Future<void> _loadMyPetsStatus() async {
    if (!mounted) return;
    setState(() => _isLoadingMyPetsStatus = true);
    try {
      final petProvider = context.read<PetProvider>();
      final Map<String, bool> published = {};
      final Map<String, bool> galleries = {};

      for (final pet in petProvider.pets) {
        final isPub = await _social.isPetPublished(pet.id);
        published[pet.id] = isPub;
        if (isPub) {
          final pubPet = await _social.getPublicPetById(pet.id);
          galleries[pet.id] = pubPet?.isGalleryPublic ?? false;
        } else {
          galleries[pet.id] = false;
        }
      }

      if (mounted) {
        setState(() {
          _publishedStatus = published;
          _galleryStatus = galleries;
          _isLoadingMyPetsStatus = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMyPetsStatus = false);
    }
  }

  Future<void> _togglePublish(Pet pet, bool value) async {
    final auth = context.read<AuthProvider>();
    final ownerName = auth.user?.fullName ?? 'Amigo de Nachos';
    
    if (value) {
      // Publicar mascota con galería desactivada por defecto
      await _social.publishPet(pet, false, ownerName);
    } else {
      // Despublicar
      await _social.unpublishPet(pet.id);
    }
    
    await _loadMyPetsStatus();
  }

  Future<void> _toggleGallery(Pet pet, bool value) async {
    final auth = context.read<AuthProvider>();
    final ownerName = auth.user?.fullName ?? 'Amigo de Nachos';
    
    await _social.publishPet(pet, value, ownerName);
    await _loadMyPetsStatus();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Red Social de Mascotas'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.primary,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          tabs: const [
            Tab(icon: Icon(Icons.search), text: 'Descubrir'),
            Tab(icon: Icon(Icons.rss_feed), text: 'Siguiendo'),
            Tab(icon: Icon(Icons.pets), text: 'Mis Mascotas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDiscoverTab(colorScheme),
          _buildFeedTab(colorScheme),
          _buildMyPetsTab(colorScheme),
        ],
      ),
    );
  }

  // --- BUILD TAB 1: DISCOVER ---
  Widget _buildDiscoverTab(ColorScheme colorScheme) {
    return Column(
      children: [
        // Buscador
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o raza...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _loadDiscover();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
            onChanged: (val) => _loadDiscover(),
          ),
        ),

        // Lista de resultados
        Expanded(
          child: _isLoadingDiscover
              ? const Center(child: CircularProgressIndicator())
              : _publicPets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pets_outlined, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          Text(
                            'No se encontraron mascotas públicas',
                            style: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text('¡Publica a tu mascota en la red social!'),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _publicPets.length,
                      itemBuilder: (context, index) {
                        final pet = _publicPets[index];
                        return _buildDiscoverCard(pet, colorScheme);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildDiscoverCard(PublicPet pet, ColorScheme colorScheme) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: () => context.push('/social/pets/${pet.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  pet.photoPath != null
                      ? (pet.photoPath!.startsWith('http')
                          ? Image.network(pet.photoPath!, fit: BoxFit.cover)
                          : Image.file(File(pet.photoPath!), fit: BoxFit.cover))
                      : Container(
                          color: colorScheme.secondaryContainer,
                          child: Icon(Icons.pets, size: 48, color: colorScheme.onSecondaryContainer),
                        ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${pet.followersCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pet.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        pet.gender == PetGender.male ? Icons.male : Icons.female,
                        size: 16,
                        color: pet.gender == PetGender.male ? Colors.blue : Colors.pink,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pet.breed ?? pet.typeDisplayName,
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          pet.ownerName,
                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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

  // --- BUILD TAB 2: FEED ---
  Widget _buildFeedTab(ColorScheme colorScheme) {
    if (_isLoadingFeed) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_feedItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.feed_outlined, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              const Text(
                'Tu feed está vacío',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ve a la pestaña "Descubrir" y sigue a las mascotas de tus amigos para ver sus fotos aquí.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _tabController.animateTo(0),
                icon: const Icon(Icons.search),
                label: const Text('Descubrir mascotas'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _feedItems.length,
      itemBuilder: (context, index) {
        final item = _feedItems[index];
        final PublicPetPhoto photo = item['photo'];
        final PublicPet pet = item['pet'];
        return _buildFeedCard(photo, pet, colorScheme);
      },
    );
  }

  Widget _buildFeedCard(PublicPetPhoto photo, PublicPet pet, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabecera del post
          ListTile(
            leading: CircleAvatar(
              backgroundImage: pet.photoPath != null ? NetworkImage(pet.photoPath!) : null,
              child: pet.photoPath == null ? const Icon(Icons.pets) : null,
            ),
            title: Text(
              pet.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('De ${pet.ownerName}'),
            trailing: Text(
              DateFormat('dd/MM/yyyy').format(photo.date),
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
            ),
            onTap: () => context.push('/social/pets/${pet.id}'),
          ),

          // La Foto
          AspectRatio(
            aspectRatio: 1.2,
            child: photo.photoPath.startsWith('http')
                ? Image.network(photo.photoPath, fit: BoxFit.cover)
                : Image.file(File(photo.photoPath), fit: BoxFit.cover),
          ),

          // Notas y comentarios
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (photo.notes != null && photo.notes!.isNotEmpty) ...[
                  Text(
                    photo.notes!,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    InkWell(
                      onTap: () => context.push('/social/pets/${pet.id}?openPhoto=${photo.id}'),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.comment_outlined, size: 16, color: colorScheme.secondary),
                            const SizedBox(width: 6),
                            Text(
                              'Comentar foto',
                              style: TextStyle(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- BUILD TAB 3: MY PETS ---
  Widget _buildMyPetsTab(ColorScheme colorScheme) {
    if (_isLoadingMyPetsStatus) {
      return const Center(child: CircularProgressIndicator());
    }

    final petProvider = context.watch<PetProvider>();
    final pets = petProvider.pets;

    if (pets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets_outlined, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            const Text(
              'No tienes mascotas registradas',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        final pet = pets[index];
        final isPublished = _publishedStatus[pet.id] ?? false;
        final isGalleryPublic = _galleryStatus[pet.id] ?? false;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: pet.photoPath != null ? FileImage(File(pet.photoPath!)) : null,
                      child: pet.photoPath == null ? const Icon(Icons.pets) : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pet.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            pet.breed ?? pet.typeDisplayName,
                            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                SwitchListTile(
                  title: const Text('Compartir en Red Social'),
                  subtitle: const Text('Permite que otros usuarios busquen y sigan a tu mascota.'),
                  secondary: Icon(Icons.share, color: colorScheme.primary),
                  value: isPublished,
                  onChanged: (val) => _togglePublish(pet, val),
                  contentPadding: EdgeInsets.zero,
                ),
                if (isPublished) ...[
                  SwitchListTile(
                    title: const Text('Galería Pública'),
                    subtitle: const Text('Permite que otros usuarios vean e interactúen con tus fotos.'),
                    secondary: Icon(Icons.photo_library, color: colorScheme.primary),
                    value: isGalleryPublic,
                    onChanged: (val) => _toggleGallery(pet, val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/social/pets/${pet.id}'),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Ver mi perfil público'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
