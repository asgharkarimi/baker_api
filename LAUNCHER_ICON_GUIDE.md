# راهنمای به‌روزرسانی آیکون برنامه

## آیکون فعلی
آیکون برنامه با موفقیت به لوگوی نانوایی (`assets/images/bakery_logo.png`) تغییر کرد.

## مشاهده تغییرات
برای مشاهده آیکون جدید:
1. برنامه را کاملاً ببندید
2. برنامه را از گوشی uninstall کنید
3. دوباره برنامه را نصب کنید: `flutter run`

## تغییر آیکون در آینده

### 1. آماده‌سازی تصویر
- سایز توصیه شده: 1024x1024 پیکسل
- فرمت: PNG با پس‌زمینه شفاف (برای بهترین نتیجه)
- تصویر را در `assets/images/` قرار دهید

### 2. به‌روزرسانی تنظیمات
فایل `pubspec.yaml` را ویرایش کنید:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/your_logo.png"
  adaptive_icon_background: "#4CAF50"  # رنگ پس‌زمینه
  adaptive_icon_foreground: "assets/images/your_logo.png"
```

### 3. اجرای دستورات
```bash
# نصب dependencies
flutter pub get

# ساخت آیکون‌ها
flutter pub run flutter_launcher_icons
# یا
dart run flutter_launcher_icons
```

### 4. تست
```bash
# حذف برنامه قبلی
flutter clean

# نصب مجدد
flutter run
```

## تنظیمات پیشرفته

### آیکون‌های Adaptive (Android)
```yaml
flutter_launcher_icons:
  android: true
  adaptive_icon_background: "#4CAF50"
  adaptive_icon_foreground: "assets/images/foreground.png"
```

### آیکون‌های مختلف برای پلتفرم‌ها
```yaml
flutter_launcher_icons:
  android: "assets/images/android_icon.png"
  ios: "assets/images/ios_icon.png"
```

### غیرفعال کردن پلتفرم خاص
```yaml
flutter_launcher_icons:
  android: true
  ios: false  # آیکون iOS تغییر نمی‌کند
```

## مشکلات رایج

### آیکون تغییر نمی‌کند
- برنامه را uninstall کنید
- `flutter clean` را اجرا کنید
- دوباره نصب کنید

### کیفیت آیکون پایین است
- از تصویر با کیفیت بالاتر استفاده کنید (1024x1024)
- از فرمت PNG استفاده کنید

### خطای permission
- مطمئن شوید فایل تصویر در مسیر صحیح است
- دسترسی‌های فایل را بررسی کنید

## منابع
- [flutter_launcher_icons package](https://pub.dev/packages/flutter_launcher_icons)
- [Android Icon Guidelines](https://developer.android.com/guide/practices/ui_guidelines/icon_design_launcher)
- [iOS Icon Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)
