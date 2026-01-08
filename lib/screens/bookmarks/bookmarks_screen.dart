import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/bookmark_service.dart';
import '../../services/api_service.dart';
import '../../utils/number_formatter.dart';
import '../../widgets/shimmer_loading.dart';
import '../job_ads/job_ad_detail_screen.dart';
import '../bakery/bakery_detail_screen.dart';
import '../job_seekers/job_seeker_detail_screen.dart';
import '../equipment/equipment_detail_screen.dart';
import '../../models/job_ad.dart';
import '../../models/bakery_ad.dart';
import '../../models/job_seeker.dart';
import '../../models/equipment_ad.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  bool _isLoading = true;
  List<_BookmarkItem> _allBookmarks = [];

  @override
  void initState() {
    super.initState();
    // لود داده‌ها با تاخیر برای جلوگیری از هنگ UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllBookmarks();
    });
  }

  Future<void> _loadAllBookmarks() async {
    setState(() => _isLoading = true);

    final items = <_BookmarkItem>[];

    // آگهی‌های شغلی
    final jobAdIds = await BookmarkService.getBookmarksByType('job_ad');
    for (final id in jobAdIds) {
      final ad = await ApiService.getJobAdById(id);
      if (ad != null) {
        items.add(_BookmarkItem(
          id: ad.id,
          type: 'job_ad',
          title: ad.title,
          subtitle: ad.location,
          extra: NumberFormatter.formatPrice(ad.salary),
          icon: Icons.work_outline,
          color: const Color(0xFF4CAF50),
          data: ad,
        ));
      }
    }

    // جویندگان کار
    final jobSeekerIds = await BookmarkService.getBookmarksByType('job_seeker');
    for (final id in jobSeekerIds) {
      final seeker = await ApiService.getJobSeekerById(id);
      if (seeker != null) {
        items.add(_BookmarkItem(
          id: seeker.id,
          type: 'job_seeker',
          title: seeker.name,
          subtitle: seeker.location,
          extra: seeker.skills.take(2).join('، '),
          icon: Icons.person_outline,
          color: const Color(0xFF2196F3),
          data: seeker,
        ));
      }
    }

    // نانوایی‌ها
    final bakeryIds = await BookmarkService.getBookmarksByType('bakery');
    for (final id in bakeryIds) {
      try {
        final ads = await ApiService.getBakeryAds();
        final ad = ads.firstWhere((a) => a.id == id);
        items.add(_BookmarkItem(
          id: ad.id,
          type: 'bakery',
          title: ad.title,
          subtitle: ad.location,
          extra: ad.type == BakeryAdType.sale ? 'فروشی' : 'اجاره‌ای',
          icon: Icons.storefront_outlined,
          color: const Color(0xFFFF9800),
          data: ad,
        ));
      } catch (_) {}
    }

    // تجهیزات
    final equipmentIds = await BookmarkService.getBookmarksByType('equipment');
    for (final id in equipmentIds) {
      try {
        final ads = await ApiService.getEquipmentAds();
        final adMap = ads.firstWhere((a) => a['id'].toString() == id);
        final ad = EquipmentAd.fromJson(adMap);
        items.add(_BookmarkItem(
          id: ad.id,
          type: 'equipment',
          title: ad.title,
          subtitle: ad.location,
          extra: ad.condition,
          icon: Icons.precision_manufacturing_outlined,
          color: const Color(0xFF9C27B0),
          data: ad,
        ));
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _allBookmarks = items;
        _isLoading = false;
      });
    }
  }


  Future<void> _removeBookmark(_BookmarkItem item) async {
    await BookmarkService.removeBookmark(item.id, item.type);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('نشانک حذف شد'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      _loadAllBookmarks();
    }
  }

  void _openDetail(_BookmarkItem item) {
    Widget screen;
    switch (item.type) {
      case 'job_ad':
        screen = JobAdDetailScreen(ad: item.data as JobAd);
        break;
      case 'job_seeker':
        screen = JobSeekerDetailScreen(seeker: item.data as JobSeeker);
        break;
      case 'bakery':
        screen = BakeryDetailScreen(ad: item.data as BakeryAd);
        break;
      case 'equipment':
        screen = EquipmentDetailScreen(ad: item.data as EquipmentAd);
        break;
      default:
        return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'job_ad': return 'آگهی شغلی';
      case 'job_seeker': return 'جوینده کار';
      case 'bakery': return 'نانوایی';
      case 'equipment': return 'تجهیزات';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
        appBar: AppBar(
          title: const Text('نشانک‌ها'),
          centerTitle: true,
          elevation: 0,
        ),
        body: _isLoading
            ? ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                itemBuilder: (_, __) => const BookmarkShimmer(),
              )
            : _allBookmarks.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadAllBookmarks,
                    color: AppTheme.primaryGreen,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _allBookmarks.length,
                      itemBuilder: (context, index) => _buildBookmarkCard(_allBookmarks[index]),
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.bookmark_border_rounded, size: 60, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          Text('هنوز نشانکی ندارید',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          const SizedBox(height: 8),
          Text('آگهی‌های مورد علاقه خود را نشانک کنید',
              style: TextStyle(fontSize: 14, color: AppTheme.textGrey)),
        ],
      ),
    );
  }

  Widget _buildBookmarkCard(_BookmarkItem item) {
    return Dismissible(
      key: Key('${item.type}_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => _removeBookmark(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: item.color.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openDetail(item),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // آیکون
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [item.color, item.color.withValues(alpha: 0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(item.icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  // اطلاعات
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: item.color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getTypeLabel(item.type),
                                style: TextStyle(fontSize: 10, color: item.color, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: AppTheme.textGrey),
                            const SizedBox(width: 4),
                            Text(item.subtitle, style: TextStyle(fontSize: 13, color: AppTheme.textGrey)),
                          ],
                        ),
                        if (item.extra.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.extra,
                            style: TextStyle(fontSize: 13, color: item.color, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // فلش
                  Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.grey.shade300),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BookmarkItem {
  final String id;
  final String type;
  final String title;
  final String subtitle;
  final String extra;
  final IconData icon;
  final Color color;
  final dynamic data;

  _BookmarkItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.extra,
    required this.icon,
    required this.color,
    required this.data,
  });
}
