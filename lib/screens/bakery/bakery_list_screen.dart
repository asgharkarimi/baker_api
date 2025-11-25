import 'package:flutter/material.dart';
import '../../models/bakery_ad.dart';
import '../../theme/app_theme.dart';
import 'bakery_detail_screen.dart';
import 'add_bakery_ad_screen.dart';

class BakeryListScreen extends StatefulWidget {
  const BakeryListScreen({super.key});

  @override
  State<BakeryListScreen> createState() => _BakeryListScreenState();
}

class _BakeryListScreenState extends State<BakeryListScreen> {
  final List<BakeryAd> _sampleAds = [
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
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('خرید و فروش نانوایی'),
        ),
        body: ListView.builder(
          itemCount: _sampleAds.length,
          itemBuilder: (context, index) {
            final ad = _sampleAds[index];
            return Card(
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BakeryDetailScreen(ad: ad),
                    ),
                  );
                },
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.store, color: AppTheme.primaryGreen),
                ),
                title: Text(ad.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ad.location),
                    if (ad.type == BakeryAdType.sale)
                      Text(
                        'فروش: ${ad.salePrice! ~/ 1000000} میلیون',
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      Text(
                        'رهن: ${ad.rentDeposit! ~/ 1000000}م - اجاره: ${ad.monthlyRent! ~/ 1000000}م',
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddBakeryAdScreen()),
            );
          },
          backgroundColor: AppTheme.primaryGreen,
          icon: Icon(Icons.add, color: AppTheme.white),
          label: Text(
            'افزودن آگهی',
            style: TextStyle(
              color: AppTheme.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
