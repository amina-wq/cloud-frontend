import '../models/ticket_model.dart';
import '../utils/constants.dart';
import '../utils/mock_data.dart';
import 'api_service.dart';
import 'auth_service.dart';

class TicketService {
  final AuthService _authService = AuthService();

  Future<List<Ticket>> getMyTickets() async {
    if (AppConstants.useMockData) {
      return _getMyTicketsWithMockData();
    }

    final token = await _authService.getToken();

    final data = await ApiService.get(
      '/users/me/tickets',
      token: token,
    );

    return (data as List).map((json) => Ticket.fromJson(json)).toList();
  }

  Future<List<Ticket>> _getMyTicketsWithMockData() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final currentUserID = await _authService.getCurrentUserID();

    if (currentUserID == null) {
      return [];
    }

    return MockData.tickets
        .where((ticket) => ticket.userID == currentUserID)
        .toList();
  }
}