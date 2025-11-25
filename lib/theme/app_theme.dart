import 'package:flutter/material.dart';

class AppTheme {
  // رنگ‌های اصلی برنامه
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFAFAFA);
  static const Color textDark = Color(0xFF212121);
  static const Color textGrey = Color(0xFF757575);
  static const Color divider = Color(0xFFE0E0E0);

  // سایزهای responsive
  static double responsiveFontSize(BuildContext context, double size) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return size;
    if (width < 900) return size * 1.2;
    return size * 1.4;
  }

  static double responsiveSpacing(BuildContext context, double size) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return size;
    if (width < 900) return size * 1.3;
    return size * 1.5;
  }

  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'Vazir',
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: white,
      colorScheme: ColorScheme.light(
        primary: primaryGreen,
        secondary: lightGreen,
        surface: white,
        error: Colors.red,
        onPrimary: white,
        onSecondary: white,
        onSurface: textDark,
      ),
      
      // تنظیمات AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: white,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Vazir',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
      ),

      // تنظیمات دکمه‌ها
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: white,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          textStyle: TextStyle(
            fontFamily: 'Vazir',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: BorderSide(color: primaryGreen, width: 2),
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontFamily: 'Vazir',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // تنظیمات فیلدهای ورودی
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red),
        ),
        labelStyle: TextStyle(
          fontFamily: 'Vazir',
          color: textGrey,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Vazir',
          color: textGrey,
        ),
      ),

      // تنظیمات کارت‌ها
      cardTheme: CardTheme(
        color: white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // تنظیمات متن
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Vazir',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Vazir',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Vazir',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Vazir',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Vazir',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Vazir',
          fontSize: 16,
          color: textDark,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Vazir',
          fontSize: 14,
          color: textDark,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Vazir',
          fontSize: 12,
          color: textGrey,
        ),
      ),
    );
  }
}
