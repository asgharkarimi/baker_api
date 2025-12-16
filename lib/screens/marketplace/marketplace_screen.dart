import 'package:flutter/material.dart';
import '../../models/equipment_ad.dart';
import '../../models/bakery_ad.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/number_formatter.dart';
import '../../widgets/add_menu_fab.dart';
import '../equipment/equipment_detail_screen.dart';
import '../bakery/bakery_detail_screen.dart';
import '../map/map_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<EquipmentAd> _equipmentAds = [];
  List<BakeryAd> _bakeryAds = [];
  bool _isLoadingEquipment = true;
  bool _isLoadingBakery = true;
  
  // فیلترها
  String? _selectedProvince;
  BakeryAdType? _selectedType;
  RangeValues _priceRange = const RangeValues(0, 50000000000);
  RangeValues _flourQuotaRange = const RangeValues(0, 1000);
  bool _filtersApplied = false;
  
  final List<String> _provinces = [
    'تهران', 'اصفهان', 'فارس', 'خراسان رضوی', 'آذربایجان شرقی',
    'مازندران', 'خوزستان', 'گیلان', 'کرمان', 'آذربایجان غربی',
    'سیستان و بلوچستان', 'کرمانشاه', 'گلستان', 'هرمزگان', 'لرستان',
    'همدان', 'کردستان', 'مرکزی', 'قزوین', 'اردبیل', 'بوشهر',
    'زنجان', 'قم', 'یزد', 'چهارمحال و بختیاری', 'سمنان',
    'خراسان شمالی', 'خراسان جنوبی', 'کهگیلویه و بویراحمد', 'ایلام', 'البرز',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    _loadEquipmentAds();
    _loadBakeryAds();
  }

  Future<void> _loadEquipmentAds() async {
    setState(() => _isLoadingEquipment = true);
    try {
      final ads = await ApiService.getEquipmentAds();
      if (mounted) {
        setState(() {
          _equipmentAds = ads.map((json) => EquipmentAd.fromJson(json)).toList();
          _isLoadingEquipment = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingEquipment = false);
    }
  }

  Future<void> _loadBakeryAds() async {
    setState(() => _isLoadingBakery = true);
    try {
      final ads = await ApiService.getBakeryAds();
      if (mounted) {
        setState(() {
          _bakeryAds = ads;
          _isLoadingBakery = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingBakery = false);
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
        backgroundColor: Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Text('بازار'),
          actions: [
            IconButton(
              icon: Icon(Icons.map),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MapScreen()),
                );
              },
              tooltip: 'نقشه نانوایی‌ها',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryGreen,
            unselectedLabelColor: AppTheme.textGrey,
            indicatorColor: AppTheme.primaryGreen,
            tabs: [
              Tab(
                icon: Icon(Icons.store),
                text: 'نانوایی',
              ),
              Tab(
                icon: Icon(Icons.precision_manufacturing),
                text: 'دستگاه‌ها',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildBakeryList(),
            _buildEquipmentList(),
          ],
        ),
        floatingActionButton: AddMenuFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildEquipmentList() {
    if (_isLoadingEquipment) {
      return Center(child: CircularProgressIndicator());
    }
    if (_equipmentAds.isEmpty) {
      return Center(child: Text('آگهی تجهیزاتی یافت نشد'));
    }
    return RefreshIndicator(
      onRefresh: _loadEquipmentAds,
      child: ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: _equipmentAds.length,
      itemBuilder: (context, index) {
        final ad = _equipmentAds[index];
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
                  builder: (_) => EquipmentDetailScreen(ad: ad),
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
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.settings,
                          color: Color(0xFF1976D2),
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ad.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppTheme.textGrey,
                      ),
                    ],
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
                    ],
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'قیمت: ',
                          style: TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          NumberFormatter.formatPrice(ad.price),
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
      },
    ),
    );
  }

  Widget _buildBakeryList() {
    if (_isLoadingBakery) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_bakeryAds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_mall_directory_outlined, size: 80, color: AppTheme.textGrey),
            const SizedBox(height: 16),
            Text('آگهی نانوایی یافت نشد', style: TextStyle(color: AppTheme.textGrey, fontSize: 16)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadBakeryAds,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bakeryAds.length,
        itemBuilder: (context, index) => _buildBakeryCard(_bakeryAds[index]),
      ),
    );
  }

  Widget _buildBakeryCard(BakeryAd ad) {
    final isSale = ad.type == BakeryAdType.sale;
    final color = isSale ? Colors.blue : Colors.purple;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BakeryDetailScreen(ad: ad))),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Image or placeholder
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: ad.images.isNotEmpty
                  ? Image.network(
                      ad.images.first.startsWith('http') ? ad.images.first : 'http://10.0.2.2:3000${ad.images.first}',
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(color),
                    )
                  : _buildPlaceholder(color),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type badge and title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isSale ? '🏷️ فروش' : '🔑 رهن و اجاره',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      if (ad.images.length > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.photo_library, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('${ad.images.length}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    ad.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.red.shade400),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          ad.location,
                          style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Info chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (ad.flourQuota != null && ad.flourQuota! > 0)
                        _buildInfoChip(Icons.inventory_2, '${ad.flourQuota} کیسه آرد', Colors.deepOrange),
                      if (ad.breadPrice != null && ad.breadPrice! > 0)
                        _buildInfoChip(Icons.bakery_dining, NumberFormatter.formatPrice(ad.breadPrice!), Colors.brown),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Price
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isSale
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('قیمت فروش:', style: TextStyle(color: color, fontSize: 14)),
                              Text(
                                NumberFormatter.formatPrice(ad.salePrice ?? 0),
                                style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('رهن:', style: TextStyle(color: color, fontSize: 13)),
                                  Text(NumberFormatter.formatPrice(ad.rentDeposit ?? 0), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('اجاره ماهانه:', style: TextStyle(color: color, fontSize: 13)),
                                  Text(NumberFormatter.formatPrice(ad.monthlyRent ?? 0), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(Color color) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store, size: 50, color: color.withValues(alpha: 0.5)),
          const SizedBox(height: 8),
          Text('بدون تصویر', style: TextStyle(color: color.withValues(alpha: 0.5), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
