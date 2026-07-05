import '../models/event_model.dart';
import '../models/event_request_model.dart';
import '../utils/constants.dart';
import '../utils/mock_data.dart';
import 'api_service.dart';
import 'auth_service.dart';

class EventRequestService {
  final AuthService _authService = AuthService();

  Future<List<EventRequest>> getMyRequests() async {
    if (AppConstants.useMockData) {
      return _getMyRequestsWithMockData();
    }

    final token = await _authService.getToken();
    final data = await ApiService.get(
      '/event-requests/my',
      token: token,
    );

    return (data as List)
        .map((json) => EventRequest.fromJson(json))
        .toList();
  }

  Future<List<EventRequest>> getAdminRequests({String? status}) async {
    if (AppConstants.useMockData) {
      return _getAdminRequestsWithMockData(status: status);
    }

    final token = await _authService.getToken();

    final endpoint = status == null || status == 'all'
        ? '/admin/event-requests'
        : '/admin/event-requests?status=$status';

    final data = await ApiService.get(
      endpoint,
      token: token,
    );

    return (data as List)
        .map((json) => EventRequest.fromJson(json))
        .toList();
  }

  Future<EventRequest> createEventRequest({
    required String eventTitle,
    required String eventDescription,
    required String venue,
    required int categoryID,
    required String categoryName,
    required String proposedStartDatetime,
    required String proposedEndDatetime,
    required int requestCapacity,
  }) async {
    if (AppConstants.useMockData) {
      return _createEventRequestWithMockData(
        eventTitle: eventTitle,
        eventDescription: eventDescription,
        venue: venue,
        categoryName: categoryName,
        proposedStartDatetime: proposedStartDatetime,
        proposedEndDatetime: proposedEndDatetime,
        requestCapacity: requestCapacity,
      );
    }

    final token = await _authService.getToken();

    final data = await ApiService.post(
      '/event-requests',
      {
        'eventTitle': eventTitle,
        'eventDescription': eventDescription,
        'venue': venue,
        'categoryID': categoryID,
        'proposedStartDatetime': proposedStartDatetime,
        'proposedEndDatetime': proposedEndDatetime,
        'requestCapacity': requestCapacity,
      },
      token: token,
    );

    return EventRequest.fromJson(data);
  }

  Future<EventRequest> approveRequest(int requestID) async {
    if (AppConstants.useMockData) {
      return _approveRequestWithMockData(requestID);
    }

    final token = await _authService.getToken();

    final data = await ApiService.put(
      '/admin/event-requests/$requestID/approve',
      {},
      token: token,
    );

    return EventRequest.fromJson(data);
  }

  Future<EventRequest> rejectRequest(int requestID, String remark) async {
    if (AppConstants.useMockData) {
      return _rejectRequestWithMockData(requestID, remark);
    }

    final token = await _authService.getToken();

    final data = await ApiService.put(
      '/admin/event-requests/$requestID/reject',
      {
        'remark': remark,
      },
      token: token,
    );

    return EventRequest.fromJson(data);
  }

  Future<List<EventRequest>> _getMyRequestsWithMockData() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final currentUserID = await _authService.getCurrentUserID();

    if (currentUserID == null) {
      return [];
    }

    final currentUser = MockData.users.firstWhere(
          (user) => user.userID == currentUserID,
    );

    return MockData.eventRequests
        .where((request) => request.submittedByName == currentUser.fullName)
        .toList();
  }

  Future<List<EventRequest>> _getAdminRequestsWithMockData({
    String? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (status == null || status == 'all') {
      return MockData.eventRequests;
    }

    return MockData.eventRequests
        .where((request) => request.requestStatus == status)
        .toList();
  }

  Future<EventRequest> _createEventRequestWithMockData({
    required String eventTitle,
    required String eventDescription,
    required String venue,
    required String categoryName,
    required String proposedStartDatetime,
    required String proposedEndDatetime,
    required int requestCapacity,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final currentUserID = await _authService.getCurrentUserID();

    if (currentUserID == null) {
      throw Exception('User is not logged in');
    }

    final currentUser = MockData.users.firstWhere(
          (user) => user.userID == currentUserID,
    );

    final newRequestID = MockData.eventRequests.isEmpty
        ? 1
        : MockData.eventRequests
        .map((request) => request.requestID)
        .reduce((a, b) => a > b ? a : b) +
        1;

    final newRequest = EventRequest(
      requestID: newRequestID,
      eventTitle: eventTitle,
      eventDescription: eventDescription,
      venue: venue,
      posterURL: '',
      categoryName: categoryName,
      proposedStartDatetime: proposedStartDatetime,
      proposedEndDatetime: proposedEndDatetime,
      requestCapacity: requestCapacity,
      requestStatus: 'pending',
      submittedAt: DateTime.now().toIso8601String(),
      reviewedAt: null,
      remark: null,
      submittedByName: currentUser.fullName,
    );

    MockData.eventRequests.add(newRequest);

    return newRequest;
  }

  Future<EventRequest> _approveRequestWithMockData(int requestID) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final requestIndex = MockData.eventRequests.indexWhere(
          (request) => request.requestID == requestID,
    );

    if (requestIndex == -1) {
      throw Exception('Request not found');
    }

    final request = MockData.eventRequests[requestIndex];

    if (request.requestStatus != 'pending') {
      throw Exception('Only pending requests can be approved');
    }

    final updatedRequest = request.copyWith(
      requestStatus: 'approved',
      reviewedAt: DateTime.now().toIso8601String(),
      remark: 'Approved by admin.',
    );

    MockData.eventRequests[requestIndex] = updatedRequest;

    final newEventID = MockData.events.isEmpty
        ? 1
        : MockData.events
        .map((event) => event.eventID)
        .reduce((a, b) => a > b ? a : b) +
        1;

    final approvedEvent = Event(
      eventID: newEventID,
      title: updatedRequest.eventTitle,
      description: updatedRequest.eventDescription,
      venue: updatedRequest.venue,
      posterURL: updatedRequest.posterURL,
      startDatetime: updatedRequest.proposedStartDatetime,
      endDatetime: updatedRequest.proposedEndDatetime,
      capacity: updatedRequest.requestCapacity,
      registeredCount: 0,
      availableSeats: updatedRequest.requestCapacity,
      categoryName: updatedRequest.categoryName,
      eventStatus: 'upcoming',
      isRegisteredByCurrentUser: false,
    );

    MockData.events.add(approvedEvent);

    return updatedRequest;
  }

  Future<EventRequest> _rejectRequestWithMockData(
      int requestID,
      String remark,
      ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final requestIndex = MockData.eventRequests.indexWhere(
          (request) => request.requestID == requestID,
    );

    if (requestIndex == -1) {
      throw Exception('Request not found');
    }

    final request = MockData.eventRequests[requestIndex];

    if (request.requestStatus != 'pending') {
      throw Exception('Only pending requests can be rejected');
    }

    final updatedRequest = request.copyWith(
      requestStatus: 'rejected',
      reviewedAt: DateTime.now().toIso8601String(),
      remark: remark,
    );

    MockData.eventRequests[requestIndex] = updatedRequest;

    return updatedRequest;
  }
}