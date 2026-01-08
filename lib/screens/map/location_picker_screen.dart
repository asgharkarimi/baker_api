import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_theme.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerScreen({super.key, this.initialLocation});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late MapController _mapController;
  late LatLng _selectedLocation;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = widget.initialLocation ?? LatLng(35.6892, 51.3890); // تهران
    
    // بعد از یه تاخیر کوتاه نقشه رو آماده نشون بده
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isMapReady = true;
        });
      }
    });
  }

  void _onMapTap(TapPosition tapPosition, LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  void _confirmLocation() {
    Navigator.pop(context, _selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('انتخاب موقعیت'),
          actions: [
            IconButton(
              icon: Icon(Icons.my_location),
              onPressed: () {
                _mapController.move(_selectedLocation, 13.0);
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            if (!_isMapReady)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'در حال بارگذاری نقشه...',
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            if (_isMapReady)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLocation,
                initialZoom: 13.0,
                onTap: _onMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.example.my_bakers_jobapp',
                  tileBuilder: (context, tileWidget, tile) {
                    return AnimatedOpacity(
                      opacity: 1.0,
                      duration: Duration(milliseconds: 300),
                      child: tileWidget,
                    );
                  },
                  errorTileCallback: (tile, error, stackTrace) {
                    // در صورت خطا در لود تایل، بی‌صدا رد شو
                  },
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation,
                      width: 50,
                      height: 50,
                      child: Icon(
                        Icons.location_pin,
                        size: 50,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'روی نقشه کلیک کنید تا موقعیت را انتخاب کنید',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: ElevatedButton.icon(
                onPressed: _confirmLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.check, color: Colors.white),
                label: Text(
                  'تأیید موقعیت',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
