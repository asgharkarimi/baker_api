import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppButtonsStyle {
  // دکمه اصلی سبز
  static ButtonStyle primaryButton({double? verticalPadding}) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppTheme.primaryGreen,
      foregroundColor: AppTheme.white,
      padding: EdgeInsets.symmetric(
        horizontal: 32,
        vertical: verticalPadding ?? 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // دکمه Outlined سبز
  static ButtonStyle outlinedButton({double? verticalPadding}) {
    return OutlinedButton.styleFrom(
      foregroundColor: AppTheme.primaryGreen,
      side: BorderSide(color: AppTheme.primaryGreen, width: 2),
      padding: EdgeInsets.symmetric(
        horizontal: 32,
        vertical: verticalPadding ?? 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // دکمه با آیکون - Outlined
  static ButtonStyle outlinedIconButton({double? verticalPadding}) {
    return OutlinedButton.styleFrom(
      foregroundColor: AppTheme.primaryGreen,
      side: BorderSide(color: AppTheme.primaryGreen, width: 2),
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: verticalPadding ?? 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // دکمه با آیکون - Elevated
  static ButtonStyle elevatedIconButton({double? verticalPadding}) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppTheme.primaryGreen,
      foregroundColor: AppTheme.white,
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: verticalPadding ?? 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // دکمه متنی ساده
  static ButtonStyle textButton() {
    return TextButton.styleFrom(
      foregroundColor: AppTheme.primaryGreen,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // دکمه خطر (قرمز)
  static ButtonStyle dangerButton({double? verticalPadding}) {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      foregroundColor: AppTheme.white,
      padding: EdgeInsets.symmetric(
        horizontal: 32,
        vertical: verticalPadding ?? 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // دکمه غیرفعال
  static ButtonStyle disabledButton({double? verticalPadding}) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppTheme.textGrey,
      foregroundColor: AppTheme.white,
      padding: EdgeInsets.symmetric(
        horizontal: 32,
        vertical: verticalPadding ?? 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
    );
  }

  // استایل متن برای دکمه‌های outlined
  static TextStyle outlinedButtonText() {
    return TextStyle(
      color: AppTheme.primaryGreen,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
  }

  // استایل متن برای دکمه‌های elevated
  static TextStyle elevatedButtonText() {
    return TextStyle(
      color: AppTheme.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
  }
}
