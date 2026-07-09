import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController venueController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();

  DateTime? startDateTime;
  DateTime? endDateTime;
  EventCategory? selectedCategory;

  XFile? selectedPoster;
  Uint8List? selectedPosterBytes;

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

  Future<void> _pickPoster() async {
    final pickedPoster = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (pickedPoster == null) return;

    final bytes = await pickedPoster.readAsBytes();

    setState(() {
      selectedPoster = pickedPoster;
      selectedPosterBytes = bytes;
    });
  }

  void _removePoster() {
    setState(() {
      selectedPoster = null;
      selectedPosterBytes = null;
    });
  }

  Future<void> _submitRequest() async {
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        venueController.text.trim().isEmpty ||
        capacityController.text.trim().isEmpty ||
        selectedCategory == null ||
        startDateTime == null ||
        endDateTime == null ||
        selectedPoster == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields and upload a poster'),
        ),
      );
      return;
    }

    final capacity = int.tryParse(capacityController.text.trim());

    if (capacity == null || capacity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Capacity must be greater than 0')),
      );
      return;
    }

    if (endDateTime!.isBefore(startDateTime!) ||
        endDateTime!.isAtSameMomentAs(startDateTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await _requestService.createEventRequest(
        eventTitle: titleController.text.trim(),
        eventDescription: descriptionController.text.trim(),
        venue: venueController.text.trim(),
        categoryID: selectedCategory!.categoryID,
        categoryName: selectedCategory!.categoryName,
        proposedStartDatetime: startDateTime!.toIso8601String(),
        proposedEndDatetime: endDateTime!.toIso8601String(),
        requestCapacity: capacity,
        posterFile: selectedPoster!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event request submitted successfully'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildPosterPicker() {
    if (selectedPosterBytes == null || selectedPoster == null) {
      return OutlinedButton.icon(
        onPressed: isLoading ? null : _pickPoster,
        icon: const Icon(Icons.image),
        label: const Text('Upload Poster'),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.memory(
            selectedPosterBytes!,
            height: 180,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.image, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedPoster!.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: isLoading ? null : _removePoster,
                  icon: const Icon(Icons.close),
                  label: const Text('Remove'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                    return DropdownMenuItem<EventCategory>(
                      value: category,
                      child: Text(category.categoryName),
                    );
                  }).toList(),
                  onChanged: isLoading
                      ? null
                      : (value) {
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
                    onPressed:
                    isLoading ? null : () => _pickDateTime(isStart: true),
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
                    onPressed:
                    isLoading ? null : () => _pickDateTime(isStart: false),
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
            _buildPosterPicker(),
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