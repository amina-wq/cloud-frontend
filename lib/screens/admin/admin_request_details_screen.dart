import 'package:flutter/material.dart';

import '../../models/event_request_model.dart';

class AdminRequestDetailsScreen extends StatelessWidget {
  final EventRequest request;

  const AdminRequestDetailsScreen({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 170,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.event_note,
                size: 70,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              request.eventTitle,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              request.requestStatus.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 20),

            _DetailRow(title: 'Submitted By', value: request.submittedByName),
            _DetailRow(title: 'Category', value: request.categoryName),
            _DetailRow(title: 'Venue', value: request.venue),
            _DetailRow(
              title: 'Start Date',
              value: request.proposedStartDatetime,
            ),
            _DetailRow(
              title: 'End Date',
              value: request.proposedEndDatetime,
            ),
            _DetailRow(
              title: 'Capacity',
              value: request.requestCapacity.toString(),
            ),
            _DetailRow(title: 'Submitted At', value: request.submittedAt),

            if (request.reviewedAt != null)
              _DetailRow(title: 'Reviewed At', value: request.reviewedAt!),

            if (request.remark != null && request.remark!.isNotEmpty)
              _DetailRow(title: 'Remark', value: request.remark!),

            const SizedBox(height: 20),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(request.eventDescription),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String title;
  final String value;

  const _DetailRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}