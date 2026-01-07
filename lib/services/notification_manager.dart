import 'package:flutter/material.dart';
import '../widgets/in_app_notification.dart';
import '../screens/chat/chat_screen.dart';
import 'socket_service.dart';
import 'encryption_service.dart';

/// مدیریت اعلان‌های درون برنامه‌ای
class NotificationManager {
  static GlobalKey<NavigatorState>? navigatorKey;
  static String? _currentChatRecipientId;
  static bool _initialized = false;

  /// مقداردهی اولیه
  static void init(GlobalKey<NavigatorState> key) {
    if (_initialized) return;
    _initialized = true;
    
    navigatorKey = key;
    
    // تنظیم callback برای نمایش اعلان
    SocketService.onShowNotification = _handleNewMessage;
    debugPrint('🔔 NotificationManager initialized');
  }

  /// تنظیم recipientId چت فعلی (برای جلوگیری از نمایش اعلان در همون چت)
  static void setCurrentChat(String? recipientId) {
    _currentChatRecipientId = recipientId;
    debugPrint('🔔 Current chat set to: $recipientId');
  }

  /// هندل کردن پیام جدید
  static Future<void> _handleNewMessage(Map<String, dynamic> message) async {
    debugPrint('🔔 New message received for notification');
    
    final senderId = message['senderId']?.toString();
    
    // اگه توی همون چت هستیم، اعلان نشون نده
    if (senderId == _currentChatRecipientId) {
      debugPrint('🔔 Skipping notification - same chat');
      return;
    }

    // رمزگشایی پیام
    String messageText = message['message'] ?? '';
    if (message['isEncrypted'] == true && senderId != null) {
      try {
        messageText = await EncryptionService.decryptMessage(
          messageText,
          int.parse(senderId),
        );
      } catch (e) {
        messageText = 'پیام جدید';
      }
    }

    final senderName = message['senderName'] ?? 'کاربر';
    final senderAvatar = message['senderAvatar'];
    
    debugPrint('🔔 Showing notification from: $senderName');

    // نمایش اعلان
    _showNotification(
      senderId: senderId ?? '0',
      senderName: senderName,
      senderAvatar: senderAvatar,
      message: messageText,
    );
  }
  
  /// نمایش نوتیفیکیشن
  static void _showNotification({
    required String senderId,
    required String senderName,
    required String message,
    String? senderAvatar,
  }) {
    final context = navigatorKey?.currentContext;
    if (context == null) {
      debugPrint('🔔 No context available for notification');
      return;
    }
    
    try {
      InAppNotification.showMessageNotification(
        context: context,
        senderName: senderName,
        message: message,
        senderAvatar: senderAvatar,
        onTap: () {
          _goToChat(senderId, senderName, senderAvatar);
        },
      );
      debugPrint('🔔 Notification shown successfully');
    } catch (e) {
      debugPrint('🔔 Error showing notification: $e');
    }
  }
  
  /// رفتن به صفحه چت
  static void _goToChat(String recipientId, String recipientName, String? recipientAvatar) {
    final context = navigatorKey?.currentContext;
    if (context == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          recipientId: recipientId,
          recipientName: recipientName,
          recipientAvatar: recipientAvatar ?? recipientName[0],
        ),
      ),
    );
  }
}
