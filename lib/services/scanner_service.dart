import '../models/ticket_model.dart';
import '../utils/mock_data.dart';

class ScannerService {
  Future<Map<String, dynamic>> checkInByQrCode(String qrCode) async {
    await Future.delayed(const Duration(milliseconds: 500));

    Ticket? ticket;

    try {
      ticket = MockData.tickets.firstWhere(
            (ticket) => ticket.qrCode == qrCode,
      );
    } catch (e) {
      return {
        'success': false,
        'message': 'Invalid QR code.',
      };
    }

    if (ticket.registrationStatus != 'registered') {
      return {
        'success': false,
        'message': 'Registration is not valid.',
      };
    }

    if (MockData.usedQrCodes.contains(qrCode)) {
      return {
        'success': false,
        'message': 'This QR code has already been used.',
      };
    }

    MockData.usedQrCodes.add(qrCode);

    return {
      'success': true,
      'message': 'Check-in successful.',
      'eventTitle': ticket.event.title,
      'venue': ticket.event.venue,
      'userName': 'Amina User',
      'schoolID': 'TP123456',
    };
  }
}