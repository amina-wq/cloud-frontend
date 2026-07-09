import 'package:flutter/material.dart';

import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../widgets/app_button.dart';

class EventDetailsScreen extends StatefulWidget {
  final int eventID;

  const EventDetailsScreen({
    super.key,
    required this.eventID,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final EventService _eventService = EventService();

  late Future<Event> _eventFuture;

  @override
  void initState() {
    super.initState();
    _eventFuture = _eventService.getEventDetails(widget.eventID);
  }

  Future<void> _registerForEvent(Event event) async {
    try {
      final ticket = await _eventService.registerForEvent(event.eventID);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully registered. Ticket QR: ${ticket.qrCode}',
          ),
        ),
      );

      setState(() {
        _eventFuture = _eventService.getEventDetails(widget.eventID);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
        ),
      );
    }
  }

  void _openFullPoster(Event event) {
    if (event.posterURL.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog.fullscreen(
          child: Scaffold(
            appBar: AppBar(
              title: Text(event.title),
              actions: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            body: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: Center(
                child: Image.network(
                  event.posterURL,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('Poster could not be loaded');
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPoster(Event event) {
    if (event.posterURL.isEmpty) {
      return Container(
        height: 260,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.event,
          size: 70,
          color: Colors.blue,
        ),
      );
    }

    return InkWell(
      onTap: () => _openFullPoster(event),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          minHeight: 320,
          maxHeight: 720,
        ),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Image.network(
          event.posterURL,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(
                Icons.event,
                size: 70,
                color: Colors.blue,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Event>(
      future: _eventFuture,
      builder: (context, snapshot) {
        final event = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: Text(event?.title ?? 'Event Details'),
          ),
          body: Builder(
            builder: (context) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || event == null) {
                return const Center(child: Text('Event not found'));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPoster(event),
                    if (event.posterURL.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'Tap poster to view full screen',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.categoryName,
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(event.description),
                    const SizedBox(height: 20),
                    _InfoRow(
                      icon: Icons.location_on,
                      text: event.venue,
                    ),
                    _InfoRow(
                      icon: Icons.calendar_month,
                      text: event.startDatetime,
                    ),
                    _InfoRow(
                      icon: Icons.people,
                      text:
                      '${event.registeredCount} registered • ${event.availableSeats} seats left',
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        text: event.isRegisteredByCurrentUser
                            ? 'Already Registered'
                            : 'Register for Event',
                        icon: event.isRegisteredByCurrentUser
                            ? Icons.check_circle
                            : Icons.app_registration,
                        onPressed: event.isRegisteredByCurrentUser
                            ? null
                            : () => _registerForEvent(event),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}