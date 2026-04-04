import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

/// Selecciona una imagen de forma multiplataforma:
/// - Windows/Linux/macOS → explorador de archivos nativo (file_picker)
/// - Android/iOS         → image_picker (cámara o galería)
///
/// Devuelve la ruta absoluta del archivo seleccionado, o null si el usuario
/// canceló o se produjo un error.
class ImagePickerHelper {
  /// En escritorio abre el explorador de archivos.
  /// En móvil abre el selector de galería.
  static Future<String?> pickFromGallery() async {
    if (_isDesktop) {
      return _pickWithFilePicker();
    }
    return _pickWithImagePicker(ImageSource.gallery);
  }

  /// En escritorio abre el explorador de archivos (cámara no disponible).
  /// En móvil abre la cámara.
  static Future<String?> pickFromCamera() async {
    if (_isDesktop) {
      // La cámara no está soportada en escritorio → usar el explorador
      return _pickWithFilePicker();
    }
    return _pickWithImagePicker(ImageSource.camera);
  }

  /// True si la app corre en una plataforma de escritorio.
  static bool get isDesktop => _isDesktop;
  static bool get _isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  // ── Implementaciones privadas ───────────────────────────────────────────────

  static Future<String?> _pickWithFilePicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    return result?.files.single.path;
  }

  static Future<String?> _pickWithImagePicker(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    return picked?.path;
  }
}
