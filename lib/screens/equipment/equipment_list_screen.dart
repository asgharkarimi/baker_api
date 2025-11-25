import 'package:flutter/material.dart';
import '../../models/equipment_ad.dart';
import '../../theme/app_theme.dart';
import 'add_equipment_ad_screen.dart';

class EquipmentListScreen extends StatefulWidget {
  const EquipmentListScreen({super.key});

  @override
  State<EquipmentListScreen> createState() => _EquipmentListScreenState();
}

class _EquipmentListScreenState extends State<EquipmentListScreen> {
  final List<EquipmentAd> _sampleAds = [
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
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('خرید و فروش دستگاه'),
        ),
        body: ListView.builder(
          itemCount: _sampleAds.length,
          itemBuilder: (context, index) {
            final ad = _sampleAds[index];
            return Card(
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.settings, color: AppTheme.primaryGreen),
                ),
                title: Text(ad.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ad.location),
                    Text(
                      '${ad.price ~/ 1000000} میلیون تومان',
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddEquipmentAdScreen()),
            );
          },
          backgroundColor: AppTheme.primaryGreen,
          child: Icon(Icons.add, color: AppTheme.white),
        ),
      ),
    );
  }
}
