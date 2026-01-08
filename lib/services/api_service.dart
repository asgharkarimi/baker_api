import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/job_ad.dart';
import '../models/job_seeker.dart';
import '../models/bakery_ad.dart';
import '../models/equipment_ad.dart';
import 'media_compressor.dart';
import 'cache_service.dart';
import 'encryption_service.dart';
import 'background_processor.dart';

class ApiService {
  // آدرس سرور آنلاین
  static const String baseUrl = 'https://bakerjobs.ir/api';
  static const String serverUrl = 'https://bakerjobs.ir';
  static const Duration _timeout = Duration(seconds: 15);
  
  // فعال/غیرفعال کردن لاگ زمان‌بندی
  static bool enableTimingLogs = true;
  
  static String? _token;
  static int? _currentUserId;
  
  // Secure storage برای ذخیره امن توکن
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  
  // Callback برای نمایش پیام آفلاین
  static Function(String)? onServerUnavailable;

  /// لاگ زمان‌بندی برای debug
  static void _logTiming(String operation, int ms) {
    if (!enableTimingLogs) return;
    final emoji = ms < 500 ? '🟢' : ms < 1500 ? '🟡' : '🔴';
    debugPrint('$emoji [$operation] ${ms}ms');
  }

  /// تبدیل خطای فنی به پیام کاربرپسند فارسی
  static String _getUserFriendlyError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('timeout') || errorStr.contains('timed out')) {
      return 'سرور پاسخ نمی‌دهد. لطفاً دوباره تلاش کنید';
    }
    if (errorStr.contains('socket') || errorStr.contains('connection refused')) {
      return 'خطا در اتصال به سرور';
    }
    if (errorStr.contains('network') || errorStr.contains('unreachable')) {
      return 'اینترنت در دسترس نیست';
    }
    if (errorStr.contains('handshake') || errorStr.contains('certificate')) {
      return 'خطا در برقراری ارتباط امن';
    }
    if (errorStr.contains('host') || errorStr.contains('dns')) {
      return 'سرور یافت نشد';
    }
    
    return 'خطا در ارتباط با سرور';
  }

  // ==================== Auth ====================
  
  static Future<void> _loadToken() async {
    if (_token != null) return;
    _token = await _secureStorage.read(key: 'auth_token');
  }

  static Future<void> _saveToken(String token) async {
    _token = token;
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  static Future<void> logout() async {
    _token = null;
    await _secureStorage.delete(key: 'auth_token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }

  static Future<bool> isLoggedIn() async {
    await _loadToken();
    return _token != null && _token!.isNotEmpty;
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // ارسال کد تایید
  static Future<Map<String, dynamic>> sendVerificationCode(String phone) async {
    try {
      debugPrint('📤 Sending code to: $baseUrl/auth/send-code');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      ).timeout(const Duration(seconds: 30));
      debugPrint('📥 Response: ${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('❌ Error: $e');
      return {'success': false, 'message': _getUserFriendlyError(e)};
    }
  }

  // تایید کد و ورود
  static Future<Map<String, dynamic>> verifyCode(String phone, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'code': code}),
      ).timeout(_timeout);
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['token'] != null) {
        await _saveToken(data['token']);
        // ذخیره userId
        if (data['user'] != null && data['user']['id'] != null) {
          _currentUserId = data['user']['id'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', _currentUserId!);
          // تنظیم userId برای رمزنگاری
          EncryptionService.setMyUserId(_currentUserId!);
        }
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': _getUserFriendlyError(e)};
    }
  }
  
  // دریافت userId کاربر فعلی
  static Future<int?> getCurrentUserId() async {
    if (_currentUserId != null) return _currentUserId;
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getInt('user_id');
    // تنظیم userId برای رمزنگاری
    if (_currentUserId != null) {
      EncryptionService.setMyUserId(_currentUserId!);
    }
    return _currentUserId;
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

  // ویرایش پروفایل
  static Future<bool> updateProfile({
    String? name,
    String? profileImage,
    String? bio,
    String? city,
    String? province,
    String? birthDate,
    List<String>? skills,
    int? experience,
    String? education,
    String? instagram,
    String? telegram,
    String? website,
  }) async {
    await _loadToken();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: _headers,
        body: jsonEncode({
          if (name != null) 'name': name,
          if (profileImage != null) 'profileImage': profileImage,
          if (bio != null) 'bio': bio,
          if (city != null) 'city': city,
          if (province != null) 'province': province,
          if (birthDate != null) 'birthDate': birthDate,
          if (skills != null) 'skills': skills,
          if (experience != null) 'experience': experience,
          if (education != null) 'education': education,
          if (instagram != null) 'instagram': instagram,
          if (telegram != null) 'telegram': telegram,
          if (website != null) 'website': website,
        }),
      );
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      return false;
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
    bool useCache = true,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    // اگه صفحه اول و بدون فیلتر بود، از کش استفاده کن
    final canUseCache = useCache && page == 1 && category == null && location == null && search == null;
    
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
      final response = await http.get(uri).timeout(_timeout);
      _logTiming('سرور job-ads', stopwatch.elapsedMilliseconds);
      
      // پارس JSON در background برای جلوگیری از هنگ UI
      final data = await BackgroundProcessor.parseJson(response.body);
      _logTiming('پارس job-ads', stopwatch.elapsedMilliseconds);
      
      if (data['success'] == true) {
        final list = data['data'] as List;
        // کش کردن نتایج (بدون await برای سرعت بیشتر)
        if (canUseCache) {
          CacheService.cacheJobAds(List<Map<String, dynamic>>.from(list));
        }
        // تبدیل به مدل در background
        return await compute(_parseJobAds, list);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching job ads: $e');
      // در صورت خطا، از کش استفاده کن
      if (canUseCache) {
        final cached = await CacheService.getJobAds();
        if (cached != null) {
          debugPrint('📦 Using cached job ads');
          onServerUnavailable?.call('نمایش از حافظه موقت');
          return await compute(_parseJobAds, cached);
        }
      }
      onServerUnavailable?.call(_getUserFriendlyError(e));
      return [];
    }
  }

  static List<JobAd> _parseJobAds(List<dynamic> list) {
    return list.map((json) => JobAd.fromJson(json)).toList();
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
      debugPrint('📝 ارسال آگهی: $adData');
      debugPrint('🔑 توکن: $_token');
      final response = await http.post(
        Uri.parse('$baseUrl/job-ads'),
        headers: _headers,
        body: jsonEncode(adData),
      );
      debugPrint('📥 پاسخ: ${response.body}');
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      debugPrint('❌ خطا در ارسال آگهی: $e');
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

  static Future<bool> updateJobAd(String id, Map<String, dynamic> adData) async {
    await _loadToken();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/job-ads/$id'),
        headers: _headers,
        body: jsonEncode(adData),
      );
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      debugPrint('❌ Error updating job ad: $e');
      return false;
    }
  }

  // ==================== Job Seekers ====================
  
  static Future<List<JobSeeker>> getJobSeekers({
    String? location,
    int? maxSalary,
    String? search,
    int page = 1,
    bool useCache = true,
  }) async {
    final canUseCache = useCache && page == 1 && location == null && search == null;
    
    try {
      final params = <String, String>{
        'page': page.toString(),
        if (location != null) 'location': location,
        if (maxSalary != null) 'maxSalary': maxSalary.toString(),
        if (search != null) 'search': search,
      };
      
      final uri = Uri.parse('$baseUrl/job-seekers').replace(queryParameters: params);
      final response = await http.get(uri).timeout(_timeout);
      final data = await BackgroundProcessor.parseJson(response.body);
      
      if (data['success'] == true) {
        final list = data['data'] as List;
        if (canUseCache) {
          CacheService.cacheJobSeekers(List<Map<String, dynamic>>.from(list));
        }
        return await compute(_parseJobSeekers, list);
      }
      return [];
    } catch (e) {
      if (canUseCache) {
        final cached = await CacheService.getJobSeekers();
        if (cached != null) {
          debugPrint('📦 Using cached job seekers');
          onServerUnavailable?.call('نمایش از حافظه موقت');
          return await compute(_parseJobSeekers, cached);
        }
      }
      onServerUnavailable?.call(_getUserFriendlyError(e));
      return [];
    }
  }

  static List<JobSeeker> _parseJobSeekers(List<dynamic> list) {
    return list.map((json) => JobSeeker.fromJson(json)).toList();
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

  static Future<List<JobSeeker>> getMyJobSeekers() async {
    await _loadToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/job-seekers/my/list'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        return (data['data'] as List).map((json) => JobSeeker.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> updateJobSeeker(String id, Map<String, dynamic> data) async {
    await _loadToken();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/job-seekers/$id'),
        headers: _headers,
        body: jsonEncode(data),
      );
      final result = jsonDecode(response.body);
      return result['success'] == true;
    } catch (e) {
      debugPrint('❌ Error updating job seeker: $e');
      return false;
    }
  }

  // ==================== Bakery Ads ====================
  
  static Future<List<BakeryAd>> getBakeryAds({
    BakeryAdType? type,
    String? location,
    String? search,
    String? province,
    int? minPrice,
    int? maxPrice,
    int? minFlourQuota,
    int? maxFlourQuota,
    int page = 1,
    bool useCache = true,
  }) async {
    final stopwatch = Stopwatch()..start();
    final canUseCache = useCache && page == 1 && type == null && location == null && search == null && province == null;
    
    // اول از کش بخون (سریع)
    if (canUseCache) {
      final cached = await CacheService.getBakeries();
      if (cached != null && cached.isNotEmpty) {
        _logTiming('کش bakery-ads', stopwatch.elapsedMilliseconds);
        // در background از سرور آپدیت کن
        _refreshBakeriesInBackground();
        return await compute(_parseBakeryAds, cached);
      }
    }
    
    try {
      final params = <String, String>{
        'page': page.toString(),
        if (type != null) 'type': type == BakeryAdType.sale ? 'sale' : 'rent',
        if (location != null) 'location': location,
        if (search != null) 'search': search,
        if (province != null) 'province': province,
        if (minPrice != null) 'minPrice': minPrice.toString(),
        if (maxPrice != null) 'maxPrice': maxPrice.toString(),
        if (minFlourQuota != null) 'minFlourQuota': minFlourQuota.toString(),
        if (maxFlourQuota != null) 'maxFlourQuota': maxFlourQuota.toString(),
      };
      
      final uri = Uri.parse('$baseUrl/bakery-ads').replace(queryParameters: params);
      final response = await http.get(uri).timeout(_timeout);
      _logTiming('سرور bakery-ads', stopwatch.elapsedMilliseconds);
      
      final data = await BackgroundProcessor.parseJson(response.body);
      _logTiming('پارس bakery-ads', stopwatch.elapsedMilliseconds);
      
      if (data['success'] == true) {
        final list = data['data'] as List;
        if (canUseCache) {
          CacheService.cacheBakeries(List<Map<String, dynamic>>.from(list));
        }
        return await compute(_parseBakeryAds, list);
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error fetching bakery ads: $e');
      if (canUseCache) {
        final cached = await CacheService.getBakeries();
        if (cached != null) {
          debugPrint('📦 Using cached bakeries');
          onServerUnavailable?.call('نمایش از حافظه موقت');
          return await compute(_parseBakeryAds, cached);
        }
      }
      onServerUnavailable?.call(_getUserFriendlyError(e));
      return [];
    }
  }

  /// آپدیت نانوایی‌ها در background
  static Future<void> _refreshBakeriesInBackground() async {
    try {
      final uri = Uri.parse('$baseUrl/bakery-ads?page=1');
      final response = await http.get(uri).timeout(_timeout);
      final data = await BackgroundProcessor.parseJson(response.body);
      if (data['success'] == true) {
        CacheService.cacheBakeries(List<Map<String, dynamic>>.from(data['data']));
      }
    } catch (_) {}
  }

  static List<BakeryAd> _parseBakeryAds(List<dynamic> list) {
    return list.map((json) => BakeryAd.fromJson(json)).toList();
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

  static Future<List<BakeryAd>> getMyBakeryAds() async {
    await _loadToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bakery-ads/my/list'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        return (data['data'] as List).map((json) => BakeryAd.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> updateBakeryAd(String id, Map<String, dynamic> adData) async {
    await _loadToken();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/bakery-ads/$id'),
        headers: _headers,
        body: jsonEncode(adData),
      );
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      debugPrint('❌ Error updating bakery ad: $e');
      return false;
    }
  }

  // ==================== Equipment Ads ====================
  
  static Future<List<Map<String, dynamic>>> getEquipmentAds({
    String? condition,
    String? location,
    String? search,
    int page = 1,
    bool useCache = true,
  }) async {
    final stopwatch = Stopwatch()..start();
    final canUseCache = useCache && page == 1 && condition == null && location == null && search == null;
    
    // اول از کش بخون (سریع)
    if (canUseCache) {
      final cached = await CacheService.getEquipment();
      if (cached != null && cached.isNotEmpty) {
        _logTiming('کش equipment-ads', stopwatch.elapsedMilliseconds);
        // در background از سرور آپدیت کن
        _refreshEquipmentInBackground();
        return cached;
      }
    }
    
    try {
      final params = <String, String>{
        'page': page.toString(),
        if (condition != null) 'condition': condition,
        if (location != null) 'location': location,
        if (search != null) 'search': search,
      };
      
      final uri = Uri.parse('$baseUrl/equipment-ads').replace(queryParameters: params);
      final response = await http.get(uri).timeout(_timeout);
      _logTiming('سرور equipment-ads', stopwatch.elapsedMilliseconds);
      
      final data = await BackgroundProcessor.parseJson(response.body);
      _logTiming('پارس equipment-ads', stopwatch.elapsedMilliseconds);
      
      if (data['success'] == true) {
        final list = List<Map<String, dynamic>>.from(data['data']);
        if (canUseCache) {
          CacheService.cacheEquipment(list);
        }
        return list;
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error fetching equipment ads: $e');
      if (canUseCache) {
        final cached = await CacheService.getEquipment();
        if (cached != null) {
          debugPrint('📦 Using cached equipment');
          onServerUnavailable?.call('نمایش از حافظه موقت');
          return cached;
        }
      }
      onServerUnavailable?.call(_getUserFriendlyError(e));
      return [];
    }
  }

  /// آپدیت تجهیزات در background
  static Future<void> _refreshEquipmentInBackground() async {
    try {
      final uri = Uri.parse('$baseUrl/equipment-ads?page=1');
      final response = await http.get(uri).timeout(_timeout);
      final data = await BackgroundProcessor.parseJson(response.body);
      if (data['success'] == true) {
        CacheService.cacheEquipment(List<Map<String, dynamic>>.from(data['data']));
      }
    } catch (_) {}
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

  static Future<List<EquipmentAd>> getMyEquipmentAds() async {
    await _loadToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipment-ads/my/list'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        return (data['data'] as List).map((json) => EquipmentAd.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> updateEquipmentAd(String id, Map<String, dynamic> adData) async {
    await _loadToken();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/equipment-ads/$id'),
        headers: _headers,
        body: jsonEncode(adData),
      );
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      debugPrint('❌ Error updating equipment ad: $e');
      return false;
    }
  }

  // ==================== Upload ====================
  
  /// آپلود عکس با فشرده‌سازی خودکار
  static Future<String?> uploadImage(File file, {bool compress = true}) async {
    await _loadToken();
    try {
      // فشرده‌سازی عکس قبل از آپلود
      File uploadFile = file;
      if (compress && MediaCompressor.needsCompression(file)) {
        debugPrint('🗜️ Compressing image before upload...');
        final compressed = await MediaCompressor.compressImage(file);
        if (compressed != null) {
          uploadFile = compressed;
        }
      }

      debugPrint('📤 Uploading to: $baseUrl/upload/image');
      
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload/image'));
      request.headers['Authorization'] = 'Bearer $_token';
      
      String ext = uploadFile.path.split('.').last.toLowerCase();
      String mimeType = 'image/jpeg';
      if (ext == 'png') {
        mimeType = 'image/png';
      } else if (ext == 'gif') {
        mimeType = 'image/gif';
      } else if (ext == 'webp') {
        mimeType = 'image/webp';
      }
      
      request.files.add(await http.MultipartFile.fromPath(
        'image', 
        uploadFile.path,
        contentType: MediaType.parse(mimeType),
      ));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('📥 Upload response: ${response.body}');
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        return data['data']['url'];
      }
      debugPrint('❌ Upload failed: ${data['message']}');
      return null;
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      return null;
    }
  }

  /// آپلود چند عکس با فشرده‌سازی خودکار
  static Future<List<String>> uploadImages(List<File> files, {bool compress = true}) async {
    await _loadToken();
    try {
      // فشرده‌سازی عکس‌ها
      List<File> uploadFiles = files;
      if (compress) {
        debugPrint('🗜️ Compressing ${files.length} images...');
        uploadFiles = await MediaCompressor.compressImages(files);
      }

      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload/images'));
      request.headers['Authorization'] = 'Bearer $_token';
      
      for (var file in uploadFiles) {
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
      debugPrint('❌ Upload images error: $e');
      return [];
    }
  }

  /// آپلود ویدیو با فشرده‌سازی خودکار
  static Future<String?> uploadVideo(
    File file, {
    bool compress = true,
    void Function(double)? onProgress,
  }) async {
    await _loadToken();
    try {
      File uploadFile = file;
      
      // فشرده‌سازی ویدیو
      if (compress) {
        debugPrint('🗜️ Compressing video...');
        final compressed = await MediaCompressor.compressVideo(
          file,
          onProgress: onProgress,
        );
        if (compressed != null) {
          uploadFile = compressed;
        }
      }

      debugPrint('📤 Uploading video: ${MediaCompressor.getFileSize(uploadFile)}');
      
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload/video'));
      request.headers['Authorization'] = 'Bearer $_token';
      
      request.files.add(await http.MultipartFile.fromPath(
        'video', 
        uploadFile.path,
        contentType: MediaType.parse('video/mp4'),
      ));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('📥 Video upload response: ${response.body}');
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        return data['data']['url'];
      }
      debugPrint('❌ Video upload failed: ${data['message']}');
      return null;
    } catch (e) {
      debugPrint('❌ Video upload error: $e');
      return null;
    }
  }

  // ==================== Notifications ====================
  
  static Future<Map<String, dynamic>> getNotifications({int page = 1, int limit = 20}) async {
    await _loadToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications?page=$page&limit=$limit'),
        headers: _headers,
      ).timeout(_timeout);
      // پارس JSON در background
      final data = await BackgroundProcessor.parseJson(response.body);
      
      if (data['success'] == true) {
        return {
          'success': true,
          'data': data['data'] ?? [],
          'total': data['total'] ?? 0,
          'unreadCount': data['unreadCount'] ?? 0,
        };
      }
      return {'success': false, 'data': [], 'unreadCount': 0};
    } catch (e) {
      debugPrint('❌ Error getting notifications: $e');
      return {'success': false, 'data': [], 'unreadCount': 0};
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

  static Future<bool> markNotificationAsRead(String id) async {
    await _loadToken();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/$id/read'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
      return false;
    }
  }

  static Future<bool> markAllNotificationsAsRead() async {
    await _loadToken();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/read-all'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      debugPrint('❌ Error marking all notifications as read: $e');
      return false;
    }
  }

  static Future<bool> deleteNotification(String id) async {
    await _loadToken();
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/notifications/$id'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      debugPrint('❌ Error deleting notification: $e');
      return false;
    }
  }

  static Future<bool> deleteAllNotifications() async {
    await _loadToken();
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/notifications'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      debugPrint('❌ Error deleting all notifications: $e');
      return false;
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
      ).timeout(_timeout);
      // پارس JSON در background
      final data = await BackgroundProcessor.parseJson(response.body);
      
      if (data['success'] == true) {
        final conversations = List<Map<String, dynamic>>.from(data['data']);
        // کش کردن مکالمات (بدون await)
        CacheService.cacheConversations(conversations);
        return conversations;
      }
      return [];
    } catch (e) {
      debugPrint('❌ Get conversations error: $e');
      // در صورت خطا از کش استفاده کن
      final cached = await CacheService.getConversations();
      if (cached != null) {
        debugPrint('📦 Using cached conversations');
        return cached;
      }
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getMessages(int recipientId, {int page = 1, int limit = 50}) async {
    await _loadToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/messages/$recipientId?page=$page&limit=$limit'),
        headers: _headers,
      ).timeout(_timeout);
      // پارس JSON در background
      final data = await BackgroundProcessor.parseJson(response.body);
      
      if (data['success'] == true) {
        var messages = List<Map<String, dynamic>>.from(data['data']);
        
        // رمزگشایی پیام‌ها در Isolate (بدون بلاک کردن UI)
        messages = await EncryptionService.decryptMessagesInBackground(messages, recipientId);
        
        // کش کردن پیام‌ها فقط برای صفحه اول (بدون await)
        if (page == 1) {
          CacheService.cacheChatMessages(recipientId, messages);
        }
        
        return messages;
      }
      return [];
    } catch (e) {
      debugPrint('❌ Get messages error: $e');
      if (page == 1) {
        final cached = await CacheService.getChatMessages(recipientId);
        if (cached != null) return cached;
      }
      return [];
    }
  }

  static Future<bool> sendMessage(int receiverId, String message, {int? replyToId, bool encrypt = true}) async {
    await _loadToken();
    try {
      String finalMessage = message;
      bool isEncrypted = false;
      
      if (encrypt && EncryptionService.myUserId != null) {
        try {
          finalMessage = await EncryptionService.encryptMessage(message, receiverId);
          isEncrypted = true;
          debugPrint('🔐 Message encrypted successfully');
        } catch (e) {
          debugPrint('⚠️ Encryption failed, sending plain: $e');
        }
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/chat/send'),
        headers: _headers,
        body: jsonEncode({
          'receiverId': receiverId,
          'message': finalMessage,
          'isEncrypted': isEncrypted,
          if (replyToId != null) 'replyToId': replyToId,
        }),
      );
      
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      debugPrint('❌ Send message error: $e');
      return false;
    }
  }

  // ارسال فایل در چت
  static Future<Map<String, dynamic>?> sendChatMedia(int receiverId, File file, String messageType, {int? replyToId}) async {
    await _loadToken();
    try {
      debugPrint('📤 sendChatMedia: receiverId=$receiverId, type=$messageType, path=${file.path}');
      
      // چک کردن وجود فایل
      if (!await file.exists()) {
        debugPrint('❌ File does not exist: ${file.path}');
        return null;
      }
      
      final fileSize = await file.length();
      debugPrint('📤 File size: $fileSize bytes');
      
      if (fileSize == 0) {
        debugPrint('❌ File is empty');
        return null;
      }
      
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/chat/send-media'));
      request.headers['Authorization'] = 'Bearer $_token';
      request.fields['receiverId'] = receiverId.toString();
      request.fields['messageType'] = messageType;
      if (replyToId != null) request.fields['replyToId'] = replyToId.toString();
      
      // تعیین Content-Type بر اساس نوع فایل
      String ext = file.path.split('.').last.toLowerCase();
      MediaType? contentType;
      
      if (messageType == 'image') {
        if (ext == 'png') {
          contentType = MediaType('image', 'png');
        } else if (ext == 'gif') {
          contentType = MediaType('image', 'gif');
        } else if (ext == 'webp') {
          contentType = MediaType('image', 'webp');
        } else {
          contentType = MediaType('image', 'jpeg');
        }
      } else if (messageType == 'video') {
        if (ext == 'mov') {
          contentType = MediaType('video', 'quicktime');
        } else if (ext == 'avi') {
          contentType = MediaType('video', 'x-msvideo');
        } else if (ext == 'webm') {
          contentType = MediaType('video', 'webm');
        } else if (ext == '3gp') {
          contentType = MediaType('video', '3gpp');
        } else {
          contentType = MediaType('video', 'mp4');
        }
      } else if (messageType == 'voice') {
        if (ext == 'mp3') {
          contentType = MediaType('audio', 'mpeg');
        } else if (ext == 'wav') {
          contentType = MediaType('audio', 'wav');
        } else if (ext == 'ogg') {
          contentType = MediaType('audio', 'ogg');
        } else if (ext == 'm4a') {
          contentType = MediaType('audio', 'mp4');
        } else if (ext == 'aac') {
          contentType = MediaType('audio', 'aac');
        } else if (ext == 'webm') {
          contentType = MediaType('audio', 'webm');
        } else {
          contentType = MediaType('audio', 'aac');
        }
      }
      
      debugPrint('📤 Content-Type: $contentType, Extension: $ext');
      
      request.files.add(await http.MultipartFile.fromPath(
        'file', 
        file.path,
        contentType: contentType,
      ));
      
      debugPrint('📤 Sending request to: $baseUrl/chat/send-media');
      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('📤 Response status: ${response.statusCode}');
      debugPrint('📤 Response body: ${response.body}');
      
      if (response.statusCode == 500) {
        debugPrint('❌ Server error - check if uploads/chat folder exists on server');
        return null;
      }
      
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        debugPrint('✅ Media sent successfully');
        return data['data'];
      }
      debugPrint('❌ Media send failed: ${data['message']}');
      return null;
    } catch (e) {
      debugPrint('❌ sendChatMedia error: $e');
      return null;
    }
  }

  // وضعیت آنلاین
  static Future<void> setOnline() async {
    await _loadToken();
    try {
      await http.post(Uri.parse('$baseUrl/chat/online'), headers: _headers);
    } catch (_) {}
  }

  static Future<void> setOffline() async {
    await _loadToken();
    try {
      await http.post(Uri.parse('$baseUrl/chat/offline'), headers: _headers);
    } catch (_) {}
  }

  // تایپ کردن
  static Future<void> sendTyping(int receiverId) async {
    await _loadToken();
    try {
      await http.post(Uri.parse('$baseUrl/chat/typing/$receiverId'), headers: _headers);
    } catch (_) {}
  }

  static Future<bool> isTyping(int senderId) async {
    await _loadToken();
    try {
      final response = await http.get(Uri.parse('$baseUrl/chat/typing/$senderId'), headers: _headers);
      final data = jsonDecode(response.body);
      return data['isTyping'] == true;
    } catch (_) {
      return false;
    }
  }

  // بلاک کردن
  static Future<bool> blockUser(int userId) async {
    await _loadToken();
    try {
      final response = await http.post(Uri.parse('$baseUrl/chat/block/$userId'), headers: _headers);
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> unblockUser(int userId) async {
    await _loadToken();
    try {
      final response = await http.delete(Uri.parse('$baseUrl/chat/block/$userId'), headers: _headers);
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isBlocked(int userId) async {
    await _loadToken();
    try {
      final response = await http.get(Uri.parse('$baseUrl/chat/is-blocked/$userId'), headers: _headers);
      final data = jsonDecode(response.body);
      return data['isBlocked'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getChatUser(int userId) async {
    await _loadToken();
    try {
      final response = await http.get(Uri.parse('$baseUrl/chat/user/$userId'), headers: _headers);
      final data = jsonDecode(response.body);
      if (data['success'] == true) return data['data'];
      return null;
    } catch (_) {
      return null;
    }
  }

  // ویرایش پیام
  static Future<bool> editMessage(int messageId, String newMessage, {int? recipientId}) async {
    await _loadToken();
    try {
      // رمزنگاری پیام ویرایش شده
      String finalMessage = newMessage;
      bool isEncrypted = false;
      
      if (recipientId != null) {
        try {
          finalMessage = await EncryptionService.encryptMessage(newMessage, recipientId);
          isEncrypted = true;
        } catch (e) {
          debugPrint('⚠️ Encryption failed for edit, sending plain: $e');
        }
      }
      
      final response = await http.put(
        Uri.parse('$baseUrl/chat/message/$messageId'),
        headers: _headers,
        body: jsonEncode({
          'message': finalMessage,
          'isEncrypted': isEncrypted,
        }),
      );
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      debugPrint('❌ Error editing message: $e');
      return false;
    }
  }

  // حذف پیام
  static Future<bool> deleteMessage(int messageId) async {
    await _loadToken();
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/chat/message/$messageId'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      debugPrint('❌ Error deleting message: $e');
      return false;
    }
  }

  // علامت‌گذاری پیام به عنوان تحویل داده شده
  static Future<bool> markMessageDelivered(int messageId) async {
    await _loadToken();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/chat/delivered/$messageId'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  // علامت‌گذاری پیام به عنوان خوانده شده
  static Future<bool> markMessageRead(int messageId) async {
    await _loadToken();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/chat/read/$messageId'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  // ==================== Helper ====================
  
  // ==================== Delete Ads ====================
  
  static Future<bool> deleteAd(String type, String id) async {
    await _loadToken();
    try {
      String endpoint;
      switch (type) {
        case 'job-ad':
          endpoint = 'job-ads';
          break;
        case 'job-seeker':
          endpoint = 'job-seekers';
          break;
        case 'bakery-ad':
          endpoint = 'bakery-ads';
          break;
        case 'equipment-ad':
          endpoint = 'equipment-ads';
          break;
        default:
          return false;
      }
      
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint/$id'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      debugPrint('❌ Error deleting ad: $e');
      return false;
    }
  }

  // ==================== Helper ====================
  
  static Future<bool> checkAuth() async {
    await _loadToken();
    return _token != null;
  }
}
