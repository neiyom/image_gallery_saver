import 'dart:typed_data';
import 'dart:io';
import 'package:gallery_saver_plus/gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';

class GalleryHelper {
  /// Save image bytes to gallery
  static Future<bool?> saveImage(Uint8List imageBytes,
      {String? name, int quality = 80}) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${name ?? DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(imageBytes, flush: true);

      return GallerySaver.saveImage(file.path, albumName: "MyApp");
    } catch (e) {
      print("Error saving image: $e");
      return false;
    }
  }

  /// Save a file (image/video) to gallery
  static Future<bool?> saveFile(String filePath, {String? albumName}) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      print("File not found: $filePath");
      return false;
    }

    final ext = file.path.split('.').last.toLowerCase();
    if (['mp4', 'mov', 'avi'].contains(ext)) {
      return GallerySaver.saveVideo(file.path, albumName: albumName ?? "MyApp");
    } else {
      return GallerySaver.saveImage(file.path, albumName: albumName ?? "MyApp");
    }
  }
}
