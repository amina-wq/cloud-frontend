import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/mock_data.dart';

class AuthService {
  static const String _tokenKey = 'jwt_token';
  static const String _userIDKey = 'user_id';
  static const String _roleKey = 'role';

  Future<AppUser> loginMock({
    required String email,
    required String password,
    required String role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final user = MockData.users.firstWhere(
          (user) => user.role.toLowerCase() == role.toLowerCase(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, 'mock-jwt-token-${user.role}');
    await prefs.setInt(_userIDKey, user.userID);
    await prefs.setString(_roleKey, user.role);

    return user;
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