import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthService {
  static const String _tokenKey = 'jwt_token';
  static const String _userIDKey = 'user_id';
  static const String _roleKey = 'role';

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final data = await ApiService.post(
      '/auth/login',
      {
        'email': email,
        'password': password,
      },
    );

    final token = data['token'];
    final user = AppUser.fromJson(data['user']);

    await _saveSession(
      token: token,
      userID: user.userID,
      role: user.role,
    );

    return user;
  }

  Future<AppUser> register({
    required String fullName,
    required String studentID,
    required String email,
    required String password,
  }) async {
    final data = await ApiService.post(
      '/auth/register',
      {
        'fullName': fullName,
        'schoolID': studentID,
        'email': email,
        'password': password,
        'organisation': AppConstants.universityName,
      },
    );

    if (data['user'] != null) {
      return AppUser.fromJson(data['user']);
    }

    return AppUser.fromJson(data);
  }

  Future<AppUser?> getCurrentUser() async {
    final token = await getToken();

    if (token == null) {
      return null;
    }

    final data = await ApiService.get(
      '/users/me',
      token: token,
    );

    return AppUser.fromJson(data);
  }

  Future<void> _saveSession({
    required String token,
    required int userID,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_userIDKey, userID);
    await prefs.setString(_roleKey, role);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_userIDKey);
    await prefs.remove(_roleKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<int?> getCurrentUserID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIDKey);
  }

  Future<String?> getCurrentRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}