import 'package:flutter/material.dart';

import '../../models/category_model.dart';
import '../../services/event_request_service.dart';
import '../../services/event_service.dart';
import '../../widgets/app_button.dart';

class CreateEventRequestScreen extends StatefulWidget {
  const CreateEventRequestScreen({super.key});

  @override
  State<CreateEventRequestScreen> createState() =>
      _CreateEventRequestScreenState();
}

class _CreateEventRequestScreenState extends State<CreateEventRequestScreen> {
  final EventService _eventService = EventService();
  final EventRequestService _requestService = EventRequestService();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController venueController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();

  DateTime? startDateTime;
  DateTime? endDateTime;
  EventCategory? selectedCategory;

  bool isLoading = false;
  late Future<List<EventCategory>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _eventService.getCategories();
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        startDateTime = selected;
      } else {
        endDateTime = selected;
      }
    });
  }

  Future<void> _submitRequest() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        venueController.text.isEmpty ||
        capacityController.text.isEmpty ||
        selectedCategory == null ||
        startDateTime == null ||
        endDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final message = await _requestService.createEventRequest(
      eventTitle: titleController.text.trim(),
      eventDescription: descriptionController.text.trim(),
      venue: venueController.text.trim(),
      categoryName: selectedCategory!.categoryName,
      proposedStartDatetime: startDateTime!.toIso8601String(),
      proposedEndDatetime: endDateTime!.toIso8601String(),
      requestCapacity: int.tryParse(capacityController.text.trim()) ?? 0,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    venueController.dispose();
    capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event Request'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Event Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Event Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: venueController,
              decoration: const InputDecoration(
                labelText: 'Venue',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            FutureBuilder<List<EventCategory>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                final categories = snapshot.data ?? [];

                return DropdownButtonFormField<EventCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.categoryName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            TextField(
              controller: capacityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Requested Capacity',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDateTime(isStart: true),
                    icon: const Icon(Icons.calendar_month),
                    label: Text(
                      startDateTime == null
                          ? 'Start Date'
                          : startDateTime!.toString().substring(0, 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDateTime(isStart: false),
                    icon: const Icon(Icons.schedule),
                    label: Text(
                      endDateTime == null
                          ? 'End Date'
                          : endDateTime!.toString().substring(0, 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Poster upload will be connected later'),
                  ),
                );
              },
              icon: const Icon(Icons.image),
              label: const Text('Upload Poster'),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'Submit Request',
                icon: Icons.send,
                isLoading: isLoading,
                onPressed: _submitRequest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}