import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  
  // مختصات تهران
  final LatLng _center = LatLng(35.6892, 51.3890);
  
  // نمونه مکان‌های نانوایی‌ها
  final List<BakeryLocation> _bakeries = [
    BakeryLocation(
      name: 'نانوایی بربری امام زاده حسن',
      position: LatLng(35.6892, 51.3890),
      type: 'فروش',
    ),
    BakeryLocation(
      name: 'نانوایی لواش جعفریه',
      position: LatLng(34.6416, 50.8746),
      type: 'رهن و اجاره',
    ),
    BakeryLocation(
      name: 'نانوایی بربری ستارخان',
      position: LatLng(35.7219, 51.3347),
      type: 'فروش',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('نقشه نانوایی‌ها'),
          actions: [
            IconButton(
              icon: Icon(Icons.my_location),
              onPressed: () {
                _mapController.move(_center, 13.0);
              },
            ),
          ],
        ),
        body: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _center,
            initialZoom: 13.0,
            minZoom: 5.0,
            maxZoom: 18.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.my_bakers_jobapp',
            ),
            MarkerLayer(
              markers: _bakeries.map((bakery) {
                return Marker(
                  point: bakery.position,
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => _showBakeryInfo(bakery),
                    child: Container(
                      decoration: BoxDecoration(
                        color: bakery.type == 'فروش'
                            ? Colors.red
                            : Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.store,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showLegend();
          },
          backgroundColor: AppTheme.primaryGreen,
          child: Icon(Icons.info_outline, color: Colors.white),
        ),
      ),
    );
  }

  void _showBakeryInfo(BakeryLocation bakery) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.store, color: AppTheme.primaryGreen, size: 30),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      bakery.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: bakery.type == 'فروش'
                      ? Colors.red.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  bakery.type,
                  style: TextStyle(
                    color: bakery.type == 'فروش' ? Colors.red : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // اینجا می‌تونی به صفحه جزئیات بری
                  },
                  icon: Icon(Icons.visibility),
                  label: Text('مشاهده جزئیات'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLegend() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('راهنما'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLegendItem(Colors.red, 'نانوایی برای فروش'),
              SizedBox(height: 8),
              _buildLegendItem(Colors.blue, 'نانوایی برای رهن و اجاره'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('بستن'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 12),
        Text(label),
      ],
    );
  }
}

class BakeryLocation {
  final String name;
  final LatLng position;
  final String type;

  BakeryLocation({
    required this.name,
    required this.position,
    required this.type,
  });
}
