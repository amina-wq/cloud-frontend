import '../models/category_model.dart';
import '../models/event_model.dart';
import '../models/ticket_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class EventService {
  final AuthService _authService = AuthService();

  Future<List<Event>> getEvents({
    int? categoryID,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final token = await _authService.getToken();

    final queryParameters = <String, String>{};

    if (categoryID != null) {
      queryParameters['categoryID'] = categoryID.toString();
    }

    if (dateFrom != null) {
      queryParameters['dateFrom'] = dateFrom.toIso8601String();
    }

    if (dateTo != null) {
      queryParameters['dateTo'] = dateTo.toIso8601String();
    }

    final queryString = queryParameters.entries
        .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value)}')
        .join('&');

    final endpoint = queryString.isEmpty ? '/events' : '/events?$queryString';

    final data = await ApiService.get(
      endpoint,
      token: token,
    );

    return (data as List).map((json) => Event.fromJson(json)).toList();
  }

  Future<Event> getEventDetails(int eventID) async {
    final token = await _authService.getToken();

    final data = await ApiService.get(
      '/events/$eventID',
      token: token,
    );

    return Event.fromJson(data);
  }

  Future<List<EventCategory>> getCategories() async {
    final data = await ApiService.get('/categories');

    return (data as List)
        .map((json) => EventCategory.fromJson(json))
        .toList();
  }

  Future<Ticket> registerForEvent(int eventID) async {
    final token = await _authService.getToken();

    final data = await ApiService.post(
      '/events/$eventID/register',
      {},
      token: token,
    );

    return Ticket.fromJson(data);
  }
}