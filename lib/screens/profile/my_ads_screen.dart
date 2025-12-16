import 'package:flutter/material.dart';
import '../../models/job_ad.dart';
import '../../models/job_seeker.dart';
import '../../models/bakery_ad.dart';
import '../../models/equipment_ad.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/number_formatter.dart';
import '../../utils/time_ago.dart';
import '../job_ads/job_ad_detail_screen.dart';
import '../job_seekers/job_seeker_detail_screen.dart';
import '../bakery/bakery_detail_screen.dart';
import '../equipment/equipment_detail_screen.dart';

class MyAdsScreen extends StatefulWidget {
  const MyAdsScreen({super.key});

  @override
  State<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen> {
  List<JobAd> _jobAds = [];
  List<JobSeeker> _jobSeekers = [];
  List<BakeryAd> _bakeryAds = [];
  List<EquipmentAd> _equipmentAds = [];
  bool _isLoading = true;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadJobAds(),
      _loadJobSeekers(),
      _loadBakeryAds(),
      _loadEquipmentAds(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadJobAds() async {
    final ads = await ApiService.getMyJobAds();
    if (mounted) setState(() => _jobAds = ads);
  }

  Future<void> _loadJobSeekers() async {
    final seekers = await ApiService.getMyJobSeekers();
    if (mounted) setState(() => _jobSeekers = seekers);
  }

  Future<void> _loadBakeryAds() async {
    final ads = await ApiService.getMyBakeryAds();
    if (mounted) setState(() => _bakeryAds = ads);
  }

  Future<void> _loadEquipmentAds() async {
    final ads = await ApiService.getMyEquipmentAds();
    if (mounted) setState(() => _equipmentAds = ads);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Text(_selectedCategory ?? 'آگهی‌های من'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_selectedCategory != null) {
                setState(() => _selectedCategory = null);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _selectedCategory == null
                ? _buildCategoryList()
                : _buildAdsList(),
      ),
    );
  }

  Widget _buildCategoryList() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCategoryCard(
            title: 'نیازمند همکار',
            count: _jobAds.length,
            icon: Icons.work_outline,
            color: Colors.blue,
            onTap: () => setState(() => _selectedCategory = 'نیازمند همکار'),
          ),
          _buildCategoryCard(
            title: 'کاریابی',
            count: _jobSeekers.length,
            icon: Icons.person_search,
            color: AppTheme.primaryGreen,
            onTap: () => setState(() => _selectedCategory = 'کاریابی'),
          ),
          _buildCategoryCard(
            title: 'نانوایی',
            count: _bakeryAds.length,
            icon: Icons.store,
            color: Colors.orange,
            onTap: () => setState(() => _selectedCategory = 'نانوایی'),
          ),
          _buildCategoryCard(
            title: 'دستگاه',
            count: _equipmentAds.length,
            icon: Icons.precision_manufacturing,
            color: Colors.purple,
            onTap: () => setState(() => _selectedCategory = 'دستگاه'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count آگهی',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textGrey),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildAdsList() {
    switch (_selectedCategory) {
      case 'نیازمند همکار':
        return _buildJobAdsList();
      case 'کاریابی':
        return _buildJobSeekersList();
      case 'نانوایی':
        return _buildBakeryAdsList();
      case 'دستگاه':
        return _buildEquipmentAdsList();
      default:
        return const SizedBox();
    }
  }

  Widget _buildJobAdsList() {
    if (_jobAds.isEmpty) {
      return _buildEmptyState(Icons.work_off_outlined, 'آگهی نیازمند همکاری ندارید');
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
    if (_jobSeekers.isEmpty) {
      return _buildEmptyState(Icons.person_off_outlined, 'رزومه‌ای ثبت نکرده‌اید');
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

  Widget _buildBakeryAdsList() {
    if (_bakeryAds.isEmpty) {
      return _buildEmptyState(Icons.store_mall_directory_outlined, 'آگهی نانوایی ندارید');
    }
    return RefreshIndicator(
      onRefresh: _loadBakeryAds,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bakeryAds.length,
        itemBuilder: (context, index) => _buildBakeryAdCard(_bakeryAds[index]),
      ),
    );
  }

  Widget _buildEquipmentAdsList() {
    if (_equipmentAds.isEmpty) {
      return _buildEmptyState(Icons.precision_manufacturing_outlined, 'آگهی دستگاه ندارید');
    }
    return RefreshIndicator(
      onRefresh: _loadEquipmentAds,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _equipmentAds.length,
        itemBuilder: (context, index) => _buildEquipmentAdCard(_equipmentAds[index]),
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppTheme.textGrey),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 16, color: AppTheme.textGrey)),
        ],
      ),
    );
  }

  Widget _buildJobAdCard(JobAd ad) {
    return _buildAdCard(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobAdDetailScreen(ad: ad))),
      onDelete: () => _confirmDelete('job-ad', ad.id, ad.title),
      title: ad.title,
      subtitle: ad.location,
      price: NumberFormatter.formatPrice(ad.salary),
      isApproved: ad.isApproved,
      createdAt: ad.createdAt,
      icon: Icons.work_outline,
      color: Colors.blue,
    );
  }

  Widget _buildJobSeekerCard(JobSeeker seeker) {
    return _buildAdCard(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobSeekerDetailScreen(seeker: seeker))),
      onDelete: () => _confirmDelete('job-seeker', seeker.id, seeker.name),
      title: seeker.name,
      subtitle: seeker.skills.isNotEmpty ? seeker.skills.join('، ') : seeker.location,
      price: NumberFormatter.formatPrice(seeker.expectedSalary),
      isApproved: true,
      createdAt: seeker.createdAt,
      icon: Icons.person,
      color: AppTheme.primaryGreen,
    );
  }

  Widget _buildBakeryAdCard(BakeryAd ad) {
    return _buildAdCard(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BakeryDetailScreen(ad: ad))),
      onDelete: () => _confirmDelete('bakery-ad', ad.id, ad.title),
      title: ad.title,
      subtitle: ad.location,
      price: ad.type == BakeryAdType.sale
          ? NumberFormatter.formatPrice(ad.salePrice ?? 0)
          : NumberFormatter.formatPrice(ad.monthlyRent ?? 0),
      isApproved: ad.isApproved,
      createdAt: ad.createdAt,
      icon: Icons.store,
      color: Colors.orange,
      badge: ad.type == BakeryAdType.sale ? 'فروش' : 'اجاره',
    );
  }

  Widget _buildEquipmentAdCard(EquipmentAd ad) {
    return _buildAdCard(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EquipmentDetailScreen(ad: ad))),
      onDelete: () => _confirmDelete('equipment-ad', ad.id, ad.title),
      title: ad.title,
      subtitle: ad.location,
      price: NumberFormatter.formatPrice(ad.price),
      isApproved: ad.isApproved,
      createdAt: ad.createdAt,
      icon: Icons.precision_manufacturing,
      color: Colors.purple,
      badge: ad.condition == 'new' ? 'نو' : 'کارکرده',
    );
  }

  void _confirmDelete(String type, String id, String title) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف آگهی'),
          content: Text('آیا از حذف "$title" مطمئن هستید؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('انصراف'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final success = await ApiService.deleteAd(type, id);
                if (mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: const Text('آگهی حذف شد'), backgroundColor: AppTheme.primaryGreen),
                    );
                    _loadData();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('خطا در حذف آگهی'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdCard({
    required VoidCallback onTap,
    required VoidCallback onDelete,
    required String title,
    required String subtitle,
    required String price,
    required bool isApproved,
    required DateTime createdAt,
    required IconData icon,
    required Color color,
    String? badge,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isApproved
                            ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isApproved ? Icons.check_circle : Icons.pending,
                            size: 14,
                            color: isApproved ? AppTheme.primaryGreen : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isApproved ? 'تایید شده' : 'در انتظار',
                            style: TextStyle(
                              fontSize: 11,
                              color: isApproved ? AppTheme.primaryGreen : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(badge, style: TextStyle(fontSize: 11, color: color)),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      TimeAgo.format(createdAt),
                      style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        price,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Delete button
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'حذف',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
