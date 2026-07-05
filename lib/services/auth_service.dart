import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/mock_data.dart';
import 'api_service.dart';

class AuthService {
  static const String _tokenKey = 'jwt_token';
  static const String _userIDKey = 'user_id';
  static const String _roleKey = 'role';

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    if (AppConstants.useMockData) {
      return _loginWithMockData(email: email, password: password);
    }

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
    if (AppConstants.useMockData) {
      return _registerWithMockData(
        fullName: fullName,
        studentID: studentID,
        email: email,
        password: password,
      );
    }

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

  Future<AppUser> _loginWithMockData({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (password != '123456') {
      throw Exception('Invalid password');
    }

    final user = MockData.users.firstWhere(
          (user) => user.email.toLowerCase() == email.toLowerCase(),
      orElse: () => throw Exception('User not found'),
    );

    await _saveSession(
      token: 'mock-jwt-token-${user.role}',
      userID: user.userID,
      role: user.role,
    );

    return user;
  }

  Future<AppUser> _registerWithMockData({
    required String fullName,
    required String studentID,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final emailExists = MockData.users.any(
          (user) => user.email.toLowerCase() == email.toLowerCase(),
    );

    if (emailExists) {
      throw Exception('Email already exists');
    }

    final studentIDExists = MockData.users.any(
          (user) => user.schoolID.toUpperCase() == studentID.toUpperCase(),
    );

    if (studentIDExists) {
      throw Exception('Student ID already exists');
    }

    final newUser = AppUser(
      userID: MockData.users.length + 1,
      fullName: fullName,
      schoolID: studentID.toUpperCase(),
      email: email,
      organisation: AppConstants.universityName,
      role: 'User',
      accountStatus: 'active',
    );

    MockData.users.add(newUser);

    return newUser;
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