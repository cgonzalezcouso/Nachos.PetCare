import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:nachos_pet_care_flutter/services/service_locator.dart';
import 'package:nachos_pet_care_flutter/services/database_service.dart';
import 'package:nachos_pet_care_flutter/models/pet_photo.dart';
import 'package:nachos_pet_care_flutter/utils/image_picker_helper.dart';
import 'package:nachos_pet_care_flutter/l10n/app_strings.dart';
import 'package:provider/provider.dart';
import 'package:nachos_pet_care_flutter/providers/subscription_provider.dart';

class PetGalleryScreen extends StatefulWidget {
  final String petId;
  final String petName;

  const PetGalleryScreen({
    super.key,
    required this.petId,
    required this.petName,
  });

  @override
  State<PetGalleryScreen> createState() => _PetGalleryScreenState();
}

class _PetGalleryScreenState extends State<PetGalleryScreen> {
  final DatabaseService _db = getIt<DatabaseService>();
  List<PetPhoto> _photos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final photos = await _db.getPetPhotos(widget.petId);
      setState(() {
        _photos = photos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showPickerOptions() async {
    final subProvider = context.read<SubscriptionProvider>();
    final canAdd = await subProvider.canAddEvent(widget.petId);
    if (!canAdd) {
      if (mounted) context.push('/premium-paywall');
      return;
    }

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería de imágenes'),
                onTap: () async {
                  Navigator.pop(context);
                  final path = await ImagePickerHelper.pickFromGallery();
                  if (path != null) {
                    _addPhoto(path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () async {
                  Navigator.pop(context);
                  final path = await ImagePickerHelper.pickFromCamera();
                  if (path != null) {
                    _addPhoto(path);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addPhoto(String path) async {
    DateTime selectedDate = DateTime.now();
    final notesController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final strings = AppStrings.of(context);
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(strings.addPhoto),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(path),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      leading: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                      title: Text(strings.selectPhotoDate),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy').format(selectedDate),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setStateDialog(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: notesController,
                      decoration: InputDecoration(
                        labelText: strings.photoNotes,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        prefixIcon: const Icon(Icons.notes),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(strings.cancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(strings.save),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirm == true) {
      final id = const Uuid().v4();
      final photo = PetPhoto(
        id: id,
        petId: widget.petId,
        photoPath: path,
        date: selectedDate,
        notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
        createdAt: DateTime.now(),
      );

      await _db.insertPetPhoto(photo);
      _loadPhotos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.of(context).photoAddedSuccessfully),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deletePhoto(PetPhoto photo) async {
    final strings = AppStrings.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.deletePhotoConfirm),
        content: Text(strings.deletePhotoConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _db.deletePetPhoto(photo.id);
      try {
        final file = File(photo.photoPath);
        if (await file.exists()) {
          // Omitir eliminación si es foto de perfil o compartida, pero para fotos
          // de galería locales tomadas por la app sí se podría borrar el archivo
          // para no consumir almacenamiento de forma innecesaria.
        }
      } catch (_) {}
      _loadPhotos();
    }
  }

  void _openFullScreen(String photoPath) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) => _FullScreenImageViewer(photoPath: photoPath),
      ),
    );
  }

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    return FileImage(File(path));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${strings.gallery} - ${widget.petName}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/pets/${widget.petId}');
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showPickerOptions,
        tooltip: strings.addPhoto,
        child: const Icon(Icons.add_a_photo_outlined),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _photos.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_album_outlined,
                          size: 72,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${strings.emptyGallery} ${widget.petName}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          strings.emptyGallerySubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _photos.length,
                  itemBuilder: (context, index) {
                    final photo = _photos[index];
                    final formattedDate = DateFormat('dd/MM/yyyy').format(photo.date);

                    return Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () => _openFullScreen(photo.photoPath),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Image(
                                    image: _getImageProvider(photo.photoPath),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: colorScheme.errorContainer,
                                      child: Icon(Icons.broken_image, color: colorScheme.error),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  color: colorScheme.surface,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today, size: 12, color: colorScheme.primary),
                                          const SizedBox(width: 4),
                                          Text(
                                            formattedDate,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (photo.notes != null && photo.notes!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          photo.notes!,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(6),
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.white),
                                  onPressed: () => _deletePhoto(photo),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _FullScreenImageViewer extends StatelessWidget {
  final String photoPath;
  const _FullScreenImageViewer({required this.photoPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: photoPath.startsWith('http')
                  ? Image.network(
                      photoPath,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        color: Colors.white54,
                        size: 80,
                      ),
                    )
                  : Image.file(
                      File(photoPath),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        color: Colors.white54,
                        size: 80,
                      ),
                    ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: SafeArea(
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
