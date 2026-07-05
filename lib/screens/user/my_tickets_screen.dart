import 'package:flutter/material.dart';

import '../../models/ticket_model.dart';
import '../../services/ticket_service.dart';
import '../../widgets/ticket_card.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  final TicketService _ticketService = TicketService();

  late Future<List<Ticket>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  void _loadTickets() {
    _ticketsFuture = _ticketService.getMyTickets();
  }

  void _refreshTickets() {
    setState(() {
      _loadTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tickets'),
      ),
      body: FutureBuilder<List<Ticket>>(
        future: _ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load tickets'));
          }

          final tickets = snapshot.data ?? [];

          if (tickets.isEmpty) {
            return const Center(child: Text('No tickets found'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              _refreshTickets();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                return TicketCard(ticket: tickets[index]);
              },
            ),
          );
        },
      ),
    );
  }
}