import 'package:flutter/material.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get userName => _currentUser?['name'];
  String? get userPhone => _currentUser?['phone'];

  AuthService() {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    _isLoading = true;
    notifyListeners();

    final user = await ApiService.getCurrentUser();
    if (user != null) {
      _isLoggedIn = true;
      _currentUser = user;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> sendCode(String phone) async {
    _isLoading = true;
    notifyListeners();

    final result = await ApiService.sendVerificationCode(phone);

    _isLoading = false;
    notifyListeners();

    return result;
  }

  Future<Map<String, dynamic>> verifyCode(String phone, String code) async {
    _isLoading = true;
    notifyListeners();

    final result = await ApiService.verifyCode(phone, code);

    if (result['success'] == true) {
      _isLoggedIn = true;
      _currentUser = result['user'];
    }

    _isLoading = false;
    notifyListeners();

    return result;
  }

  Future<void> logout() async {
    await ApiService.logout();
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    final user = await ApiService.getCurrentUser();
    if (user != null) {
      _currentUser = user;
      notifyListeners();
    }
  }
}
