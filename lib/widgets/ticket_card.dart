import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/ticket_model.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;

  const TicketCard({
    super.key,
    required this.ticket,
  });

  Widget _buildPosterThumbnail() {
    if (ticket.event.posterURL.isEmpty) {
      return Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.confirmation_number,
          color: Colors.blue,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        ticket.event.posterURL,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.confirmation_number,
              color: Colors.blue,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPosterPreview() {
    if (ticket.event.posterURL.isEmpty) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        color: Colors.grey.shade100,
        child: Image.network(
          ticket.event.posterURL,
          width: double.infinity,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _showTicketDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildPosterPreview(),
                  const SizedBox(height: 18),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showTicketDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildPosterThumbnail(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(ticket.event.venue),
                    const SizedBox(height: 4),
                    Text(ticket.registrationStatus),
                  ],
                ),
              ),
              const Icon(Icons.qr_code),
            ],
          ),
        ),
      ),
    );
  }
}