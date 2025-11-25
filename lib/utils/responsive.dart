import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;
  
  Responsive(this.context);

  // دریافت عرض صفحه
  double get width => MediaQuery.of(context).size.width;
  
  // دریافت ارتفاع صفحه
  double get height => MediaQuery.of(context).size.height;
  
  // تشخیص نوع دستگاه
  bool get isMobile => width < 600;
  bool get isTablet => width >= 600 && width < 900;
  bool get isDesktop => width >= 900;
  
  // سایز فونت responsive
  double fontSize(double size) {
    if (isMobile) return size;
    if (isTablet) return size * 1.2;
    return size * 1.4;
  }
  
  // فاصله‌گذاری responsive
  double spacing(double size) {
    if (isMobile) return size;
    if (isTablet) return size * 1.3;
    return size * 1.5;
  }
  
  // padding responsive
  EdgeInsets padding({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    final multiplier = isMobile ? 1.0 : (isTablet ? 1.3 : 1.5);
    
    if (all != null) {
      return EdgeInsets.all(all * multiplier);
    }
    
    return EdgeInsets.only(
      top: (top ?? vertical ?? 0) * multiplier,
      bottom: (bottom ?? vertical ?? 0) * multiplier,
      left: (left ?? horizontal ?? 0) * multiplier,
      right: (right ?? horizontal ?? 0) * multiplier,
    );
  }
  
  // ارتفاع دکمه
  double get buttonHeight {
    if (isMobile) return 56;
    if (isTablet) return 64;
    return 72;
  }
  
  // شعاع گوشه
  double borderRadius(double radius) {
    if (isMobile) return radius;
    if (isTablet) return radius * 1.2;
    return radius * 1.4;
  }
  
  // سایز آیکون
  double iconSize(double size) {
    if (isMobile) return size;
    if (isTablet) return size * 1.3;
    return size * 1.5;
  }
  
  // عرض محتوا (برای دسکتاپ محدود می‌کنیم)
  double get contentWidth {
    if (isDesktop) return 1200;
    if (isTablet) return width * 0.9;
    return width;
  }
  
  // تعداد ستون‌ها در Grid
  int get gridColumns {
    if (isMobile) return 1;
    if (isTablet) return 2;
    return 3;
  }
  
  // فاصله بین آیتم‌های Grid
  double get gridSpacing {
    if (isMobile) return 12;
    if (isTablet) return 16;
    return 20;
  }
}

// Extension برای دسترسی آسان
extension ResponsiveExtension on BuildContext {
  Responsive get responsive => Responsive(this);
  
  // میانبرها
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 900;
  bool get isDesktop => screenWidth >= 900;
}

// کلاس کمکی برای سایزهای ثابت responsive
class ResponsiveSizes {
  static double fontSize(BuildContext context, double size) {
    return Responsive(context).fontSize(size);
  }
  
  static double spacing(BuildContext context, double size) {
    return Responsive(context).spacing(size);
  }
  
  static double iconSize(BuildContext context, double size) {
    return Responsive(context).iconSize(size);
  }
  
  static double borderRadius(BuildContext context, double radius) {
    return Responsive(context).borderRadius(radius);
  }
}
