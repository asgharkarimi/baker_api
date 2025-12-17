import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

class MediaCompressor {
  static Future<File?> compressImage(
    File file, {
    int quality = 70,
    int maxDimension = 1080,
  }) async {
    try {
      final originalSize = await file.length();
      debugPrint('Original image: ${_formatBytes(originalSize)}');

      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();

      final byteData = await frame.image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return file;

      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/img_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final compressedFile = File(targetPath);
      await compressedFile.writeAsBytes(byteData.buffer.asUint8List());

      final compressedSize = await compressedFile.length();
      debugPrint('Compressed: ${_formatBytes(compressedSize)}');

      return compressedFile;
    } catch (e) {
      debugPrint('Error compressing image: $e');
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


  static Future<File?> compressVideo(
    File file, {
    VideoQuality quality = VideoQuality.MediumQuality,
    void Function(double)? onProgress,
  }) async {
    try {
      final originalSize = await file.length();
      debugPrint('Original video: ${_formatBytes(originalSize)}');

      if (onProgress != null) {
        VideoCompress.compressProgress$.subscribe((progress) {
          onProgress(progress);
        });
      }

      final info = await VideoCompress.compressVideo(
        file.path,
        quality: quality,
        deleteOrigin: false,
        includeAudio: true,
      );

      if (info != null && info.file != null) {
        final compressedSize = await info.file!.length();
        debugPrint('Compressed video: ${_formatBytes(compressedSize)}');
        return info.file;
      }

      return file;
    } catch (e) {
      debugPrint('Error compressing video: $e');
      return file;
    }
  }

  static Future<File?> getVideoThumbnail(File videoFile) async {
    try {
      return await VideoCompress.getFileThumbnail(
        videoFile.path,
        quality: 70,
        position: -1,
      );
    } catch (e) {
      debugPrint('Error getting thumbnail: $e');
      return null;
    }
  }

  static Future<void> cancelVideoCompression() async {
    await VideoCompress.cancelCompression();
  }

  static Future<void> clearCache() async {
    await VideoCompress.deleteAllCache();
  }

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
