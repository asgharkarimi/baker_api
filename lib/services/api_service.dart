import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job_ad.dart';
import '../models/job_seeker.dart';
import '../models/bakery_ad.dart';

class ApiService {
  // برای تست روی امولاتور اندروید از 10.0.2.2 استفاده کن
  // برای دستگاه واقعی از IP کامپیوترت استفاده کن
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  static String? _token;

  // ==================== Auth ====================
  
  static Future<void> _loadToken() async {
    if (_token != null) return;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  static Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // ارسال کد تایید
  static Future<Map<String, dynamic>> sendVerificationCode(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطا در اتصال به سرور'};
    }
  }

  // تایید کد و ورود
  static Future<Map<String, dynamic>> verifyCode(String phone, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'code': code}),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['token'] != null) {
        await _saveToken(data['token']);
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': 'خطا در اتصال به سرور'};
    }
  }

  // دریافت اطلاعات کاربر
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    await _loadToken();
    if (_token == null) return null;
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data['user'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ==================== Job Ads ====================
  
  static Future<List<JobAd>> getJobAds({
    String? category,
    String? location,
    int? minSalary,
    int? maxSalary,
    String? search,
    int page = 1,
  }) async {
    try {
      final params = <String, String>{
        'page': page.toString(),
        if (category != null) 'category': category,
        if (location != null) 'location': location,
        if (minSalary != null) 'minSalary': minSalary.toString(),
        if (maxSalary != null) 'maxSalary': maxSalary.toString(),
        if (search != null) 'search': search,
      };
      
      final uri = Uri.parse('$baseUrl/job-ads').replace(queryParameters: params);
      final response = await http.get(uri);
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        return (data['data'] as List).map((json) => JobAd.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching job ads: $e');
      return [];
    }
  }

  static Future<JobAd?> getJobAdById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/job-ads/$id'));
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        return JobAd.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> createJobAd(Map<String, dynamic> adData) async {
    await _loadToken();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/job-ads'),
        headers: _headers,
        body: jsonEncode(adData),
      );
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<JobAd>> getMyJobAds() async {
    await _loadToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/job-ads/my/list'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        return (data['data'] as List).map((json) => JobAd.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ==================== Job Seekers ====================
  
  static Future<List<JobSeeker>> getJobSeekers({
    String? location,
    int? maxSalary,
    String? search,
    int page = 1,
  }) async {
    try {
      final params = <String, String>{
        'page': page.toString(),
        if (location != null) 'location': location,
        if (maxSalary != null) 'maxSalary': maxSalary.toString(),
        if (search != null) 'search': search,
      };
      
      final uri = Uri.parse('$baseUrl/job-seekers').replace(queryParameters: params);
      final response = await http.get(uri);
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        return (data['data'] as List).map((json) => JobSeeker.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<JobSeeker?> getJobSeekerById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/job-seekers/$id'));
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        return JobSeeker.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> createJobSeeker(Map<String, dynamic> seekerData) async {
    await _loadToken();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/job-seekers'),
        headers: _headers,
        body: jsonEncode(seekerData),
      );
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // ==================== Bakery Ads ====================
  
  static Future<List<BakeryAd>> getBakeryAds({
    BakeryAdType? type,
    String? location,
    String? search,
    int page = 1,
  }) async {
    try {
      final params = <String, String>{
        'page': page.toString(),
        if (type != null) 'type': type == BakeryAdType.sale ? 'sale' : 'rent',
        if (location != null) 'location': location,
        if (search != null) 'search': search,
      };
      
      final uri = Uri.parse('$baseUrl/bakery-ads').replace(queryParameters: params);
      final response = await http.get(uri);
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        return (data['data'] as List).map((json) => BakeryAd.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> createBakeryAd(Map<String, dynamic> adData) async {
    await _loadToken();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bakery-ads'),
        headers: _headers,
        body: jsonEncode(adData),
      );
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // ==================== Equipment Ads ====================
  
  static Future<List<Map<String, dynamic>>> getEquipmentAds({
    String? condition,
    String? location,
    String? search,
    int page = 1,
  }) async {
    try {
      final params = <String, String>{
        'page': page.toString(),
        if (condition != null) 'condition': condition,
        if (location != null) 'location': location,
        if (search != null) 'search': search,
      };
      
      final uri = Uri.parse('$baseUrl/equipment-ads').replace(queryParameters: params);
      final response = await http.get(uri);
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> createEquipmentAd(Map<String, dynamic> adData) async {
    await _loadToken();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/equipment-ads'),
        headers: _headers,
        body: jsonEncode(adData),
      );
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // ==================== Upload ====================
  
  static Future<String?> uploadImage(File file) async {
    await _loadToken();
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload/image'));
      request.headers['Authorization'] = 'Bearer $_token';
      request.files.add(await http.MultipartFile.fromPath('image', file.path));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        return data['data']['url'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<String>> uploadImages(List<File> files) async {
    await _loadToken();
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload/images'));
      request.headers['Authorization'] = 'Bearer $_token';
      
      for (var file in files) {
        request.files.add(await http.MultipartFile.fromPath('images', file.path));
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        return (data['data'] as List).map((f) => f['url'] as String).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ==================== Notifications ====================
  
  static Future<List<Map<String, dynamic>>> getNotifications({int page = 1}) async {
    await _loadToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications?page=$page'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<int> getUnreadNotificationCount() async {
    await _loadToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications?page=1&limit=1'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      return data['unreadCount'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // ==================== Statistics ====================
  
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/statistics'));
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        return data['data'];
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  // ==================== Chat ====================
  
  static Future<List<Map<String, dynamic>>> getConversations() async {
    await _loadToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/conversations'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getMessages(int recipientId) async {
    await _loadToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/messages/$recipientId'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> sendMessage(int receiverId, String message) async {
    await _loadToken();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/send'),
        headers: _headers,
        body: jsonEncode({'receiverId': receiverId, 'message': message}),
      );
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // ==================== Helper ====================
  
  static bool get isLoggedIn => _token != null;
  
  static Future<bool> checkAuth() async {
    await _loadToken();
    return _token != null;
  }
}
