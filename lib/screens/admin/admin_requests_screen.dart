import 'package:flutter/material.dart';

import '../../models/event_request_model.dart';
import '../../services/auth_service.dart';
import '../../services/event_request_service.dart';
import '../../utils/app_routes.dart';
import '../../widgets/request_card.dart';
import 'admin_request_details_screen.dart';

class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({super.key});

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {
  final AuthService _authService = AuthService();
  final EventRequestService _requestService = EventRequestService();

  String selectedStatus = 'all';
  late Future<List<EventRequest>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() {
    _requestsFuture = _requestService.getAdminRequests(status: selectedStatus);
  }

  void _changeStatus(String status) {
    setState(() {
      selectedStatus = status;
      _loadRequests();
    });
  }

  Future<void> _approveRequest(int requestID) async {
    try {
      await _requestService.approveRequest(requestID);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request approved successfully')),
      );

      setState(() {
        _loadRequests();
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

  Future<void> _rejectRequest(int requestID) async {
    final TextEditingController remarkController = TextEditingController();

    final remark = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject Request'),
          content: TextField(
            controller: remarkController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Remark',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, remarkController.text.trim());
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );

    remarkController.dispose();

    if (remark == null || remark.isEmpty) return;

    try {
      await _requestService.rejectRequest(requestID, remark);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request rejected successfully')),
      );

      setState(() {
        _loadRequests();
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
    final statuses = ['all', 'pending', 'approved', 'rejected'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Requests'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: statuses.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final status = statuses[index];

                return ChoiceChip(
                  label: Text(status.toUpperCase()),
                  selected: selectedStatus == status,
                  onSelected: (_) => _changeStatus(status),
                );
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<EventRequest>>(
              future: _requestsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Failed to load admin requests'),
                  );
                }

                final requests = snapshot.data ?? [];

                if (requests.isEmpty) {
                  return const Center(child: Text('No requests found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];

                    return RequestCard(
                      request: request,
                      showAdminActions: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AdminRequestDetailsScreen(request: request),
                          ),
                        );
                      },
                      onApprove: () => _approveRequest(request.requestID),
                      onReject: () => _rejectRequest(request.requestID),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}