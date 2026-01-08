import 'dart:convert';
import 'package:flutter/foundation.dart';

/// کلاس کمکی برای انجام پردازش‌های سنگین در background thread
class BackgroundProcessor {
  /// پارس کردن JSON در background
  static Future<dynamic> parseJson(String jsonString) async {
    if (jsonString.length < 1000) {
      // برای JSON های کوچک، همینجا پارس کن
      return jsonDecode(jsonString);
    }
    return compute(_parseJsonIsolate, jsonString);
  }

  static dynamic _parseJsonIsolate(String jsonString) {
    return jsonDecode(jsonString);
  }

  /// تبدیل لیست JSON به لیست مدل در background
  static Future<List<T>> parseList<T>(
    List<dynamic> jsonList,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    if (jsonList.length < 20) {
      // برای لیست‌های کوچک، همینجا پردازش کن
      return jsonList.map((json) => fromJson(json as Map<String, dynamic>)).toList();
    }
    
    // برای لیست‌های بزرگ، در background پردازش کن
    return compute(
      _parseListIsolate<T>,
      _ParseListParams(jsonList, fromJson),
    );
  }

  static List<T> _parseListIsolate<T>(_ParseListParams<T> params) {
    return params.jsonList
        .map((json) => params.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// فیلتر کردن لیست در background
  static Future<List<T>> filterList<T>(
    List<T> list,
    bool Function(T) test,
  ) async {
    if (list.length < 100) {
      return list.where(test).toList();
    }
    return compute(_filterListIsolate<T>, _FilterListParams(list, test));
  }

  static List<T> _filterListIsolate<T>(_FilterListParams<T> params) {
    return params.list.where(params.test).toList();
  }

  /// مرتب‌سازی لیست در background
  static Future<List<T>> sortList<T>(
    List<T> list,
    int Function(T, T) compare,
  ) async {
    if (list.length < 100) {
      return list..sort(compare);
    }
    return compute(_sortListIsolate<T>, _SortListParams(list, compare));
  }

  static List<T> _sortListIsolate<T>(_SortListParams<T> params) {
    final sorted = List<T>.from(params.list);
    sorted.sort(params.compare);
    return sorted;
  }

  /// جستجو در لیست در background
  static Future<List<T>> searchList<T>(
    List<T> list,
    String query,
    String Function(T) getText,
  ) async {
    if (list.length < 50 || query.isEmpty) {
      return list.where((item) => getText(item).contains(query)).toList();
    }
    return compute(_searchListIsolate<T>, _SearchListParams(list, query, getText));
  }

  static List<T> _searchListIsolate<T>(_SearchListParams<T> params) {
    final queryLower = params.query.toLowerCase();
    return params.list
        .where((item) => params.getText(item).toLowerCase().contains(queryLower))
        .toList();
  }

  /// encode کردن JSON در background
  static Future<String> encodeJson(dynamic data) async {
    return compute(_encodeJsonIsolate, data);
  }

  static String _encodeJsonIsolate(dynamic data) {
    return jsonEncode(data);
  }
}

/// پارامترهای parseList
class _ParseListParams<T> {
  final List<dynamic> jsonList;
  final T Function(Map<String, dynamic>) fromJson;

  _ParseListParams(this.jsonList, this.fromJson);
}

/// پارامترهای filterList
class _FilterListParams<T> {
  final List<T> list;
  final bool Function(T) test;

  _FilterListParams(this.list, this.test);
}

/// پارامترهای sortList
class _SortListParams<T> {
  final List<T> list;
  final int Function(T, T) compare;

  _SortListParams(this.list, this.compare);
}

/// پارامترهای searchList
class _SearchListParams<T> {
  final List<T> list;
  final String query;
  final String Function(T) getText;

  _SearchListParams(this.list, this.query, this.getText);
}
