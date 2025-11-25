import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/iran_provinces.dart';

enum TimeFilter {
  all,
  today,
  yesterday,
  lastWeek,
  lastMonth,
}

class TimeFilterBottomSheet extends StatefulWidget {
  final String? selectedProvince;
  final TimeFilter? selectedTimeFilter;
  final Function(String?, TimeFilter?) onApply;

  const TimeFilterBottomSheet({
    super.key,
    this.selectedProvince,
    this.selectedTimeFilter,
    required this.onApply,
  });

  @override
  State<TimeFilterBottomSheet> createState() => _TimeFilterBottomSheetState();
}

class _TimeFilterBottomSheetState extends State<TimeFilterBottomSheet> {
  String? _selectedProvince;
  TimeFilter _selectedTimeFilter = TimeFilter.all;

  @override
  void initState() {
    super.initState();
    _selectedProvince = widget.selectedProvince;
    _selectedTimeFilter = widget.selectedTimeFilter ?? TimeFilter.all;
  }

  void _resetFilters() {
    setState(() {
      _selectedProvince = null;
      _selectedTimeFilter = TimeFilter.all;
    });
  }

  String _getTimeFilterLabel(TimeFilter filter) {
    switch (filter) {
      case TimeFilter.all:
        return 'همه';
      case TimeFilter.today:
        return 'امروز';
      case TimeFilter.yesterday:
        return 'دیروز';
      case TimeFilter.lastWeek:
        return 'هفته گذشته';
      case TimeFilter.lastMonth:
        return 'ماه گذشته';
    }
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
            
            // فیلتر زمانی
            Text(
              'زمان انتشار',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TimeFilter.values.map((filter) {
                final isSelected = _selectedTimeFilter == filter;
                return ChoiceChip(
                  label: Text(_getTimeFilterLabel(filter)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedTimeFilter = filter);
                  },
                  selectedColor: AppTheme.primaryGreen,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textDark,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                );
              }).toList(),
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
                      widget.onApply(_selectedProvince, _selectedTimeFilter);
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
