# راهنمای استفاده از API Service

## فایل‌های ایجاد شده

### 1. `lib/data/mock_data.dart`
داده‌های واقعی‌تر برای تست شامل:
- 5 آگهی شغلی با جزئیات کامل
- 5 کارجو با مهارت‌های مختلف  
- 4 آگهی نانوایی (فروش و اجاره)

### 2. `lib/services/api_service.dart`
سرویس API با قابلیت‌های:
- `getJobAds()` - دریافت آگهی‌های شغلی با فیلتر
- `getJobSeekers()` - دریافت کارجویان
- `getBakeryAds()` - دریافت آگهی‌های نانوایی
- شبیه‌سازی تاخیر شبکه (500ms)
- آماده برای اتصال به API واقعی

## نحوه استفاده

### مثال 1: دریافت آگهی‌های شغلی

```dart
import '../../services/api_service.dart';

class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  List<JobAd> _ads = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final ads = await ApiService.getJobAds(
        category: 'شاطر بربری', // اختیاری
        location: 'تهران',       // اختیاری
        minSalary: 7000000,      // اختیاری
      );
      
      setState(() {
        _ads = ads;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // نمایش خطا
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    return ListView.builder(
      itemCount: _ads.length,
      itemBuilder: (context, index) {
        return ListTile(title: Text(_ads[index].title));
      },
    );
  }
}
```

### مثال 2: با RefreshIndicator

```dart
RefreshIndicator(
  onRefresh: _loadData,
  child: ListView.builder(...),
)
```

## اتصال به سرور واقعی

وقتی سرور آماده شد، فقط کافیه:

1. در `api_service.dart` مقدار `useMockData` رو `false` کن
2. `baseUrl` رو به آدرس سرور تغییر بده
3. کامنت‌های TODO رو uncomment کن

```dart
class ApiService {
  static const String baseUrl = 'https://your-server.com/api';
  static const bool useMockData = false; // تغییر به false
  
  static Future<List<JobAd>> getJobAds() async {
    if (useMockData) {
      // ...
    }
    
    // این قسمت فعال میشه
    final response = await http.get(Uri.parse('$baseUrl/job-ads'));
    return parseJobAds(response.body);
  }
}
```

## مزایا

✅ تست با داده‌های واقعی‌تر
✅ بدون نیاز به سرور
✅ آماده برای production
✅ کد تمیز و قابل نگهداری
✅ شبیه‌سازی تاخیر شبکه

## بعداً با هم...

وقتی سرور رو راه‌اندازی کردیم، با هم:
- Authentication اضافه می‌کنیم
- Upload عکس رو وصل می‌کنیم  
- Real-time notifications
- و خیلی چیزهای دیگه! 😄
