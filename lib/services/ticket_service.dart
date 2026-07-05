import '../models/ticket_model.dart';
import '../utils/mock_data.dart';

class TicketService {
  Future<List<Ticket>> getMyTickets() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return MockData.tickets;
  }
}