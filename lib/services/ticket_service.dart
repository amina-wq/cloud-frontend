import '../models/ticket_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class TicketService {
  final AuthService _authService = AuthService();

  Future<List<Ticket>> getMyTickets() async {
    final token = await _authService.getToken();

    final data = await ApiService.get(
      '/users/me/tickets',
      token: token,
    );

    return (data as List).map((json) => Ticket.fromJson(json)).toList();
  }
}