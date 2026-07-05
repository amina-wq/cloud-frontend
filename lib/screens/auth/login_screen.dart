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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      if (user.role == 'Admin') {
        Navigator.pushReplacementNamed(context, AppRoutes.adminRequests);
      } else if (user.role == 'Scanner') {
        Navigator.pushReplacementNamed(context, AppRoutes.scanner);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.mainUser);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _fillTestAccount(String email) {
    setState(() {
      emailController.text = email;
      passwordController.text = '123456';
    });
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
                    text: 'Login',
                    icon: Icons.login,
                    isLoading: isLoading,
                    onPressed: _login,
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                      Navigator.pushNamed(context, AppRoutes.register);
                    },
                    child: const Text('Create new account'),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),

                  const Text(
                    'Test accounts',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      ActionChip(
                        label: const Text('User'),
                        onPressed: () => _fillTestAccount('user@mail.com'),
                      ),
                      ActionChip(
                        label: const Text('Admin'),
                        onPressed: () => _fillTestAccount('admin@mail.com'),
                      ),
                      ActionChip(
                        label: const Text('Scanner'),
                        onPressed: () => _fillTestAccount('scanner@mail.com'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    'Password for all test accounts: 123456',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
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