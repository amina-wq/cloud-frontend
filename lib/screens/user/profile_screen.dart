import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../utils/app_routes.dart';
import '../../utils/mock_data.dart';
import '../../widgets/app_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  late Future<AppUser?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _getCurrentUser();
  }

  Future<AppUser?> _getCurrentUser() async {
    final currentUserID = await _authService.getCurrentUserID();

    if (currentUserID == null) {
      return null;
    }

    final userIndex = MockData.users.indexWhere(
          (user) => user.userID == currentUserID,
    );

    if (userIndex == -1) {
      return null;
    }

    return MockData.users[userIndex];
  }

  Future<void> _logout() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: FutureBuilder<AppUser?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;

          if (user == null) {
            return const Center(
              child: Text('User profile not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 45,
                  child: Icon(Icons.person, size: 48),
                ),
                const SizedBox(height: 16),

                Text(
                  user.fullName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),
                Text(user.email),
                const SizedBox(height: 24),

                _ProfileInfoTile(
                  icon: Icons.badge,
                  title: 'Student ID',
                  value: user.schoolID,
                ),
                _ProfileInfoTile(
                  icon: Icons.business,
                  title: 'University',
                  value: user.organisation,
                ),
                _ProfileInfoTile(
                  icon: Icons.verified_user,
                  title: 'Role',
                  value: user.role,
                ),
                _ProfileInfoTile(
                  icon: Icons.check_circle,
                  title: 'Account Status',
                  value: user.accountStatus,
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    text: 'Logout',
                    icon: Icons.logout,
                    isOutlined: true,
                    onPressed: _logout,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileInfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}