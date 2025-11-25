import '../models/job_ad.dart';
import '../models/job_seeker.dart';
import '../models/bakery_ad.dart';

class MockData {
  // داده‌های واقعی‌تر برای آگهی‌های شغلی
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
        description: 'نانوایی بربری در منطقه پونک نیازمند شاطر با تجربه می‌باشد. دستگاه ربات، پخت 7 تا 8 کیسه در روز. محیط کار تمیز و مناسب. بیمه و عیدی و پاداش.',
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
      ),
      JobAd(
        id: '2',
        title: 'استخدام خمیرگیر تافتون',
        category: 'خمیرگیر تافتون',
        dailyBags: 6,
        salary: 7500000,
        location: 'کرج - گوهردشت',
        phoneNumber: '09351234567',
        description: 'نانوایی تافتون در گوهردشت کرج نیازمند خمیرگیر با تجربه. پخت 5 تا 6 کیسه. حقوق هفتگی 7.5 میلیون تومان. بیمه تامین اجتماعی.',
        createdAt: DateTime.now().subtract(Duration(hours: 5)),
      ),
      JobAd(
        id: '3',
        title: 'نیازمند چونه گیر لواش',
        category: 'چونه گیر لواش',
        dailyBags: 10,
        salary: 8500000,
        location: 'اصفهان - خیابان باهنر',
        phoneNumber: '09131234567',
        description: 'نانوایی لواش در خیابان باهنر اصفهان نیازمند چونه گیر ماهر. پخت 9 تا 10 کیسه روزانه. حقوق هفتگی 8.5 میلیون. بیمه و مزایا.',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
      ),
      JobAd(
        id: '4',
        title: 'استخدام شاطر سنگک',
        category: 'شاطر سنگک',
        dailyBags: 7,
        salary: 10000000,
        location: 'مشهد - احمدآباد',
        phoneNumber: '09151234567',
        description: 'نانوایی سنگک در احمدآباد مشهد نیازمند شاطر با تجربه بالا. پخت 6 تا 7 کیسه. حقوق عالی و مزایای کامل. محیط کار مناسب.',
        createdAt: DateTime.now().subtract(Duration(days: 2)),
      ),
      JobAd(
        id: '5',
        title: 'نیازمند خمیرگیر بربری',
        category: 'خمیرگیر بربری',
        dailyBags: 5,
        salary: 7000000,
        location: 'شیراز - ستارخان',
        phoneNumber: '09171234567',
        description: 'نانوایی بربری در ستارخان شیراز نیازمند خمیرگیر. پخت 4 تا 5 کیسه. دستگاه چونه دار. حقوق هفتگی 7 میلیون تومان.',
        createdAt: DateTime.now().subtract(Duration(days: 3)),
      ),
    ];
  }

  // داده‌های واقعی‌تر برای کارجویان
  static List<JobSeeker> getJobSeekers() {
    return [
      JobSeeker(
        id: '1',
        firstName: 'علی',
        lastName: 'محمدی',
        isMarried: true,
        skills: ['شاطر بربری', 'خمیرگیر بربری'],
        location: 'تهران',
        expectedSalary: 8500000,
        rating: 4.8,
        isSmoker: false,
        hasAddiction: false,
        createdAt: DateTime.now().subtract(Duration(hours: 3)),
      ),
      JobSeeker(
        id: '2',
        firstName: 'حسین',
        lastName: 'احمدی',
        isMarried: false,
        skills: ['خمیرگیر تافتون', 'چونه گیر تافتون'],
        location: 'کرج',
        expectedSalary: 7000000,
        rating: 4.5,
        isSmoker: false,
        hasAddiction: false,
        createdAt: DateTime.now().subtract(Duration(hours: 6)),
      ),
      JobSeeker(
        id: '3',
        firstName: 'مهدی',
        lastName: 'رضایی',
        isMarried: true,
        skills: ['شاطر سنگک'],
        location: 'اصفهان',
        expectedSalary: 9500000,
        rating: 4.9,
        isSmoker: false,
        hasAddiction: false,
        createdAt: DateTime.now().subtract(Duration(days: 1)),
      ),
      JobSeeker(
        id: '4',
        firstName: 'امیر',
        lastName: 'حسینی',
        isMarried: false,
        skills: ['چونه گیر لواش', 'خمیرگیر لواش'],
        location: 'مشهد',
        expectedSalary: 8000000,
        rating: 4.6,
        isSmoker: false,
        hasAddiction: false,
        createdAt: DateTime.now().subtract(Duration(days: 2)),
      ),
      JobSeeker(
        id: '5',
        firstName: 'رضا',
        lastName: 'کریمی',
        isMarried: true,
        skills: ['شاطر بربری', 'شاطر تافتون'],
        location: 'شیراز',
        expectedSalary: 8200000,
        rating: 4.7,
        isSmoker: false,
        hasAddiction: false,
        createdAt: DateTime.now().subtract(Duration(days: 3)),
      ),
    ];
  }

  // داده‌های واقعی‌تر برای آگهی‌های نانوایی
  static List<BakeryAd> getBakeryAds() {
    return [
      BakeryAd(
        id: '1',
        title: 'فروش نانوایی بربری در تهران',
        type: BakeryAdType.sale,
        salePrice: 450000000,
        location: 'تهران - نارمک',
        phoneNumber: '09121234567',
        description: 'نانوایی بربری با 15 سال سابقه، دستگاه ربات، پخت 8 کیسه، مشتری ثابت، موقعیت عالی، سند تک برگ.',
        images: [],
        createdAt: DateTime.now().subtract(Duration(hours: 4)),
      ),
      BakeryAd(
        id: '2',
        title: 'رهن و اجاره نانوایی تافتون',
        type: BakeryAdType.rent,
        rentDeposit: 100000000,
        monthlyRent: 15000000,
        location: 'کرج - مهرشهر',
        phoneNumber: '09351234567',
        description: 'نانوایی تافتون با دستگاه کامل، پخت 6 کیسه، مشتری خوب، رهن 100 میلیون، اجاره ماهانه 15 میلیون.',
        images: [],
        createdAt: DateTime.now().subtract(Duration(hours: 8)),
      ),
      BakeryAd(
        id: '3',
        title: 'فروش فوری نانوایی سنگک',
        type: BakeryAdType.sale,
        salePrice: 600000000,
        location: 'اصفهان - خیابان کاوه',
        phoneNumber: '09131234567',
        description: 'نانوایی سنگک با تنور سنتی، پخت 7 کیسه، مشتری عالی، فروش فوری به دلیل مهاجرت.',
        images: [],
        createdAt: DateTime.now().subtract(Duration(days: 1)),
      ),
      BakeryAd(
        id: '4',
        title: 'رهن و اجاره نانوایی لواش',
        type: BakeryAdType.rent,
        rentDeposit: 80000000,
        monthlyRent: 12000000,
        location: 'مشهد - بلوار وکیل آباد',
        phoneNumber: '09151234567',
        description: 'نانوایی لواش با دستگاه اتوماتیک، پخت 10 کیسه، رهن 80 میلیون، اجاره 12 میلیون.',
        images: [],
        createdAt: DateTime.now().subtract(Duration(days: 2)),
      ),
    ];
  }

  // شهرهای پرتکرار
  static List<String> getPopularCities() {
    return [
      'تهران',
      'کرج',
      'اصفهان',
      'مشهد',
      'شیراز',
      'تبریز',
      'اهواز',
      'قم',
      'کرمان',
      'رشت',
    ];
  }

  // دسته‌بندی‌های پرتکرار
  static List<String> getPopularCategories() {
    return [
      'شاطر بربری',
      'خمیرگیر بربری',
      'چونه گیر بربری',
      'شاطر تافتون',
      'خمیرگیر تافتون',
      'شاطر سنگک',
      'چونه گیر لواش',
      'خمیرگیر لواش',
    ];
  }
}
