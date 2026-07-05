class EventRequest {
  final int requestID;
  final String eventTitle;
  final String eventDescription;
  final String venue;
  final String posterURL;
  final String categoryName;
  final String proposedStartDatetime;
  final String proposedEndDatetime;
  final int requestCapacity;
  final String requestStatus;
  final String submittedAt;
  final String? reviewedAt;
  final String? remark;
  final String submittedByName;

  EventRequest({
    required this.requestID,
    required this.eventTitle,
    required this.eventDescription,
    required this.venue,
    required this.posterURL,
    required this.categoryName,
    required this.proposedStartDatetime,
    required this.proposedEndDatetime,
    required this.requestCapacity,
    required this.requestStatus,
    required this.submittedAt,
    this.reviewedAt,
    this.remark,
    required this.submittedByName,
  });

  EventRequest copyWith({
    int? requestID,
    String? eventTitle,
    String? eventDescription,
    String? venue,
    String? posterURL,
    String? categoryName,
    String? proposedStartDatetime,
    String? proposedEndDatetime,
    int? requestCapacity,
    String? requestStatus,
    String? submittedAt,
    String? reviewedAt,
    String? remark,
    String? submittedByName,
  }) {
    return EventRequest(
      requestID: requestID ?? this.requestID,
      eventTitle: eventTitle ?? this.eventTitle,
      eventDescription: eventDescription ?? this.eventDescription,
      venue: venue ?? this.venue,
      posterURL: posterURL ?? this.posterURL,
      categoryName: categoryName ?? this.categoryName,
      proposedStartDatetime:
      proposedStartDatetime ?? this.proposedStartDatetime,
      proposedEndDatetime: proposedEndDatetime ?? this.proposedEndDatetime,
      requestCapacity: requestCapacity ?? this.requestCapacity,
      requestStatus: requestStatus ?? this.requestStatus,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      remark: remark ?? this.remark,
      submittedByName: submittedByName ?? this.submittedByName,
    );
  }

  factory EventRequest.fromJson(Map<String, dynamic> json) {
    return EventRequest(
      requestID: json['requestID'],
      eventTitle: json['eventTitle'],
      eventDescription: json['eventDescription'],
      venue: json['venue'],
      posterURL: json['posterURL'] ?? '',
      categoryName: json['categoryName'],
      proposedStartDatetime: json['proposedStartDatetime'],
      proposedEndDatetime: json['proposedEndDatetime'],
      requestCapacity: json['requestCapacity'],
      requestStatus: json['requestStatus'],
      submittedAt: json['submittedAt'],
      reviewedAt: json['reviewedAt'],
      remark: json['remark'],
      submittedByName: json['submittedByName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestID': requestID,
      'eventTitle': eventTitle,
      'eventDescription': eventDescription,
      'venue': venue,
      'posterURL': posterURL,
      'categoryName': categoryName,
      'proposedStartDatetime': proposedStartDatetime,
      'proposedEndDatetime': proposedEndDatetime,
      'requestCapacity': requestCapacity,
      'requestStatus': requestStatus,
      'submittedAt': submittedAt,
      'reviewedAt': reviewedAt,
      'remark': remark,
      'submittedByName': submittedByName,
    };
  }
}