import 'package:flutter/material.dart';

import '../../models/event_request_model.dart';
import '../../services/event_request_service.dart';
import '../../utils/app_routes.dart';
import '../../widgets/request_card.dart';

class EventRequestsScreen extends StatefulWidget {
  const EventRequestsScreen({super.key});

  @override
  State<EventRequestsScreen> createState() => _EventRequestsScreenState();
}

class _EventRequestsScreenState extends State<EventRequestsScreen> {
  final EventRequestService _requestService = EventRequestService();

  late Future<List<EventRequest>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _requestsFuture = _requestService.getMyRequests();
  }

  void _refreshRequests() {
    setState(() {
      _requestsFuture = _requestService.getMyRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Event Requests'),
      ),
      body: FutureBuilder<List<EventRequest>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load requests'));
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return const Center(child: Text('No event requests yet'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              _refreshRequests();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];

                return RequestCard(
                  request: request,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.createEventRequest);
          _refreshRequests();
        },
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
      ),
    );
  }
}