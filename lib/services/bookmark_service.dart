import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const String _bookmarksKey = 'bookmarks';

  // ذخیره نشانک
  static Future<void> addBookmark(String id, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList(_bookmarksKey) ?? [];
    final bookmarkId = '$type:$id';
    
    if (!bookmarks.contains(bookmarkId)) {
      bookmarks.add(bookmarkId);
      await prefs.setStringList(_bookmarksKey, bookmarks);
    }
  }

  // حذف نشانک
  static Future<void> removeBookmark(String id, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList(_bookmarksKey) ?? [];
    final bookmarkId = '$type:$id';
    
    bookmarks.remove(bookmarkId);
    await prefs.setStringList(_bookmarksKey, bookmarks);
  }

  // چک کردن نشانک
  static Future<bool> isBookmarked(String id, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList(_bookmarksKey) ?? [];
    final bookmarkId = '$type:$id';
    
    return bookmarks.contains(bookmarkId);
  }

  // گرفتن همه نشانک‌ها
  static Future<List<String>> getAllBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_bookmarksKey) ?? [];
  }

  // گرفتن نشانک‌های یک نوع خاص
  static Future<List<String>> getBookmarksByType(String type) async {
    final bookmarks = await getAllBookmarks();
    return bookmarks
        .where((bookmark) => bookmark.startsWith('$type:'))
        .map((bookmark) => bookmark.replaceFirst('$type:', ''))
        .toList();
  }
}
