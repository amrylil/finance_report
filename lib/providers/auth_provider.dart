import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isAuthenticated => _token != null;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final token = await _authService.getToken();
    if (token == null) {
      return false;
    }
    _token = token;
    notifyListeners();
    return true;
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _authService.login(email, password);
      _token = response['access_token'];
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _authService.register(
        name,
        email,
        password,
        passwordConfirmation,
      );
      _token = response['access_token'];
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    if (_token != null) {
      await _authService.logout(_token!);
      _token = null;
      notifyListeners();
    }
  }
}
