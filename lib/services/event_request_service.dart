import '../models/event_request_model.dart';
import '../utils/mock_data.dart';

class EventRequestService {
  Future<List<EventRequest>> getMyRequests() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return MockData.eventRequests;
  }

  Future<List<EventRequest>> getAdminRequests({String? status}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (status == null || status == 'all') {
      return MockData.eventRequests;
    }

    return MockData.eventRequests
        .where((request) => request.requestStatus == status)
        .toList();
  }

  Future<String> createEventRequest({
    required String eventTitle,
    required String eventDescription,
    required String venue,
    required String categoryName,
    required String proposedStartDatetime,
    required String proposedEndDatetime,
    required int requestCapacity,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return 'Event request submitted successfully';
  }

  Future<String> approveRequest(int requestID) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return 'Request approved successfully';
  }

  Future<String> rejectRequest(int requestID, String remark) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return 'Request rejected successfully';
  }
}