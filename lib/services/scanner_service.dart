import '../models/check_in_result_model.dart';
import '../utils/constants.dart';
import '../utils/mock_data.dart';
import 'api_service.dart';
import 'auth_service.dart';

class ScannerService {
  final AuthService _authService = AuthService();

  Future<CheckInResult> checkInByQrCode(String qrCode) async {
    if (AppConstants.useMockData) {
      return _checkInWithMockData(qrCode);
    }

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

  Future<CheckInResult> _checkInWithMockData(String qrCode) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final currentRole = await _authService.getCurrentRole();

    if (currentRole != 'Scanner') {
      return CheckInResult(
        success: false,
        message: 'Only scanner accounts can check in tickets.',
      );
    }

    final ticketIndex = MockData.tickets.indexWhere(
          (ticket) => ticket.qrCode == qrCode,
    );

    if (ticketIndex == -1) {
      return CheckInResult(
        success: false,
        message: 'Invalid QR code.',
      );
    }

    final ticket = MockData.tickets[ticketIndex];

    if (ticket.registrationStatus != 'registered') {
      return CheckInResult(
        success: false,
        message: 'Registration is not valid.',
      );
    }

    if (ticket.attendanceStatus == 'checked_in' ||
        MockData.usedQrCodes.contains(qrCode)) {
      return CheckInResult(
        success: false,
        message: 'This QR code has already been used.',
        eventTitle: ticket.event.title,
        venue: ticket.event.venue,
        attendanceStatus: ticket.attendanceStatus,
      );
    }

    final checkInDatetime = DateTime.now().toIso8601String();

    final updatedTicket = ticket.copyWith(
      attendanceStatus: 'checked_in',
    );

    MockData.tickets[ticketIndex] = updatedTicket;
    MockData.usedQrCodes.add(qrCode);

    String userName = 'Unknown User';
    String studentID = 'Unknown';

    if (ticket.userID != null) {
      final userIndex = MockData.users.indexWhere(
            (user) => user.userID == ticket.userID,
      );

      if (userIndex != -1) {
        userName = MockData.users[userIndex].fullName;
        studentID = MockData.users[userIndex].schoolID;
      }
    }

    return CheckInResult(
      success: true,
      message: 'Check-in successful.',
      eventTitle: ticket.event.title,
      venue: ticket.event.venue,
      userName: userName,
      studentID: studentID,
      attendanceStatus: 'checked_in',
      checkInDatetime: checkInDatetime,
    );
  }
}