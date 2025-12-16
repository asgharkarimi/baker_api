import 'package:flutter/material.dart';
import '../../models/job_ad.dart';
import '../../models/job_seeker.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/number_formatter.dart';
import '../../utils/time_ago.dart';
import '../job_ads/job_ad_detail_screen.dart';
import '../job_seekers/job_seeker_detail_screen.dart';

class MyAdsScreen extends StatefulWidget {
  const MyAdsScreen({super.key});

  @override
  State<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<JobAd> _jobAds = [];
  List<JobSeeker> _jobSeekers = [];
  bool _isLoadingJobs = true;
  bool _isLoadingSeekers = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    _loadJobAds();
    _loadJobSeekers();
  }

  Future<void> _loadJobAds() async {
    setState(() => _isLoadingJobs = true);
    final ads = await ApiService.getMyJobAds();
    if (mounted) {
      setState(() {
        _jobAds = ads;
        _isLoadingJobs = false;
      });
    }
  }

  Future<void> _loadJobSeekers() async {
    setState(() => _isLoadingSeekers = true);
    final seekers = await ApiService.getMyJobSeekers();
    if (mounted) {
      setState(() {
        _jobSeekers = seekers;
        _isLoadingSeekers = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('آگهی‌های من'),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(
                icon: const Icon(Icons.work_outline),
                text: 'نیازمند همکار (${_jobAds.length})',
              ),
              Tab(
                icon: const Icon(Icons.person_search),
                text: 'کارجو (${_jobSeekers.length})',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildJobAdsList(),
            _buildJobSeekersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildJobAdsList() {
    if (_isLoadingJobs) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_jobAds.isEmpty) {
      return _buildEmptyState(
        icon: Icons.work_off_outlined,
        title: 'آگهی نیازمند همکاری ندارید',
        subtitle: 'برای ثبت آگهی از دکمه + استفاده کنید',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJobAds,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _jobAds.length,
        itemBuilder: (context, index) => _buildJobAdCard(_jobAds[index]),
      ),
    );
  }

  Widget _buildJobSeekersList() {
    if (_isLoadingSeekers) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_jobSeekers.isEmpty) {
      return _buildEmptyState(
        icon: Icons.person_off_outlined,
        title: 'رزومه‌ای ثبت نکرده‌اید',
        subtitle: 'برای ثبت رزومه از دکمه + استفاده کنید',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJobSeekers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _jobSeekers.length,
        itemBuilder: (context, index) => _buildJobSeekerCard(_jobSeekers[index]),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppTheme.textGrey),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: AppTheme.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildJobAdCard(JobAd ad) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => JobAdDetailScreen(ad: ad)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ad.isApproved
                          ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          ad.isApproved ? Icons.check_circle : Icons.pending,
                          size: 14,
                          color: ad.isApproved ? AppTheme.primaryGreen : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ad.isApproved ? 'تایید شده' : 'در انتظار تایید',
                          style: TextStyle(
                            fontSize: 12,
                            color: ad.isApproved ? AppTheme.primaryGreen : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    TimeAgo.format(ad.createdAt),
                    style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ad.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textGrey),
                  const SizedBox(width: 4),
                  Text(ad.location, style: TextStyle(color: AppTheme.textGrey)),
                  const SizedBox(width: 16),
                  Icon(Icons.attach_money, size: 16, color: AppTheme.textGrey),
                  const SizedBox(width: 4),
                  Text(
                    NumberFormatter.formatPrice(ad.salary),
                    style: TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobSeekerCard(JobSeeker seeker) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => JobSeekerDetailScreen(seeker: seeker)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF1976D2).withValues(alpha: 0.1),
                    child: Text(
                      seeker.name.isNotEmpty ? seeker.name[0] : '?',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          seeker.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          seeker.skills.isNotEmpty ? seeker.skills.join('، ') : 'بدون تخصص',
                          style: TextStyle(fontSize: 14, color: AppTheme.textGrey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    TimeAgo.format(seeker.createdAt),
                    style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textGrey),
                  const SizedBox(width: 4),
                  Text(seeker.location, style: TextStyle(color: AppTheme.textGrey)),
                  const SizedBox(width: 16),
                  Icon(Icons.attach_money, size: 16, color: AppTheme.textGrey),
                  const SizedBox(width: 4),
                  Text(
                    NumberFormatter.formatPrice(seeker.expectedSalary),
                    style: TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
