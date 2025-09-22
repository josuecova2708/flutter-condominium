import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  static const String baseUrl = 'https://backend-condo-production.up.railway.app';
  static const String loginEndpoint = '/api/auth/login/';
  static const String profileEndpoint = '/api/auth/profile/';

  User? _user;
  String? _accessToken;
  String? _refreshToken;
  bool _isLoading = true;

  User? get user => _user;
  String? get accessToken => _accessToken;
  bool get isAuthenticated => _accessToken != null && _user != null;
  bool get isLoading => _isLoading;

  AuthService() {
    _loadStoredTokens();
  }

  Future<void> _loadStoredTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('access_token');
      _refreshToken = prefs.getString('refresh_token');

      if (_accessToken != null) {
        await _loadUserProfile();
      }
    } catch (e) {
      print('Error loading stored tokens: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse('$baseUrl$loginEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _accessToken = data['access'];
        _refreshToken = data['refresh'];
        _user = User.fromJson(data['user']);

        await _storeTokens();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$profileEndpoint'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Profile data received: $data'); // Debug print
        _user = User.fromJson(data);
        print('User propietarioId: ${_user?.propietarioId}'); // Debug print
      } else {
        // Token might be expired, clear stored data
        await logout();
      }
    } catch (e) {
      print('Error loading user profile: $e');
      await logout();
    }
  }

  Future<void> _storeTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_accessToken != null) {
        await prefs.setString('access_token', _accessToken!);
      }
      if (_refreshToken != null) {
        await prefs.setString('refresh_token', _refreshToken!);
      }
    } catch (e) {
      print('Error storing tokens: $e');
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');

      _accessToken = null;
      _refreshToken = null;
      _user = null;

      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  String? getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Credenciales inválidas';
      case 401:
        return 'Usuario o contraseña incorrectos';
      case 500:
        return 'Error del servidor. Intente más tarde';
      default:
        return 'Error de conexión. Verifique su internet';
    }
  }
}