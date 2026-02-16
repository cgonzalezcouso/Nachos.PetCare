import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class StorageService {
  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (e) {
      return null;
    }
  }
  
  final ImagePicker _picker = ImagePicker();

  // Seleccionar imagen de la galería
  Future<File?> pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (pickedFile == null) return null;
    return File(pickedFile.path);
  }

  // Tomar foto con la cámara
  Future<File?> pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (pickedFile == null) return null;
    return File(pickedFile.path);
  }

  // Subir imagen de perfil
  Future<String> uploadProfileImage(String userId, File file) async {
    if (_supabase == null) {
      throw Exception('Supabase no está configurado');
    }
    
    final ext = path.extension(file.path);
    final filePath = 'profiles/$userId/profile$ext';
    
    await _supabase!.storage.from('avatars').upload(
      filePath,
      file,
      fileOptions: const FileOptions(upsert: true),
    );
    
    return _supabase!.storage.from('avatars').getPublicUrl(filePath);
  }

  // Subir imagen de mascota
  Future<String> uploadPetImage(String petId, File file) async {
    if (_supabase == null) {
      throw Exception('Supabase no está configurado');
    }
    
    final ext = path.extension(file.path);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = 'pets/$petId/$timestamp$ext';
    
    await _supabase!.storage.from('pets').upload(
      filePath,
      file,
      fileOptions: const FileOptions(upsert: true),
    );
    
    return _supabase!.storage.from('pets').getPublicUrl(filePath);
  }

  // Eliminar imagen
  Future<void> deleteImage(String bucket, String filePath) async {
    if (_supabase == null) return;
    
    try {
      await _supabase!.storage.from(bucket).remove([filePath]);
    } catch (e) {
      // Ignorar errores si la imagen no existe
    }
  }
}
