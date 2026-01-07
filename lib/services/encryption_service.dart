import 'dart:convert';
import 'package:flutter/foundation.dart';

/// سرویس رمزنگاری ساده و قابل اعتماد برای چت
/// کلید بر اساس دو userId ساخته میشه و برای هر دو طرف یکسانه
class EncryptionService {
  static int? _myUserId;

  /// تنظیم userId کاربر فعلی - باید قبل از استفاده فراخوانی بشه
  static void setMyUserId(int userId) {
    _myUserId = userId;
    debugPrint('🔐 EncryptionService: myUserId = $userId');
  }

  /// گرفتن userId فعلی
  static int? get myUserId => _myUserId;

  /// تولید کلید یکتا برای مکالمه
  /// کلید همیشه یکسانه چون بر اساس min_max ساخته میشه
  static String _generateKey(int recipientId) {
    if (_myUserId == null) {
      throw Exception('userId not set! Call setMyUserId first.');
    }
    
    final id1 = _myUserId!;
    final id2 = recipientId;
    
    // همیشه به ترتیب min_max تا هر دو طرف کلید یکسان داشته باشن
    final minId = id1 < id2 ? id1 : id2;
    final maxId = id1 > id2 ? id1 : id2;
    
    // کلید ثابت و قابل پیش‌بینی
    final seed = 'bakery_secure_chat_${minId}_${maxId}_key_2024';
    debugPrint('🔐 Key generated: myId=$id1, recipientId=$id2, minId=$minId, maxId=$maxId');
    return seed;
  }

  /// رمزنگاری پیام
  static Future<String> encryptMessage(String message, int recipientId) async {
    try {
      final key = _generateKey(recipientId);
      final keyBytes = utf8.encode(key);
      final messageBytes = utf8.encode(message);

      final encrypted = List<int>.generate(
        messageBytes.length,
        (i) => messageBytes[i] ^ keyBytes[i % keyBytes.length],
      );

      return base64Encode(encrypted);
    } catch (e) {
      debugPrint('❌ Encryption error: $e');
      return message; // اگه خطا داد، پیام اصلی رو برگردون
    }
  }

  /// رمزگشایی پیام
  static Future<String> decryptMessage(String encryptedMessage, int recipientId) async {
    try {
      if (encryptedMessage.isEmpty) return encryptedMessage;
      
      final key = _generateKey(recipientId);
      final keyBytes = utf8.encode(key);
      final encryptedBytes = base64Decode(encryptedMessage);

      final decrypted = List<int>.generate(
        encryptedBytes.length,
        (i) => encryptedBytes[i] ^ keyBytes[i % keyBytes.length],
      );

      return utf8.decode(decrypted);
    } catch (e) {
      debugPrint('❌ Decryption error: $e');
      return encryptedMessage; // اگه خطا داد، همون متن رو برگردون
    }
  }

  /// رمزگشایی لیست پیام‌ها (برای performance بهتر)
  static Future<List<Map<String, dynamic>>> decryptMessagesInBackground(
    List<Map<String, dynamic>> messages,
    int recipientId,
  ) async {
    if (_myUserId == null) {
      debugPrint('⚠️ Cannot decrypt: userId not set');
      return messages;
    }

    final key = _generateKey(recipientId);
    
    // رمزگشایی در Isolate برای جلوگیری از بلاک شدن UI
    return compute(_decryptMessages, _DecryptParams(messages, key));
  }
}

/// پارامترهای رمزگشایی
class _DecryptParams {
  final List<Map<String, dynamic>> messages;
  final String key;
  _DecryptParams(this.messages, this.key);
}

/// تابع رمزگشایی در Isolate
List<Map<String, dynamic>> _decryptMessages(_DecryptParams params) {
  final keyBytes = utf8.encode(params.key);
  
  for (var msg in params.messages) {
    if (msg['message'] != null && msg['isEncrypted'] == true) {
      try {
        final encryptedMessage = msg['message'] as String;
        final encryptedBytes = base64Decode(encryptedMessage);

        final decrypted = List<int>.generate(
          encryptedBytes.length,
          (i) => encryptedBytes[i] ^ keyBytes[i % keyBytes.length],
        );

        msg['message'] = utf8.decode(decrypted);
      } catch (e) {
        // اگه رمزگشایی نشد، همون متن رو نگه دار
      }
    }
  }
  return params.messages;
}
