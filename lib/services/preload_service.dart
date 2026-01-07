import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'encryption_service.dart';
import 'socket_service.dart';

/// سرویس پیش‌بارگذاری داده‌ها در پس‌زمینه
class PreloadService {
  static bool _isPreloading = false;
  static bool _isPreloaded = false;

  /// آیا داده‌ها پیش‌بارگذاری شدن؟
  static bool get isPreloaded => _isPreloaded;

  /// پیش‌بارگذاری همه داده‌های اصلی به صورت موازی
  static Future<void> preloadAll() async {
    if (_isPreloading || _isPreloaded) return;
    _isPreloading = true;

    debugPrint('🚀 شروع پیش‌بارگذاری داده‌ها...');
    final stopwatch = Stopwatch()..start();

    try {
      // اول اطلاعات کاربر رو بگیر (برای رمزنگاری و سوکت)
      await _preloadUserData();
      
      // بعد بقیه داده‌ها رو موازی بگیر
      await Future.wait([
        _preloadJobAds(),
        _preloadJobSeekers(),
        _preloadBakeries(),
        _preloadEquipment(),
      ]);

      _isPreloaded = true;
      debugPrint('✅ پیش‌بارگذاری کامل شد در ${stopwatch.elapsedMilliseconds}ms');
    } catch (e) {
      debugPrint('⚠️ خطا در پیش‌بارگذاری: $e');
    } finally {
      _isPreloading = false;
      stopwatch.stop();
    }
  }

  /// پیش‌بارگذاری آگهی‌های شغلی
  static Future<void> _preloadJobAds() async {
    try {
      final ads = await ApiService.getJobAds(page: 1, useCache: true);
      debugPrint('📦 ${ads.length} آگهی شغلی بارگذاری شد');
    } catch (e) {
      debugPrint('❌ خطا در بارگذاری آگهی‌های شغلی: $e');
    }
  }

  /// پیش‌بارگذاری کارجویان
  static Future<void> _preloadJobSeekers() async {
    try {
      final seekers = await ApiService.getJobSeekers(page: 1, useCache: true);
      debugPrint('📦 ${seekers.length} کارجو بارگذاری شد');
    } catch (e) {
      debugPrint('❌ خطا در بارگذاری کارجویان: $e');
    }
  }

  /// پیش‌بارگذاری نانوایی‌ها
  static Future<void> _preloadBakeries() async {
    try {
      final bakeries = await ApiService.getBakeryAds(page: 1, useCache: true);
      debugPrint('📦 ${bakeries.length} نانوایی بارگذاری شد');
    } catch (e) {
      debugPrint('❌ خطا در بارگذاری نانوایی‌ها: $e');
    }
  }

  /// پیش‌بارگذاری تجهیزات
  static Future<void> _preloadEquipment() async {
    try {
      final equipment = await ApiService.getEquipmentAds(page: 1, useCache: true);
      debugPrint('📦 ${equipment.length} تجهیزات بارگذاری شد');
    } catch (e) {
      debugPrint('❌ خطا در بارگذاری تجهیزات: $e');
    }
  }

  /// پیش‌بارگذاری اطلاعات کاربر و اتصال سوکت
  static Future<void> _preloadUserData() async {
    try {
      final isLoggedIn = await ApiService.isLoggedIn();
      if (isLoggedIn) {
        // گرفتن userId
        final userId = await ApiService.getCurrentUserId();
        
        if (userId != null) {
          // تنظیم برای رمزنگاری
          EncryptionService.setMyUserId(userId);
          
          // اتصال سوکت برای دریافت پیام‌های realtime
          SocketService.connect(userId);
          
          debugPrint('📦 کاربر $userId آماده شد (رمزنگاری + سوکت)');
        }
        
        // گرفتن اطلاعات کاربر
        await ApiService.getCurrentUser();
        debugPrint('📦 اطلاعات کاربر بارگذاری شد');
      }
    } catch (e) {
      debugPrint('❌ خطا در بارگذاری اطلاعات کاربر: $e');
    }
  }

  /// ریست کردن وضعیت (برای تست)
  static void reset() {
    _isPreloaded = false;
    _isPreloading = false;
  }
}
