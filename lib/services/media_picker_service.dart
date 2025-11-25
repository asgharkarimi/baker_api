import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MediaPickerService {
  static final ImagePicker _picker = ImagePicker();

  // انتخاب تک عکس
  static Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
    int? maxWidth,
    int? maxHeight,
    int? imageQuality = 85,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth?.toDouble(),
        maxHeight: maxHeight?.toDouble(),
        imageQuality: imageQuality,
      );
      
      if (image != null) {
        print('Image picked: ${image.path}');
        return File(image.path);
      }
      print('No image selected');
      return null;
    } catch (e) {
      print('Error picking image: $e');
      // بررسی نوع خطا
      if (e.toString().contains('photo_access_denied') || 
          e.toString().contains('camera_access_denied')) {
        print('Permission denied');
      }
      return null;
    }
  }

  // انتخاب چند عکس
  static Future<List<File>> pickMultipleImages({
    int? maxWidth,
    int? maxHeight,
    int? imageQuality = 85,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: maxWidth?.toDouble(),
        maxHeight: maxHeight?.toDouble(),
        imageQuality: imageQuality,
      );
      
      print('${images.length} images picked');
      return images.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      print('Error picking multiple images: $e');
      if (e.toString().contains('photo_access_denied')) {
        print('Gallery permission denied');
      }
      return [];
    }
  }

  // انتخاب ویدیو
  static Future<File?> pickVideo({
    ImageSource source = ImageSource.gallery,
    Duration? maxDuration,
  }) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: source,
        maxDuration: maxDuration,
      );
      
      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      print('Error picking video: $e');
      return null;
    }
  }

  // نمایش دیالوگ انتخاب منبع (دوربین یا گالری)
  static Future<ImageSource?> showSourceDialog() async {
    // این متد باید در ویجت استفاده بشه
    return null;
  }

  // بررسی سایز فایل
  static Future<int> getFileSize(File file) async {
    return await file.length();
  }

  // تبدیل سایز به فرمت خوانا
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // بررسی نوع فایل
  static bool isImage(String path) {
    final ext = path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  static bool isVideo(String path) {
    final ext = path.toLowerCase().split('.').last;
    return ['mp4', 'mov', 'avi', 'mkv', 'flv', 'wmv'].contains(ext);
  }
}
