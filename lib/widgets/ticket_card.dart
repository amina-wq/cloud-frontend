import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/ticket_model.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;

  const TicketCard({
    super.key,
    required this.ticket,
  });

  void _showTicketDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ticket.event.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(ticket.event.venue),
              const SizedBox(height: 4),
              Text(ticket.event.startDatetime),
              const SizedBox(height: 24),

              QrImageView(
                data: ticket.qrCode,
                version: QrVersions.auto,
                size: 220,
              ),

              const SizedBox(height: 16),
              Text(
                'QR Code: ${ticket.qrCode}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),

              Text(
                'Attendance: ${ticket.attendanceStatus}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.confirmation_number, color: Colors.blue),
        ),
        title: Text(
          ticket.event.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${ticket.event.venue}\n${ticket.registrationStatus}',
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.qr_code),
        onTap: () => _showTicketDetails(context),
      ),
    );
  }
}