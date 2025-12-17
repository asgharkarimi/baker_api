import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/job_ad.dart';
import '../../theme/app_theme.dart';
import '../../utils/number_formatter.dart';
import '../../utils/time_ago.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/notification_badge.dart';
import '../../widgets/time_filter_bottom_sheet.dart';
import '../../widgets/add_menu_fab.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_state_widget.dart';
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
  bool _hasError = false;
  String? _errorMessage;
  String? _selectedProvince;
  TimeFilter? _selectedTimeFilter;

  @override
  void initState() {
    super.initState();
    _loadJobAds();
  }

  Future<void> _loadJobAds() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // تایم‌اوت 4 ثانیه
      final ads = await ApiService.getJobAds().timeout(
        const Duration(seconds: 4),
        onTimeout: () {
          throw TimeoutException('سرور پاسخ نمی‌دهد');
        },
      );

      if (!mounted) return;
      setState(() {
        _ads = ads;
        _filteredAds = ads;
        _isLoading = false;
        _hasError = false;
      });
      _applyFilters();
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'سرور در دسترس نیست.\nلطفاً بعداً تلاش کنید.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'خطا در اتصال به سرور.\nلطفاً اتصال اینترنت خود را بررسی کنید.';
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredAds = _ads.where((ad) {
        if (_selectedProvince != null && ad.location != _selectedProvince) {
          return false;
        }

        if (_selectedTimeFilter != null &&
            _selectedTimeFilter != TimeFilter.all) {
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
        title: const Text('نیازمند همکار'),
        actions: [
          const NotificationBadge(),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (_selectedProvince != null ||
                    (_selectedTimeFilter != null &&
                        _selectedTimeFilter != TimeFilter.all))
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
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
      backgroundColor: const Color(0xFFE3F2FD),
      body: _buildBody(),
      floatingActionButton: const AddMenuFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 5,
        itemBuilder: (context, index) => const JobAdShimmer(),
      );
    }

    if (_hasError) {
      return ErrorStateWidget(
        message: _errorMessage,
        onRetry: _loadJobAds,
      );
    }

    if (_filteredAds.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.work_off_outlined,
        title: 'هیچ آگهی شغلی یافت نشد',
        message: 'در حال حاضر آگهی شغلی موجود نیست.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJobAds,
      color: AppTheme.primaryGreen,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
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
    );
  }

  Widget _buildJobAdCard(JobAd ad) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Nav.toDetail(context, JobAdDetailScreen(ad: ad)),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ردیف بالا: دسته‌بندی + زمان + فلش
                  Row(
                    children: [
                      // دسته‌بندی
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF26A69A), Color(0xFF4DB6AC)],
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          ad.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // زمان
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 15,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              TimeAgo.format(ad.createdAt),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // فلش
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 14,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // عنوان
                  Text(
                    ad.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // موقعیت و کیسه
                  Row(
                    children: [
                      _buildInfoChip(Icons.location_on, ad.location),
                      const SizedBox(width: 16),
                      _buildInfoChip(Icons.inventory_2_outlined, '${ad.dailyBags} کیسه'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // حقوق
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'حقوق هفتگی: ',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          NumberFormatter.formatPrice(ad.salary),
                          style: const TextStyle(
                            color: Color(0xFF2E7D32),
                            fontSize: 17,
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
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
