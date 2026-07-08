import '../models/check_in_result_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class ScannerService {
  final AuthService _authService = AuthService();

  Future<CheckInResult> checkInByQrCode(String qrCode) async {
    final token = await _authService.getToken();

    final data = await ApiService.post(
      '/scanner/check-in',
      {
        'qrCode': qrCode,
      },
      token: token,
    );

    return CheckInResult.fromJson(data);
  }
}