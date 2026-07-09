import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../models/check_in_result_model.dart';
import '../../services/auth_service.dart';
import '../../services/scanner_service.dart';
import '../../utils/app_routes.dart';
import '../../widgets/app_button.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final AuthService _authService = AuthService();
  final ScannerService _scannerService = ScannerService();

  final TextEditingController qrController = TextEditingController();
  final MobileScannerController cameraController = MobileScannerController();

  bool isLoading = false;
  bool isCameraPaused = false;
  bool isProcessingScan = false;

  CheckInResult? result;
  String? lastScannedQr;

  Future<void> _handleDetectedBarcode(BarcodeCapture capture) async {
    if (isProcessingScan || isLoading || isCameraPaused) {
      return;
    }

    if (capture.barcodes.isEmpty) {
      return;
    }

    final qrCode = capture.barcodes.first.rawValue;

    if (qrCode == null || qrCode.trim().isEmpty) {
      return;
    }

    setState(() {
      isProcessingScan = true;
      isCameraPaused = true;
      lastScannedQr = qrCode.trim();
      qrController.text = qrCode.trim();
    });

    await cameraController.stop();
    await _checkIn(qrCode.trim());

    if (mounted) {
      setState(() {
        isProcessingScan = false;
      });
    }
  }

  Future<void> _checkIn([String? scannedQrCode]) async {
    final qrCode = scannedQrCode ?? qrController.text.trim();

    if (qrCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please scan or enter QR code')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      result = null;
    });

    try {
      final response = await _scannerService.checkInByQrCode(qrCode);

      if (!mounted) return;

      setState(() {
        result = response;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        result = CheckInResult(
          success: false,
          message: e.toString().replaceAll('Exception: ', ''),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _scanAgain() async {
    setState(() {
      result = null;
      lastScannedQr = null;
      qrController.clear();
      isCameraPaused = false;
      isProcessingScan = false;
    });

    await cameraController.start();
  }

  Future<void> _toggleCameraPause() async {
    if (isCameraPaused) {
      await cameraController.start();
    } else {
      await cameraController.stop();
    }

    if (!mounted) return;

    setState(() {
      isCameraPaused = !isCameraPaused;
    });
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

  Widget _buildScannerArea() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 360,
        width: double.infinity,
        child: Stack(
          children: [
            MobileScanner(
              controller: cameraController,
              onDetect: _handleDetectedBarcode,
            ),
            Center(
              child: Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Point the camera at the ticket QR code',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    if (result == null) {
      return const SizedBox.shrink();
    }

    final isSuccess = result!.success;

    return Card(
      color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result!.message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSuccess ? Colors.green : Colors.red,
              ),
            ),
            if (lastScannedQr != null) ...[
              const SizedBox(height: 12),
              Text('QR Code: $lastScannedQr'),
            ],
            if (result!.eventTitle != null) ...[
              const SizedBox(height: 12),
              Text('Event: ${result!.eventTitle}'),
            ],
            if (result!.venue != null) Text('Venue: ${result!.venue}'),
            if (result!.userName != null) Text('User: ${result!.userName}'),
            if (result!.studentID != null)
              Text('Student ID: ${result!.studentID}'),
            if (result!.attendanceStatus != null)
              Text('Attendance: ${result!.attendanceStatus}'),
            if (result!.checkInDatetime != null)
              Text('Check-in Time: ${result!.checkInDatetime}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'Scan Another Ticket',
                icon: Icons.qr_code_scanner,
                onPressed: _scanAgain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    qrController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        actions: [
          IconButton(
            tooltip: 'Switch Camera',
            onPressed: () => cameraController.switchCamera(),
            icon: const Icon(Icons.cameraswitch),
          ),
          IconButton(
            tooltip: isCameraPaused ? 'Start Camera' : 'Pause Camera',
            onPressed: _toggleCameraPause,
            icon: Icon(isCameraPaused ? Icons.play_arrow : Icons.pause),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildScannerArea(),
            const SizedBox(height: 20),
            TextField(
              controller: qrController,
              decoration: const InputDecoration(
                labelText: 'QR Code',
                helperText: 'Camera scan fills this automatically',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'Manual Check In',
                icon: Icons.check_circle,
                isLoading: isLoading,
                onPressed: () => _checkIn(),
              ),
            ),
            const SizedBox(height: 20),
            _buildResultCard(),
          ],
        ),
      ),
    );
  }
}