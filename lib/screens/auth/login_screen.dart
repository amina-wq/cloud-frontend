import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../utils/app_routes.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController emailController =
  TextEditingController(text: 'user@mail.com');
  final TextEditingController passwordController =
  TextEditingController(text: '123456');

  bool isLoading = false;

  Future<void> _login(String role) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = await _authService.loginMock(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        role: role,
      );

      if (!mounted) return;

      if (user.role == 'Admin') {
        Navigator.pushReplacementNamed(context, AppRoutes.adminRequests);
      } else if (user.role == 'Scanner') {
        Navigator.pushReplacementNamed(context, AppRoutes.scanner);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.event_available,
                    size: 82,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'University Event Manager',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  const Text(
                    'Login to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 24),

                  AppButton(
                    text: 'Login as User',
                    icon: Icons.person,
                    isLoading: isLoading,
                    onPressed: () => _login('User'),
                  ),
                  const SizedBox(height: 10),

                  AppButton(
                    text: 'Login as Admin',
                    icon: Icons.admin_panel_settings,
                    isOutlined: true,
                    isLoading: isLoading,
                    onPressed: () => _login('Admin'),
                  ),
                  const SizedBox(height: 10),

                  AppButton(
                    text: 'Login as Scanner',
                    icon: Icons.qr_code_scanner,
                    isOutlined: true,
                    isLoading: isLoading,
                    onPressed: () => _login('Scanner'),
                  ),
                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                      Navigator.pushNamed(context, AppRoutes.register);
                    },
                    child: const Text('Create new account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}