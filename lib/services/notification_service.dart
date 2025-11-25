import 'package:flutter/material.dart';
import '../models/job_ad.dart';
import '../models/bakery_ad.dart';

class NotificationService {
  static final List<AppNotification> _notifications = [];
  static final List<Function(AppNotification)> _listeners = [];

  // دریافت تمام نوتیفیکیشن‌ها
  static List<AppNotification> getAll() {
    return List.from(_notifications);
  }

  // دریافت نوتیفیکیشن‌های خوانده نشده
  static List<AppNotification> getUnread() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  // تعداد نوتیفیکیشن‌های خوانده نشده
  static int getUnreadCount() {
    return _notifications.where((n) => !n.isRead).length;
  }

  // اضافه کردن نوتیفیکیشن جدید
  static void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    _notifyListeners(notification);
  }

  // علامت‌گذاری به عنوان خوانده شده
  static void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  // علامت‌گذاری همه به عنوان خوانده شده
  static void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  // حذف نوتیفیکیشن
  static void remove(String id) {
    _notifications.removeWhere((n) => n.id == id);
  }

  // پاک کردن همه
  static void clearAll() {
    _notifications.clear();
  }

  // ثبت listener
  static void addListener(Function(AppNotification) listener) {
    _listeners.add(listener);
  }

  // حذف listener
  static void removeListener(Function(AppNotification) listener) {
    _listeners.remove(listener);
  }

  // اطلاع‌رسانی به listeners
  static void _notifyListeners(AppNotification notification) {
    for (var listener in _listeners) {
      listener(notification);
    }
  }

  // ایجاد نوتیفیکیشن برای آگهی شغلی جدید
  static void notifyNewJobAd(JobAd ad) {
    addNotification(AppNotification(
      id: 'job_${ad.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'آگهی شغلی جدید',
      body: ad.title,
      type: NotificationType.newJobAd,
      data: {'jobAdId': ad.id},
      createdAt: DateTime.now(),
    ));
  }

  // ایجاد نوتیفیکیشن برای آگهی نانوایی جدید
  static void notifyNewBakeryAd(BakeryAd ad) {
    addNotification(AppNotification(
      id: 'bakery_${ad.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'آگهی نانوایی جدید',
      body: ad.title,
      type: NotificationType.newBakeryAd,
      data: {'bakeryAdId': ad.id},
      createdAt: DateTime.now(),
    ));
  }

  // ایجاد نوتیفیکیشن سفارشی
  static void notifyCustom({
    required String title,
    required String body,
    NotificationType type = NotificationType.general,
    Map<String, dynamic>? data,
  }) {
    addNotification(AppNotification(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      type: type,
      data: data,
      createdAt: DateTime.now(),
    ));
  }

  // شبیه‌سازی دریافت نوتیفیکیشن‌های نمونه
  static void loadSampleNotifications() {
    addNotification(AppNotification(
      id: '1',
      title: 'آگهی شغلی جدید',
      body: 'نیازمند شاطر بربری در تهران',
      type: NotificationType.newJobAd,
      data: {'jobAdId': '1'},
      createdAt: DateTime.now().subtract(Duration(minutes: 5)),
    ));

    addNotification(AppNotification(
      id: '2',
      title: 'آگهی نانوایی جدید',
      body: 'فروش نانوایی بربری در اصفهان',
      type: NotificationType.newBakeryAd,
      data: {'bakeryAdId': '1'},
      createdAt: DateTime.now().subtract(Duration(hours: 1)),
      isRead: true,
    ));

    addNotification(AppNotification(
      id: '3',
      title: 'پیام جدید',
      body: 'شما یک پیام جدید دارید',
      type: NotificationType.newMessage,
      createdAt: DateTime.now().subtract(Duration(hours: 2)),
    ));
  }
}

// مدل نوتیفیکیشن
class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    required this.createdAt,
    this.isRead = false,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  IconData get icon {
    switch (type) {
      case NotificationType.newJobAd:
        return Icons.work;
      case NotificationType.newBakeryAd:
        return Icons.store;
      case NotificationType.newMessage:
        return Icons.message;
      case NotificationType.newReview:
        return Icons.star;
      case NotificationType.general:
        return Icons.notifications;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.newJobAd:
        return Colors.blue;
      case NotificationType.newBakeryAd:
        return Colors.orange;
      case NotificationType.newMessage:
        return Colors.green;
      case NotificationType.newReview:
        return Colors.amber;
      case NotificationType.general:
        return Colors.grey;
    }
  }
}

enum NotificationType {
  newJobAd,
  newBakeryAd,
  newMessage,
  newReview,
  general,
}
