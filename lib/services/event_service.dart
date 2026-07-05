import '../models/category_model.dart';
import '../models/event_model.dart';
import '../models/ticket_model.dart';
import '../utils/constants.dart';
import '../utils/mock_data.dart';
import 'api_service.dart';
import 'auth_service.dart';

class EventService {
  final AuthService _authService = AuthService();

  Future<List<Event>> getEvents({
    int? categoryID,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    if (AppConstants.useMockData) {
      return _getEventsWithMockData(
        categoryID: categoryID,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
    }

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
    if (AppConstants.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));

      return MockData.events.firstWhere(
            (event) => event.eventID == eventID,
      );
    }

    final token = await _authService.getToken();

    final data = await ApiService.get(
      '/events/$eventID',
      token: token,
    );

    return Event.fromJson(data);
  }

  Future<List<EventCategory>> getCategories() async {
    if (AppConstants.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockData.categories;
    }

    final data = await ApiService.get('/categories');

    return (data as List)
        .map((json) => EventCategory.fromJson(json))
        .toList();
  }

  Future<Ticket> registerForEvent(int eventID) async {
    if (AppConstants.useMockData) {
      return _registerForEventWithMockData(eventID);
    }

    final token = await _authService.getToken();

    final data = await ApiService.post(
      '/events/$eventID/register',
      {},
      token: token,
    );

    return Ticket.fromJson(data);
  }

  Future<List<Event>> _getEventsWithMockData({
    int? categoryID,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    List<Event> filteredEvents = List.from(MockData.events);

    if (categoryID != null) {
      final selectedCategory = MockData.categories.firstWhere(
            (category) => category.categoryID == categoryID,
      );

      filteredEvents = filteredEvents
          .where((event) => event.categoryName == selectedCategory.categoryName)
          .toList();
    }

    if (dateFrom != null) {
      filteredEvents = filteredEvents.where((event) {
        final eventDate = DateTime.parse(event.startDatetime);

        return eventDate.isAfter(dateFrom) ||
            eventDate.isAtSameMomentAs(dateFrom);
      }).toList();
    }

    if (dateTo != null) {
      filteredEvents = filteredEvents.where((event) {
        final eventDate = DateTime.parse(event.startDatetime);

        return eventDate.isBefore(dateTo) ||
            eventDate.isAtSameMomentAs(dateTo);
      }).toList();
    }

    filteredEvents.sort(
          (a, b) => b.registeredCount.compareTo(a.registeredCount),
    );

    return filteredEvents;
  }

  Future<Ticket> _registerForEventWithMockData(int eventID) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final currentUserID = await _authService.getCurrentUserID();

    if (currentUserID == null) {
      throw Exception('User is not logged in');
    }

    final eventIndex = MockData.events.indexWhere(
          (event) => event.eventID == eventID,
    );

    if (eventIndex == -1) {
      throw Exception('Event not found');
    }

    final event = MockData.events[eventIndex];

    final alreadyHasTicket = MockData.tickets.any(
          (ticket) => ticket.event.eventID == eventID && ticket.userID == currentUserID,
    );

    if (alreadyHasTicket || event.isRegisteredByCurrentUser) {
      final existingTicket = MockData.tickets.firstWhere(
            (ticket) => ticket.event.eventID == eventID && ticket.userID == currentUserID,
        orElse: () => throw Exception('You are already registered'),
      );

      return existingTicket;
    }

    if (event.availableSeats <= 0) {
      throw Exception('Event is fully booked');
    }

    final updatedEvent = event.copyWith(
      isRegisteredByCurrentUser: true,
      registeredCount: event.registeredCount + 1,
      availableSeats: event.availableSeats - 1,
    );

    MockData.events[eventIndex] = updatedEvent;

    final newRegistrationID = MockData.tickets.isEmpty
        ? 1
        : MockData.tickets
        .map((ticket) => ticket.registrationID)
        .reduce((a, b) => a > b ? a : b) +
        1;

    final ticket = Ticket(
      registrationID: newRegistrationID,
      userID: currentUserID,
      registrationStatus: 'registered',
      qrCode: 'QR-EVENT-${event.eventID}-USER-$currentUserID',
      event: updatedEvent,
      attendanceStatus: 'not_checked_in',
    );

    MockData.tickets.add(ticket);

    return ticket;
  }
}