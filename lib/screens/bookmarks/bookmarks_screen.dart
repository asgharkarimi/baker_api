import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/bookmark_service.dart';
import '../job_ads/job_ad_detail_screen.dart';
import '../bakery/bakery_detail_screen.dart';
import '../../models/job_ad.dart';
import '../../models/bakery_ad.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<String> _bookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final bookmarks = await BookmarkService.getAllBookmarks();
    setState(() {
      _bookmarks = bookmarks;
      _isLoading = false;
    });
  }

  String _getTypeLabel(String bookmark) {
    if (bookmark.startsWith('job_ad:')) return 'آگهی شغلی';
    if (bookmark.startsWith('job_seeker:')) return 'جوینده کار';
    if (bookmark.startsWith('equipment:')) return 'دستگاه';
    if (bookmark.startsWith('bakery:')) return 'نانوایی';
    return 'نامشخص';
  }

  String _getBookmarkTitle(String bookmark) {
    final parts = bookmark.split(':');
    final id = parts[1];
    
    // در واقعیت باید عنوان واقعی رو از دیتابیس بگیری
    // الان فقط نمونه است
    if (bookmark.startsWith('job_ad:')) {
      return 'نیازمند شاطر بربری';
    } else if (bookmark.startsWith('bakery:')) {
      return 'فروش نانوایی بربری';
    } else if (bookmark.startsWith('equipment:')) {
      return 'دستگاه ربات نانوایی';
    } else if (bookmark.startsWith('job_seeker:')) {
      return 'شاطر با تجربه';
    }
    return 'آگهی شماره $id';
  }

  IconData _getTypeIcon(String bookmark) {
    if (bookmark.startsWith('job_ad:')) return Icons.work;
    if (bookmark.startsWith('job_seeker:')) return Icons.person_search;
    if (bookmark.startsWith('equipment:')) return Icons.settings;
    if (bookmark.startsWith('bakery:')) return Icons.store;
    return Icons.bookmark;
  }

  Color _getTypeColor(String bookmark) {
    if (bookmark.startsWith('job_ad:')) return AppTheme.primaryGreen;
    if (bookmark.startsWith('job_seeker:')) return AppTheme.primaryGreen;
    if (bookmark.startsWith('equipment:')) return Color(0xFF1976D2);
    if (bookmark.startsWith('bakery:')) return AppTheme.primaryGreen;
    return AppTheme.textGrey;
  }

  void _openBookmarkDetail(String bookmark) {
    final parts = bookmark.split(':');
    final type = parts[0];
    final id = parts[1];

    // برای نمونه، فقط برای نانوایی و آگهی شغلی پیاده‌سازی می‌کنیم
    // در واقعیت باید از دیتابیس یا API آگهی رو بگیریم
    
    if (type == 'bakery') {
      // نمونه داده - باید از دیتابیس واقعی بگیری
      final sampleAd = BakeryAd(
        id: id,
        title: 'فروش نانوایی بربری',
        description: 'نانوایی با تجهیزات کامل و موقعیت عالی',
        type: BakeryAdType.sale,
        salePrice: 50000000,
        location: 'تهران',
        phoneNumber: '09123456789',
        images: [],
        createdAt: DateTime.now(),
      );
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BakeryDetailScreen(ad: sampleAd),
        ),
      );
    } else if (type == 'job_ad') {
      // نمونه داده - باید از دیتابیس واقعی بگیری
      final sampleAd = JobAd(
        id: id,
        title: 'نیازمند شاطر بربری',
        category: 'شاطر بربری',
        dailyBags: 5,
        salary: 7000000,
        location: 'تهران',
        phoneNumber: '09123456789',
        description: 'نیاز به شاطر با تجربه، پخت 5 کیسه روزانه',
        createdAt: DateTime.now(),
      );
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => JobAdDetailScreen(ad: sampleAd),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('این نوع آگهی هنوز پشتیبانی نمی‌شود'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Color(0xFFE3F2FD),
        appBar: AppBar(
          title: Text('نشانک‌ها'),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _bookmarks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          size: 80,
                          color: AppTheme.textGrey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'هنوز نشانکی ندارید',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppTheme.textGrey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'آگهی‌های مورد علاقه خود را نشانک کنید',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _bookmarks.length,
                    itemBuilder: (context, index) {
                      final bookmark = _bookmarks[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          onTap: () {
                            _openBookmarkDetail(bookmark);
                          },
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _getTypeColor(bookmark).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getTypeIcon(bookmark),
                              color: _getTypeColor(bookmark),
                            ),
                          ),
                          title: Text(
                            _getBookmarkTitle(bookmark),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          subtitle: Text(
                            _getTypeLabel(bookmark),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textGrey,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final parts = bookmark.split(':');
                              await BookmarkService.removeBookmark(
                                parts[1],
                                parts[0],
                              );
                              _loadBookmarks();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('نشانک حذف شد'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
