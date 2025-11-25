import 'package:flutter/material.dart';
import '../../models/equipment_ad.dart';
import '../../models/bakery_ad.dart';
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
  String _fabLabel = 'افزودن آگهی';

  final List<EquipmentAd> _sampleEquipmentAds = [
    EquipmentAd(
      id: '1',
      title: 'دستگاه ربات نانوایی',
      description: 'دستگاه ربات نانوایی در حد نو، کارکرد کم',
      price: 50000000,
      location: 'تهران',
      phoneNumber: '09121234567',
      images: [],
      videos: [],
      createdAt: DateTime.now(),
    ),
    EquipmentAd(
      id: '2',
      title: 'دستگاه چونه گیر اتوماتیک',
      description: 'دستگاه چونه گیر تمام اتوماتیک، مدل جدید، با گارانتی',
      price: 35000000,
      location: 'اصفهان',
      phoneNumber: '09131234567',
      images: [],
      videos: [],
      createdAt: DateTime.now().subtract(Duration(days: 1)),
    ),
    EquipmentAd(
      id: '3',
      title: 'تنور گازی صنعتی',
      description: 'تنور گازی 4 شعله، مناسب نانوایی بربری',
      price: 25000000,
      location: 'مشهد',
      phoneNumber: '09151234567',
      images: [],
      videos: [],
      createdAt: DateTime.now().subtract(Duration(days: 2)),
    ),
    EquipmentAd(
      id: '4',
      title: 'دستگاه خمیرگیر صنعتی',
      description: 'خمیرگیر 50 کیلویی، کارکرد 2 سال، سالم و تمیز',
      price: 18000000,
      location: 'شیراز',
      phoneNumber: '09171234567',
      images: [],
      videos: [],
      createdAt: DateTime.now().subtract(Duration(days: 3)),
    ),
    EquipmentAd(
      id: '5',
      title: 'دستگاه پخت لواش',
      description: 'دستگاه پخت لواش اتوماتیک، مدل 2023، فوری فروش',
      price: 45000000,
      location: 'کرج',
      phoneNumber: '09121234568',
      images: [],
      videos: [],
      createdAt: DateTime.now().subtract(Duration(days: 4)),
    ),
  ];

  final List<BakeryAd> _sampleBakeryAds = [
    BakeryAd(
      id: '1',
      title: 'فروش نانوایی بربری',
      description: 'فروش سه دانگ نانوایی بربری با ملکیت به متراژ 48 متر',
      type: BakeryAdType.sale,
      salePrice: 500000000,
      location: 'تهران، امام زاده حسن',
      phoneNumber: '09103563267',
      images: [],
      createdAt: DateTime.now(),
    ),
    BakeryAd(
      id: '2',
      title: 'رهن و اجاره نانوایی',
      description: 'آرد یارانه ای نوع 6، جای خواب و سرویس، دارای مجوز دو نوع نان',
      type: BakeryAdType.rent,
      rentDeposit: 50000000,
      monthlyRent: 15000000,
      location: 'قم، جعفریه',
      phoneNumber: '09124521803',
      images: [],
      createdAt: DateTime.now(),
    ),
    BakeryAd(
      id: '3',
      title: 'فروش نانوایی لواش',
      description: 'نانوایی لواش با تجهیزات کامل، موقعیت عالی، مشتری ثابت',
      type: BakeryAdType.sale,
      salePrice: 350000000,
      location: 'اصفهان، خیابان باهنر',
      phoneNumber: '09131234567',
      images: [],
      createdAt: DateTime.now().subtract(Duration(days: 1)),
    ),
    BakeryAd(
      id: '4',
      title: 'اجاره نانوایی بربری',
      description: 'نانوایی آماده کار، دستگاه ربات، آرد یارانه نوع 2',
      type: BakeryAdType.rent,
      rentDeposit: 80000000,
      monthlyRent: 20000000,
      location: 'مشهد، احمدآباد',
      phoneNumber: '09151234567',
      images: [],
      createdAt: DateTime.now().subtract(Duration(days: 2)),
    ),
    BakeryAd(
      id: '5',
      title: 'فروش فوری نانوایی',
      description: 'نانوایی بربری، 60 متر، با ملک، فروش فوری به دلیل مهاجرت',
      type: BakeryAdType.sale,
      salePrice: 450000000,
      location: 'شیراز، ستارخان',
      phoneNumber: '09171234567',
      images: [],
      createdAt: DateTime.now().subtract(Duration(days: 3)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _fabLabel = _tabController.index == 0 ? 'افزودن آگهی' : 'افزودن آگهی';
      });
    });
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
                icon: Icon(Icons.settings),
                text: 'دستگاه‌ها',
              ),
              Tab(
                icon: Icon(Icons.store),
                text: 'نانوایی',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildEquipmentList(),
            _buildBakeryList(),
          ],
        ),
        floatingActionButton: AddMenuFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildEquipmentList() {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: _sampleEquipmentAds.length,
      itemBuilder: (context, index) {
        final ad = _sampleEquipmentAds[index];
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
    );
  }

  Widget _buildBakeryList() {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: _sampleBakeryAds.length,
      itemBuilder: (context, index) {
        final ad = _sampleBakeryAds[index];
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
                  builder: (_) => BakeryDetailScreen(ad: ad),
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
                          ad.type == BakeryAdType.sale ? 'فروش' : 'رهن و اجاره',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
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
                    child: ad.type == BakeryAdType.sale
                        ? Row(
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
                                NumberFormatter.formatPrice(ad.salePrice!),
                                style: TextStyle(
                                  color: Color(0xFF1976D2),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'رهن: ',
                                    style: TextStyle(
                                      color: AppTheme.textGrey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    NumberFormatter.formatPrice(ad.rentDeposit!),
                                    style: TextStyle(
                                      color: Color(0xFF1976D2),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'اجاره: ',
                                    style: TextStyle(
                                      color: AppTheme.textGrey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    NumberFormatter.formatPrice(ad.monthlyRent!),
                                    style: TextStyle(
                                      color: Color(0xFF1976D2),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
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
    );
  }


}
