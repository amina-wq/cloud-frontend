import 'package:flutter/material.dart';

import '../../services/scanner_service.dart';
import '../../utils/app_routes.dart';
import '../../widgets/app_button.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ScannerService _scannerService = ScannerService();
  final TextEditingController qrController = TextEditingController(
    text: 'QR-AI-WORKSHOP-USER-1',
  );

  bool isLoading = false;
  Map<String, dynamic>? result;

  Future<void> _checkIn() async {
    if (qrController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or scan QR code')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      result = null;
    });

    final response = await _scannerService.checkInByQrCode(
      qrController.text.trim(),
    );

    setState(() {
      isLoading = false;
      result = response;
    });
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
          (route) => false,
    );
  }

  @override
  void dispose() {
    qrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = result?['success'] == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.qr_code_scanner,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),

            const Text(
              'Scan user QR code to mark attendance',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: qrController,
              decoration: const InputDecoration(
                labelText: 'QR Code',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'Check In',
                icon: Icons.check_circle,
                isLoading: isLoading,
                onPressed: _checkIn,
              ),
            ),
            const SizedBox(height: 24),

            if (result != null)
              Card(
                color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result!['message'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSuccess ? Colors.green : Colors.red,
                        ),
                      ),

                      if (isSuccess) ...[
                        const SizedBox(height: 12),
                        Text('Event: ${result!['eventTitle']}'),
                        Text('Venue: ${result!['venue']}'),
                        Text('User: ${result!['userName']}'),
                        Text('School ID: ${result!['schoolID']}'),
                      ],
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),
            const Text(
              'For testing, use: QR-AI-WORKSHOP-USER-1',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}