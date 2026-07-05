import '../models/category_model.dart';
import '../models/event_model.dart';
import '../utils/mock_data.dart';

class EventService {
  Future<List<Event>> getEvents({
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
        return eventDate.isAfter(dateFrom) || eventDate.isAtSameMomentAs(dateFrom);
      }).toList();
    }

    if (dateTo != null) {
      filteredEvents = filteredEvents.where((event) {
        final eventDate = DateTime.parse(event.startDatetime);
        return eventDate.isBefore(dateTo) || eventDate.isAtSameMomentAs(dateTo);
      }).toList();
    }

    filteredEvents.sort(
          (a, b) => b.registeredCount.compareTo(a.registeredCount),
    );

    return filteredEvents;
  }

  Future<Event> getEventDetails(int eventID) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return MockData.events.firstWhere(
          (event) => event.eventID == eventID,
    );
  }

  Future<List<EventCategory>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.categories;
  }

  Future<String> registerForEvent(int eventID) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final event = MockData.events.firstWhere(
          (event) => event.eventID == eventID,
    );

    return 'Successfully registered for ${event.title}';
  }
}