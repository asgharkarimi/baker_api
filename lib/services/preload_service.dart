import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'encryption_service.dart';
import 'socket_service.dart';

/// سرویس آماده‌سازی اولیه برنامه
class PreloadService {
  static bool _isPreloading = false;
  static bool _isPreloaded = false;

  /// آیا آماده‌سازی انجام شده؟
  static bool get isPreloaded => _isPreloaded;

  /// فقط اطلاعات کاربر و سوکت - آگهی‌ها موقع نیاز لود میشن
  static Future<void> preloadUserOnly() async {
    if (_isPreloading) return;
    _isPreloading = true;

    debugPrint('🚀 آماده‌سازی کاربر...');
    final stopwatch = Stopwatch()..start();

    try {
      await _preloadUserData();
      _isPreloaded = true;
      debugPrint('✅ آماده‌سازی کامل شد در ${stopwatch.elapsedMilliseconds}ms');
    } catch (e) {
      debugPrint('⚠️ خطا در آماده‌سازی: $e');
    } finally {
      _isPreloading = false;
      stopwatch.stop();
    }
  }

  /// برای سازگاری با کدهای قبلی
  static Future<void> preloadAll() async {
    await preloadUserOnly();
  }

  /// آماده‌سازی اطلاعات کاربر و اتصال سوکت
  static Future<void> _preloadUserData() async {
    try {
      final stopwatch = Stopwatch()..start();
      
      final isLoggedIn = await ApiService.isLoggedIn();
      debugPrint('⏱️ چک لاگین: ${stopwatch.elapsedMilliseconds}ms');
      
      if (isLoggedIn) {
        // گرفتن userId
        final userId = await ApiService.getCurrentUserId();
        debugPrint('⏱️ گرفتن userId: ${stopwatch.elapsedMilliseconds}ms');
        
        if (userId != null) {
          // تنظیم برای رمزنگاری
          EncryptionService.setMyUserId(userId);
          
          // اتصال سوکت برای دریافت پیام‌های realtime
          SocketService.connect(userId);
          
          debugPrint('📦 کاربر $userId آماده شد');
        }
        
        // گرفتن اطلاعات کاربر - این میتونه کند باشه
        ApiService.getCurrentUser(); // بدون await - در background
        debugPrint('⏱️ کل آماده‌سازی: ${stopwatch.elapsedMilliseconds}ms');
      }
      
      stopwatch.stop();
    } catch (e) {
      debugPrint('❌ خطا در آماده‌سازی کاربر: $e');
    }
  }

  /// ریست کردن وضعیت
  static void reset() {
    _isPreloaded = false;
    _isPreloading = false;
  }
}
