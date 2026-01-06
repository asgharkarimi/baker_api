import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class MediaCompressor {
  // فشرده‌سازی سبک با flutter_image_compress
  static Future<File?> compressImage(
    File file, {
    int quality = 70,
    int maxDimension = 1080,
  }) async {
    try {
      final originalSize = await file.length();
      
      // اگه کمتر از 500KB بود، فشرده نکن
      if (originalSize < 500 * 1024) {
        debugPrint('📷 Image small enough, skipping compression');
        return file;
      }
      
      debugPrint('📷 Compressing image: ${_formatBytes(originalSize)}');

      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/img_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxDimension,
        minHeight: maxDimension,
      );

      if (result != null) {
        final compressedSize = await result.length();
        debugPrint('📷 Compressed: ${_formatBytes(compressedSize)}');
        return File(result.path);
      }
      
      return file;
    } catch (e) {
      debugPrint('⚠️ Compression failed: $e');
      return file;
    }
  }

  static Future<List<File>> compressImages(List<File> files) async {
    final compressed = <File>[];
    for (final file in files) {
      final result = await compressImage(file);
      if (result != null) compressed.add(result);
    }
    return compressed;
  }

  // ویدیو فشرده نمیشه - سنگینه
  static Future<File?> compressVideo(
    File file, {
    dynamic quality,
    void Function(double)? onProgress,
  }) async {
    return file;
  }

  static Future<File?> getVideoThumbnail(File videoFile) async {
    return null;
  }

  static Future<void> cancelVideoCompression() async {}

  static Future<void> clearCache() async {}

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static bool needsCompression(File file, {int maxSizeKB = 500}) {
    return file.lengthSync() / 1024 > maxSizeKB;
  }

  static String getFileSize(File file) {
    return _formatBytes(file.lengthSync());
  }
}
