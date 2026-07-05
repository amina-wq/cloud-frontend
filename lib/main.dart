import 'package:flutter/material.dart';

import 'screens/admin/admin_requests_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/scanner/scanner_screen.dart';
import 'screens/user/create_event_request_screen.dart';
import 'screens/user/event_requests_screen.dart';
import 'screens/user/home_screen.dart';
import 'screens/user/my_tickets_screen.dart';
import 'screens/user/profile_screen.dart';
import 'utils/app_routes.dart';
import 'utils/constants.dart';

void main() {
  runApp(const EventManagerApp());
}

class EventManagerApp extends StatelessWidget {
  const EventManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      ),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
        AppRoutes.myTickets: (context) => const MyTicketsScreen(),
        AppRoutes.eventRequests: (context) => const EventRequestsScreen(),
        AppRoutes.createEventRequest: (context) =>
        const CreateEventRequestScreen(),
        AppRoutes.adminRequests: (context) => const AdminRequestsScreen(),
        AppRoutes.scanner: (context) => const ScannerScreen(),
      },
    );
  }
}