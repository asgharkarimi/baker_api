import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyPhoneNumber = 'phoneNumber';
  static const String _keyUserId = 'userId';

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<void> login(String phoneNumber, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyPhoneNumber, phoneNumber);
    await prefs.setString(_keyUserId, userId);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhoneNumber);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  // شبیه‌سازی ارسال کد تایید
  Future<bool> sendVerificationCode(String phoneNumber) async {
    await Future.delayed(Duration(seconds: 2));
    return true;
  }

  // شبیه‌سازی تایید کد
  Future<bool> verifyCode(String phoneNumber, String code) async {
    await Future.delayed(Duration(seconds: 1));
    // در حالت واقعی باید کد را با سرور چک کنید
    return code == '1234';
  }
}
