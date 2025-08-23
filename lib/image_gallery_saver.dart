import 'dart:typed_data';
import 'dart:io';
import 'package:gallery_saver_plus/gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';

class GalleryHelper {
  /// Request storage / media permissions (Android 10–13+ safe)
  static Future<bool> _checkPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.photos.isGranted ||
          await Permission.storage.isGranted ||
          await Permission.mediaLibrary.isGranted) {
        return true;
      }
      final status = await [
        Permission.photos,
        Permission.storage,
        Permission.mediaLibrary,
      ].request();

      return status.values.any((s) => s.isGranted);
    }
    return true; // iOS handles it internally
  }

  /// Save image bytes to gallery
  static Future<bool> saveImage(
    Uint8List imageBytes, {
    String? name,
    int quality = 80,
    String albumName = "MyApp",
  }) async {
    try {
      if (!await _checkPermissions()) {
        print("❌ Permission denied");
        return false;
      }

      // Compress if needed
      final compressedBytes = await FlutterImageCompress.compressWithList(
        imageBytes,
        quality: quality,
      );

      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/${name ?? DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(compressedBytes, flush: true);

      final result = await GallerySaver.saveImage(file.path, albumName: albumName);
      return result ?? false;
    } catch (e) {
      print("❌ Error saving image: $e");
      return false;
    }
  }

  /// Save file (image/video) to gallery
  static Future<bool> saveFile(
    String filePath, {
    String albumName = "MyApp",
  }) async {
    try {
      if (!await _checkPermissions()) {
        print("❌ Permission denied");
        return false;
      }

      final file = File(filePath);
      if (!file.existsSync()) {
        print("❌ File not found: $filePath");
        return false;
      }

      final ext = file.path.split('.').last.toLowerCase();
      final result = (['mp4', 'mov', 'avi'].contains(ext))
          ? await GallerySaver.saveVideo(file.path, albumName: albumName)
          : await GallerySaver.saveImage(file.path, albumName: albumName);

      return result ?? false;
    } catch (e) {
      print("❌ Error saving file: $e");
      return false;
    }
  }
}
