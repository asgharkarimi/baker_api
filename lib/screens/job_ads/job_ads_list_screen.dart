import 'package:flutter/material.dart';
import '../../models/job_ad.dart';
import '../../theme/app_theme.dart';
import '../../utils/number_formatter.dart';
import '../../utils/time_ago.dart';
import '../../widgets/notification_badge.dart';
import '../../widgets/time_filter_bottom_sheet.dart';
import '../../widgets/add_menu_fab.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/shimmer_loading.dart';
import '../../services/api_service.dart';
import 'job_ad_detail_screen.dart';

class JobAdsListScreen extends StatefulWidget {
  const JobAdsListScreen({super.key});

  @override
  State<JobAdsListScreen> createState() => _JobAdsListScreenState();
}

class _JobAdsListScreenState extends State<JobAdsListScreen> {
  List<JobAd> _ads = [];
  List<JobAd> _filteredAds = [];
  bool _isLoading = true;
  String? _selectedProvince;
  TimeFilter? _selectedTimeFilter;

  @override
  void initState() {
    super.initState();
    _loadJobAds();
  }

  Future<void> _loadJobAds() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final ads = await ApiService.getJobAds();
      if (!mounted) return;
      setState(() {
        _ads = ads;
        _filteredAds = ads;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در بارگذاری آگهی‌ها')),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredAds = _ads.where((ad) {
        // فیلتر استان
        if (_selectedProvince != null && ad.location != _selectedProvince) {
          return false;
        }
        
        // فیلتر زمانی
        if (_selectedTimeFilter != null && _selectedTimeFilter != TimeFilter.all) {
          final now = DateTime.now();
          final adDate = ad.createdAt;
          
          switch (_selectedTimeFilter!) {
            case TimeFilter.today:
              if (adDate.day != now.day || 
                  adDate.month != now.month || 
                  adDate.year != now.year) {
                return false;
              }
              break;
            case TimeFilter.yesterday:
              final yesterday = now.subtract(const Duration(days: 1));
              if (adDate.day != yesterday.day || 
                  adDate.month != yesterday.month || 
                  adDate.year != yesterday.year) {
                return false;
              }
              break;
            case TimeFilter.lastWeek:
              final weekAgo = now.subtract(const Duration(days: 7));
              if (adDate.isBefore(weekAgo)) {
                return false;
              }
              break;
            case TimeFilter.lastMonth:
              final monthAgo = now.subtract(const Duration(days: 30));
              if (adDate.isBefore(monthAgo)) {
                return false;
              }
              break;
            case TimeFilter.all:
              break;
          }
        }
        
        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('نیازمند همکار'),
        actions: [
          NotificationBadge(),
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.filter_list),
                if (_selectedProvince != null || 
                    (_selectedTimeFilter != null && _selectedTimeFilter != TimeFilter.all))
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => TimeFilterBottomSheet(
                  selectedProvince: _selectedProvince,
                  selectedTimeFilter: _selectedTimeFilter,
                  onApply: (province, timeFilter) {
                    setState(() {
                      _selectedProvince = province;
                      _selectedTimeFilter = timeFilter;
                    });
                    _applyFilters();
                  },
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Color(0xFFE3F2FD),
      body: _isLoading
          ? ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 5,
              itemBuilder: (context, index) => const JobAdShimmer(),
            )
          : _filteredAds.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.work_off_outlined,
                  title: 'هیچ آگهی شغلی یافت نشد',
                  message: 'در حال حاضر آگهی شغلی موجود نیست.\nاولین نفری باشید که آگهی ثبت می‌کند!',
                  buttonText: 'افزودن آگهی شغلی',
                  onButtonPressed: () {
                    // منوی افزودن باز میشه
                  },
                )
              : RefreshIndicator(
                  onRefresh: _loadJobAds,
                  color: AppTheme.primaryGreen,
                  child: ListView.builder(
                    padding: EdgeInsets.all(20),
                    itemCount: _filteredAds.length,
                    itemBuilder: (context, index) {
                      final ad = _filteredAds[index];
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 50 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: _buildJobAdCard(ad),
                      );
                    },
                  ),
                ),
      floatingActionButton: AddMenuFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildJobAdCard(JobAd ad) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => JobAdDetailScreen(ad: ad),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF42A5F5),
                          Color(0xFF64B5F6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF42A5F5).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      ad.category,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppTheme.primaryGreen,
                        ),
                        SizedBox(width: 4),
                        Text(
                          TimeAgo.format(ad.createdAt),
                          style: TextStyle(
                            color: AppTheme.primaryGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppTheme.textGrey,
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                ad.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppTheme.textGrey,
                  ),
                  SizedBox(width: 4),
                  Text(
                    ad.location,
                    style: TextStyle(
                      color: AppTheme.textGrey,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 16),
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 16,
                    color: AppTheme.textGrey,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${ad.dailyBags} کیسه',
                    style: TextStyle(
                      color: AppTheme.textGrey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'حقوق هفتگی: ',
                      style: TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      NumberFormatter.formatPrice(ad.salary),
                      style: TextStyle(
                        color: Color(0xFF1976D2),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
