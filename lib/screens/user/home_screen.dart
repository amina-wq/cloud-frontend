import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/category_model.dart';
import '../../models/event_model.dart';
import '../../services/auth_service.dart';
import '../../services/event_service.dart';
import '../../utils/app_routes.dart';
import '../../widgets/event_card.dart';
import 'event_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EventService _eventService = EventService();
  final AuthService _authService = AuthService();

  late Future<List<Event>> _eventsFuture;
  late Future<List<EventCategory>> _categoriesFuture;

  int? selectedCategoryID;
  String? selectedCategoryName;
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _eventService.getCategories();
    _loadEvents();
  }

  void _loadEvents() {
    DateTime? dateFrom;
    DateTime? dateTo;

    if (selectedDateRange != null) {
      dateFrom = DateTime(
        selectedDateRange!.start.year,
        selectedDateRange!.start.month,
        selectedDateRange!.start.day,
      );

      dateTo = DateTime(
        selectedDateRange!.end.year,
        selectedDateRange!.end.month,
        selectedDateRange!.end.day,
        23,
        59,
        59,
      );
    }

    _eventsFuture = _eventService.getEvents(
      categoryID: selectedCategoryID,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }

  void _refreshEvents() {
    setState(() {
      _loadEvents();
    });
  }

  Future<void> _pickDateRange() async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDateRange: selectedDateRange,
    );

    if (pickedRange == null) return;

    setState(() {
      selectedDateRange = pickedRange;
      _loadEvents();
    });
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return FutureBuilder<List<EventCategory>>(
          future: _categoriesFuture,
          builder: (context, snapshot) {
            final categories = snapshot.data ?? [];

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              children: [
                const Text(
                  'Filter by Category',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                ListTile(
                  leading: const Icon(Icons.all_inclusive),
                  title: const Text('All Categories'),
                  trailing: selectedCategoryID == null
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    setState(() {
                      selectedCategoryID = null;
                      selectedCategoryName = null;
                      _loadEvents();
                    });

                    Navigator.pop(context);
                  },
                ),

                ...categories.map((category) {
                  return ListTile(
                    leading: const Icon(Icons.category),
                    title: Text(category.categoryName),
                    trailing: selectedCategoryID == category.categoryID
                        ? const Icon(Icons.check, color: Colors.blue)
                        : null,
                    onTap: () {
                      setState(() {
                        selectedCategoryID = category.categoryID;
                        selectedCategoryName = category.categoryName;
                        _loadEvents();
                      });

                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  void _clearFilters() {
    setState(() {
      selectedCategoryID = null;
      selectedCategoryName = null;
      selectedDateRange = null;
      _loadEvents();
    });
  }

  String _dateRangeText() {
    if (selectedDateRange == null) return 'Date';

    final formatter = DateFormat('dd MMM');

    return '${formatter.format(selectedDateRange!.start)} - ${formatter.format(selectedDateRange!.end)}';
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

  @override
  Widget build(BuildContext context) {
    final hasFilters = selectedCategoryID != null || selectedDateRange != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Events'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDateRange,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(_dateRangeText()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showCategoryFilter,
                    icon: const Icon(Icons.category),
                    label: Text(selectedCategoryName ?? 'Category'),
                  ),
                ),
              ],
            ),
          ),

          if (hasFilters)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      children: [
                        if (selectedCategoryName != null)
                          Chip(
                            label: Text(selectedCategoryName!),
                            onDeleted: () {
                              setState(() {
                                selectedCategoryID = null;
                                selectedCategoryName = null;
                                _loadEvents();
                              });
                            },
                          ),
                        if (selectedDateRange != null)
                          Chip(
                            label: Text(_dateRangeText()),
                            onDeleted: () {
                              setState(() {
                                selectedDateRange = null;
                                _loadEvents();
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),

          Expanded(
            child: FutureBuilder<List<Event>>(
              future: _eventsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load events'));
                }

                final events = snapshot.data ?? [];

                if (events.isEmpty) {
                  return const Center(
                    child: Text('No events found for selected filters'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _refreshEvents();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];

                      return EventCard(
                        event: event,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventDetailsScreen(eventID: event.eventID),
                            ),
                          );

                          _refreshEvents();
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}