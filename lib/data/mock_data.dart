import '../models/job_ad.dart';
import '../models/job_seeker.dart';
import '../models/bakery_ad.dart';

class MockData {
  static List<JobAd> getJobAds() {
    return [
      JobAd(
        id: '1',
        title: 'نیازمند شاطر بربری با تجربه',
        category: 'شاطر بربری',
        dailyBags: 8,
        salary: 9000000,
        location: 'تهران - پونک',
        phoneNumber: '09121234567',
        description: 'نانوایی بربری در منطقه پونک نیازمند شاطر با تجربه می‌باشد.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      JobAd(
        id: '2',
        title: 'استخدام خمیرگیر تافتون',
        category: 'خمیرگیر تافتون',
        dailyBags: 6,
        salary: 7500000,
        location: 'کرج - گوهردشت',
        phoneNumber: '09351234567',
        description: 'نانوایی تافتون در گوهردشت کرج نیازمند خمیرگیر با تجربه.',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      JobAd(
        id: '3',
        title: 'نیازمند چونه گیر لواش',
        category: 'چونه گیر لواش',
        dailyBags: 10,
        salary: 8500000,
        location: 'اصفهان - خیابان باهنر',
        phoneNumber: '09131234567',
        description: 'نانوایی لواش در خیابان باهنر اصفهان نیازمند چونه گیر ماهر.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      JobAd(
        id: '4',
        title: 'استخدام شاطر سنگک',
        category: 'شاطر سنگک',
        dailyBags: 7,
        salary: 10000000,
        location: 'مشهد - احمدآباد',
        phoneNumber: '09151234567',
        description: 'نانوایی سنگک در احمدآباد مشهد نیازمند شاطر با تجربه بالا.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      JobAd(
        id: '5',
        title: 'نیازمند خمیرگیر بربری',
        category: 'خمیرگیر بربری',
        dailyBags: 5,
        salary: 7000000,
        location: 'شیراز - ستارخان',
        phoneNumber: '09171234567',
        description: 'نانوایی بربری در ستارخان شیراز نیازمند خمیرگیر.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  static List<JobSeeker> getJobSeekers() {
    return [
      JobSeeker(
        id: '1',
        name: 'علی محمدی',
        skills: ['شاطر بربری', 'خمیرگیر بربری'],
        location: 'تهران',
        expectedSalary: 8500000,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      JobSeeker(
        id: '2',
        name: 'حسین احمدی',
        skills: ['خمیرگیر تافتون', 'چونه گیر تافتون'],
        location: 'کرج',
        expectedSalary: 7000000,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      JobSeeker(
        id: '3',
        name: 'مهدی رضایی',
        skills: ['شاطر سنگک'],
        location: 'اصفهان',
        expectedSalary: 9500000,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      JobSeeker(
        id: '4',
        name: 'امیر حسینی',
        skills: ['چونه گیر لواش', 'خمیرگیر لواش'],
        location: 'مشهد',
        expectedSalary: 8000000,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      JobSeeker(
        id: '5',
        name: 'رضا کریمی',
        skills: ['شاطر بربری', 'شاطر تافتون'],
        location: 'شیراز',
        expectedSalary: 8200000,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  static List<BakeryAd> getBakeryAds() {
    return [
      BakeryAd(
        id: '1',
        title: 'فروش نانوایی بربری در تهران',
        description: 'نانوایی بربری با 15 سال سابقه، دستگاه ربات، پخت 8 کیسه.',
        type: BakeryAdType.sale,
        salePrice: 450000000,
        location: 'تهران - نارمک',
        phoneNumber: '09121234567',
        images: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      BakeryAd(
        id: '2',
        title: 'رهن و اجاره نانوایی تافتون',
        description: 'نانوایی تافتون با دستگاه کامل، پخت 6 کیسه.',
        type: BakeryAdType.rent,
        rentDeposit: 100000000,
        monthlyRent: 15000000,
        location: 'کرج - مهرشهر',
        phoneNumber: '09351234567',
        images: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      BakeryAd(
        id: '3',
        title: 'فروش فوری نانوایی سنگک',
        description: 'نانوایی سنگک با تنور سنتی، پخت 7 کیسه.',
        type: BakeryAdType.sale,
        salePrice: 600000000,
        location: 'اصفهان - خیابان کاوه',
        phoneNumber: '09131234567',
        images: [],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      BakeryAd(
        id: '4',
        title: 'رهن و اجاره نانوایی لواش',
        description: 'نانوایی لواش با دستگاه اتوماتیک، پخت 10 کیسه.',
        type: BakeryAdType.rent,
        rentDeposit: 80000000,
        monthlyRent: 12000000,
        location: 'مشهد - بلوار وکیل آباد',
        phoneNumber: '09151234567',
        images: [],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  static List<String> getPopularCities() {
    return ['تهران', 'کرج', 'اصفهان', 'مشهد', 'شیراز', 'تبریز', 'اهواز', 'قم', 'کرمان', 'رشت'];
  }

  static List<String> getPopularCategories() {
    return ['شاطر بربری', 'خمیرگیر بربری', 'چونه گیر بربری', 'شاطر تافتون', 'خمیرگیر تافتون', 'شاطر سنگک', 'چونه گیر لواش', 'خمیرگیر لواش'];
  }
}
