import 'dart:async';
import '../models/job_ad.dart';
import '../models/job_seeker.dart';
import '../models/bakery_ad.dart';
import '../data/mock_data.dart';

class ApiService {
  // Base URL - بعداً به سرور واقعی تغییر میده
  static const String baseUrl = 'http://localhost:3000'; // فعلاً استفاده نمیشه
  static const bool useMockData = true; // برای تست

  // تاخیر شبیه‌سازی شده برای network
  static Future<void> _simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: 500));
  }

  // ==================== Job Ads ====================
  
  static Future<List<JobAd>> getJobAds({
    String? category,
    String? location,
    int? minSalary,
    int? maxSalary,
  }) async {
    await _simulateNetworkDelay();
    
    if (useMockData) {
      var ads = MockData.getJobAds();
      
      // فیلتر کردن
      if (category != null && category.isNotEmpty) {
        ads = ads.where((ad) => ad.category == category).toList();
      }
      if (location != null && location.isNotEmpty) {
        ads = ads.where((ad) => ad.location.contains(location)).toList();
      }
      if (minSalary != null) {
        ads = ads.where((ad) => ad.salary >= minSalary).toList();
      }
      if (maxSalary != null) {
        ads = ads.where((ad) => ad.salary <= maxSalary).toList();
      }
      
      return ads;
    }
    
    // TODO: بعداً اینجا API واقعی صدا زده میشه
    // final response = await http.get(Uri.parse('$baseUrl/job-ads'));
    // return parseJobAds(response.body);
    
    return [];
  }

  static Future<JobAd?> getJobAdById(String id) async {
    await _simulateNetworkDelay();
    
    if (useMockData) {
      final ads = MockData.getJobAds();
      try {
        return ads.firstWhere((ad) => ad.id == id);
      } catch (e) {
        return null;
      }
    }
    
    // TODO: API واقعی
    return null;
  }

  static Future<bool> createJobAd(JobAd ad) async {
    await _simulateNetworkDelay();
    
    if (useMockData) {
      // شبیه‌سازی موفقیت
      return true;
    }
    
    // TODO: API واقعی
    // final response = await http.post(
    //   Uri.parse('$baseUrl/job-ads'),
    //   body: jsonEncode(ad.toJson()),
    // );
    // return response.statusCode == 201;
    
    return false;
  }

  // ==================== Job Seekers ====================
  
  static Future<List<JobSeeker>> getJobSeekers({
    List<String>? skills,
    String? location,
    int? maxSalary,
  }) async {
    await _simulateNetworkDelay();
    
    if (useMockData) {
      var seekers = MockData.getJobSeekers();
      
      // فیلتر کردن
      if (skills != null && skills.isNotEmpty) {
        seekers = seekers.where((seeker) {
          return seeker.skills.any((skill) => skills.contains(skill));
        }).toList();
      }
      if (location != null && location.isNotEmpty) {
        seekers = seekers.where((s) => s.location.contains(location)).toList();
      }
      if (maxSalary != null) {
        seekers = seekers.where((s) => s.expectedSalary <= maxSalary).toList();
      }
      
      return seekers;
    }
    
    // TODO: API واقعی
    return [];
  }

  static Future<JobSeeker?> getJobSeekerById(String id) async {
    await _simulateNetworkDelay();
    
    if (useMockData) {
      final seekers = MockData.getJobSeekers();
      try {
        return seekers.firstWhere((s) => s.id == id);
      } catch (e) {
        return null;
      }
    }
    
    // TODO: API واقعی
    return null;
  }

  // ==================== Bakery Ads ====================
  
  static Future<List<BakeryAd>> getBakeryAds({
    BakeryAdType? type,
    String? location,
  }) async {
    await _simulateNetworkDelay();
    
    if (useMockData) {
      var ads = MockData.getBakeryAds();
      
      // فیلتر کردن
      if (type != null) {
        ads = ads.where((ad) => ad.type == type).toList();
      }
      if (location != null && location.isNotEmpty) {
        ads = ads.where((ad) => ad.location.contains(location)).toList();
      }
      
      return ads;
    }
    
    // TODO: API واقعی
    return [];
  }

  // ==================== Statistics ====================
  
  static Future<Map<String, dynamic>> getStatistics() async {
    await _simulateNetworkDelay();
    
    if (useMockData) {
      return {
        'totalJobAds': MockData.getJobAds().length,
        'totalJobSeekers': MockData.getJobSeekers().length,
        'totalBakeryAds': MockData.getBakeryAds().length,
        'newAdsToday': 3,
        'activeUsers': 127,
      };
    }
    
    // TODO: API واقعی
    return {};
  }

  // ==================== Helper Methods ====================
  
  static Future<List<String>> getPopularCities() async {
    await _simulateNetworkDelay();
    return MockData.getPopularCities();
  }

  static Future<List<String>> getPopularCategories() async {
    await _simulateNetworkDelay();
    return MockData.getPopularCategories();
  }
}
