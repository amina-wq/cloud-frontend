import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../utils/app_routes.dart';
import '../../utils/mock_data.dart';
import '../../widgets/app_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = MockData.users.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
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
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(user.email),
            const SizedBox(height: 24),

            _ProfileInfoTile(
              icon: Icons.badge,
              title: 'Student ID',
              value: user.schoolID,
            ),
            _ProfileInfoTile(
              icon: Icons.business,
              title: 'Organisation',
              value: user.organisation,
            ),
            _ProfileInfoTile(
              icon: Icons.verified_user,
              title: 'Account Status',
              value: user.accountStatus,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'My Tickets',
                icon: Icons.confirmation_number,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.myTickets);
                },
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'Logout',
                icon: Icons.logout,
                isOutlined: true,
                onPressed: () => _logout(context),
              ),
            ),
          ],
        ),
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