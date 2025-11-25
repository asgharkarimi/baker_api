class TimeAgo {
  static String format(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'همین الان';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes دقیقه پیش';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ساعت پیش';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days روز پیش';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks هفته پیش';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ماه پیش';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years سال پیش';
    }
  }

  static String formatShort(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'الان';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}د';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}س';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}ر';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}ه';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}م';
    } else {
      return '${(difference.inDays / 365).floor()}س';
    }
  }
}
