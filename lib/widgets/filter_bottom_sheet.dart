import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/iran_provinces.dart';

class FilterBottomSheet extends StatefulWidget {
  final String? selectedProvince;
  final RangeValues? priceRange;
  final Function(String?, RangeValues?) onApply;

  const FilterBottomSheet({
    super.key,
    this.selectedProvince,
    this.priceRange,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _selectedProvince;
  RangeValues _priceRange = const RangeValues(0, 100000000);

  @override
  void initState() {
    super.initState();
    _selectedProvince = widget.selectedProvince;
    _priceRange = widget.priceRange ?? const RangeValues(0, 100000000);
  }

  void _resetFilters() {
    setState(() {
      _selectedProvince = null;
      _priceRange = const RangeValues(0, 100000000);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'فیلترها',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // فیلتر استان
            Text(
              'استان',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedProvince,
              decoration: InputDecoration(
                hintText: 'همه استان‌ها',
                prefixIcon: Icon(Icons.location_on, color: AppTheme.primaryGreen),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              isExpanded: true,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('همه استان‌ها'),
                ),
                ...IranProvinces.getProvinces().map(
                  (province) => DropdownMenuItem(
                    value: province,
                    child: Text(province),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedProvince = value);
              },
            ),
            
            const SizedBox(height: 20),
            
            // فیلتر قیمت
            Text(
              'محدوده قیمت (تومان)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(_priceRange.start / 1000000).toStringAsFixed(0)} میلیون',
                  style: TextStyle(color: AppTheme.textGrey),
                ),
                Text(
                  '${(_priceRange.end / 1000000).toStringAsFixed(0)} میلیون',
                  style: TextStyle(color: AppTheme.textGrey),
                ),
              ],
            ),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 100000000,
              divisions: 100,
              activeColor: AppTheme.primaryGreen,
              onChanged: (values) {
                setState(() => _priceRange = values);
              },
            ),
            
            const SizedBox(height: 20),
            
            // دکمه‌ها
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('پاک کردن'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_selectedProvince, _priceRange);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('اعمال فیلتر'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
