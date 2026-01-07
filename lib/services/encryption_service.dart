import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// سرویس رمزنگاری برای چت
class EncryptionService {
  static const String _keyStoragePrefix = 'chat_key_v2_';
  static int? _myUserId;
  
  // کش کلیدها در حافظه برای سرعت بیشتر
  static final Map<int, String> _keyCache = {};

  /// تنظیم userId کاربر فعلی
  static void setMyUserId(int userId) {
    _myUserId = userId;
    debugPrint('🔐 EncryptionService: userId set to $userId');
  }

  /// تولید کلید یکتا برای مکالمه (بر اساس هر دو userId)
  static String _generateChatKeyName(int recipientId) {
    if (_myUserId == null) {
      debugPrint('⚠️ Warning: _myUserId is null!');
      return '${_keyStoragePrefix}temp_$recipientId';
    }
    
    // کلید یکسان برای هر دو طرف: min_max
    final minId = _myUserId! < recipientId ? _myUserId! : recipientId;
    final maxId = _myUserId! > recipientId ? _myUserId! : recipientId;
    return '$_keyStoragePrefix${minId}_$maxId';
  }

  /// تولید کلید قطعی بر اساس دو userId (همیشه یکسان برای هر دو طرف)
  static String _generateDeterministicKey(int id1, int id2) {
    // مرتب‌سازی برای اطمینان از یکسان بودن کلید
    final minId = id1 < id2 ? id1 : id2;
    final maxId = id1 > id2 ? id1 : id2;
    
    final seed = 'bakery_chat_secure_${minId}_${maxId}_2024';
    final bytes = utf8.encode(seed);
    
    final key = List<int>.generate(32, (i) {
      return (bytes[i % bytes.length] + i * 7 + minId + maxId) % 256;
    });
    
    return base64Encode(key);
  }

  /// تولید کلید مشترک برای هر مکالمه - با کش
  static Future<String> _getOrCreateChatKey(int recipientId) async {
    if (_myUserId == null) {
      debugPrint('❌ Error: _myUserId is null, cannot create proper key');
      throw Exception('userId not set');
    }
    
    // اول از کش بخون
    if (_keyCache.containsKey(recipientId)) {
      return _keyCache[recipientId]!;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final keyName = _generateChatKeyName(recipientId);

    String? key = prefs.getString(keyName);
    if (key == null) {
      // کلید جدید بساز
      key = _generateDeterministicKey(_myUserId!, recipientId);
      await prefs.setString(keyName, key);
      debugPrint('🔐 New chat key created for conversation with $recipientId');
    }
    
    // کش کن
    _keyCache[recipientId] = key;
    return key;
  }
  
  /// گرفتن کلید از کش (sync) - برای استفاده در Isolate
  static String? getCachedKey(int recipientId) {
    return _keyCache[recipientId];
  }
  
  /// پیش‌بارگذاری کلید برای یک مکالمه
  static Future<void> preloadKey(int recipientId) async {
    if (_myUserId != null) {
      await _getOrCreateChatKey(recipientId);
    }
  }

  /// رمزنگاری پیام با XOR + Base64
  static Future<String> encryptMessage(String message, int recipientId) async {
    try {
      if (_myUserId == null) {
        debugPrint('⚠️ Encryption skipped: userId not set');
        return message;
      }
      final key = await _getOrCreateChatKey(recipientId);
      return _encryptWithKey(message, key);
    } catch (e) {
      debugPrint('❌ Encryption error: $e');
      return message; // برگردون پیام اصلی اگه خطا داد
    }
  }
  
  /// رمزنگاری sync با کلید آماده
  static String _encryptWithKey(String message, String key) {
    final keyBytes = utf8.encode(key);
    final messageBytes = utf8.encode(message);

    final encrypted = List<int>.generate(
      messageBytes.length,
      (i) => messageBytes[i] ^ keyBytes[i % keyBytes.length],
    );

    return base64Encode(encrypted);
  }

  /// رمزگشایی پیام
  static Future<String> decryptMessage(String encryptedMessage, int recipientId) async {
    try {
      if (encryptedMessage.isEmpty) return encryptedMessage;
      if (_myUserId == null) {
        debugPrint('⚠️ Decryption skipped: userId not set');
        return encryptedMessage;
      }
      final key = await _getOrCreateChatKey(recipientId);
      return _decryptWithKey(encryptedMessage, key);
    } catch (e) {
      debugPrint('❌ Decryption error: $e');
      return encryptedMessage;
    }
  }
  
  /// رمزگشایی sync با کلید آماده
  static String _decryptWithKey(String encryptedMessage, String key) {
    try {
      final keyBytes = utf8.encode(key);
      final encryptedBytes = base64Decode(encryptedMessage);

      final decrypted = List<int>.generate(
        encryptedBytes.length,
        (i) => encryptedBytes[i] ^ keyBytes[i % keyBytes.length],
      );

      return utf8.decode(decrypted);
    } catch (e) {
      return encryptedMessage;
    }
  }
  
  /// رمزگشایی لیست پیام‌ها در Isolate
  static Future<List<Map<String, dynamic>>> decryptMessagesInBackground(
    List<Map<String, dynamic>> messages,
    int recipientId,
  ) async {
    if (_myUserId == null) {
      debugPrint('⚠️ Batch decryption skipped: userId not set');
      return messages;
    }
    
    // اول کلید رو آماده کن
    final key = await _getOrCreateChatKey(recipientId);
    
    // رمزگشایی در Isolate
    return compute(_decryptMessagesIsolate, _DecryptParams(messages, key));
  }

  /// پاک کردن همه کلیدها
  static Future<void> clearAllKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('chat_key_'));
    for (final key in keys) {
      await prefs.remove(key);
    }
    _keyCache.clear();
    debugPrint('🔐 All chat keys cleared');
  }
}

/// پارامترهای رمزگشایی برای Isolate
class _DecryptParams {
  final List<Map<String, dynamic>> messages;
  final String key;
  
  _DecryptParams(this.messages, this.key);
}

/// تابع رمزگشایی در Isolate
List<Map<String, dynamic>> _decryptMessagesIsolate(_DecryptParams params) {
  for (var msg in params.messages) {
    if (msg['message'] != null && msg['isEncrypted'] == true) {
      try {
        final encryptedMessage = msg['message'] as String;
        final keyBytes = utf8.encode(params.key);
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
