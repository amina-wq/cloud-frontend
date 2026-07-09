import 'package:image_picker/image_picker.dart';

import '../models/event_request_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class EventRequestService {
  final AuthService _authService = AuthService();

  Future<List<EventRequest>> getMyRequests() async {
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
    required XFile posterFile,
  }) async {
    final token = await _authService.getToken();
    final posterBytes = await posterFile.readAsBytes();

    final data = await ApiService.postMultipart(
      '/event-requests/with-poster',
      fields: {
        'EventTitle': eventTitle,
        'EventDescription': eventDescription,
        'Venue': venue,
        'CategoryID': categoryID.toString(),
        'ProposedStartDatetime': proposedStartDatetime,
        'ProposedEndDatetime': proposedEndDatetime,
        'RequestCapacity': requestCapacity.toString(),
      },
      fileFieldName: 'PosterFile',
      fileBytes: posterBytes,
      fileName: posterFile.name,
      token: token,
    );

    return EventRequest.fromJson(data);
  }

  Future<EventRequest> approveRequest(int requestID) async {
    final token = await _authService.getToken();

    final data = await ApiService.put(
      '/admin/event-requests/$requestID/approve',
      {},
      token: token,
    );

    return EventRequest.fromJson(data);
  }

  Future<EventRequest> rejectRequest(int requestID, String remark) async {
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
}