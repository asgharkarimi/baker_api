import 'package:flutter/material.dart';

class PermissionHandler {
  // نمایش پیام در صورت عدم دسترسی
  static void showPermissionDeniedDialog(BuildContext context, String permission) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('نیاز به دسترسی'),
          content: Text(
            'برای استفاده از این قابلیت، لطفاً دسترسی $permission را در تنظیمات برنامه فعال کنید.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('باشه'),
            ),
          ],
        ),
      ),
    );
  }

  // نمایش پیام راهنما
  static void showPermissionInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
