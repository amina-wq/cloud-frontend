class Event {
  final int eventID;
  final String title;
  final String description;
  final String venue;
  final String posterURL;
  final String startDatetime;
  final String endDatetime;
  final int capacity;
  final int registeredCount;
  final int availableSeats;
  final String categoryName;
  final String eventStatus;
  final bool isRegisteredByCurrentUser;

  Event({
    required this.eventID,
    required this.title,
    required this.description,
    required this.venue,
    required this.posterURL,
    required this.startDatetime,
    required this.endDatetime,
    required this.capacity,
    required this.registeredCount,
    required this.availableSeats,
    required this.categoryName,
    required this.eventStatus,
    required this.isRegisteredByCurrentUser,
  });

  Event copyWith({
    int? eventID,
    String? title,
    String? description,
    String? venue,
    String? posterURL,
    String? startDatetime,
    String? endDatetime,
    int? capacity,
    int? registeredCount,
    int? availableSeats,
    String? categoryName,
    String? eventStatus,
    bool? isRegisteredByCurrentUser,
  }) {
    return Event(
      eventID: eventID ?? this.eventID,
      title: title ?? this.title,
      description: description ?? this.description,
      venue: venue ?? this.venue,
      posterURL: posterURL ?? this.posterURL,
      startDatetime: startDatetime ?? this.startDatetime,
      endDatetime: endDatetime ?? this.endDatetime,
      capacity: capacity ?? this.capacity,
      registeredCount: registeredCount ?? this.registeredCount,
      availableSeats: availableSeats ?? this.availableSeats,
      categoryName: categoryName ?? this.categoryName,
      eventStatus: eventStatus ?? this.eventStatus,
      isRegisteredByCurrentUser:
      isRegisteredByCurrentUser ?? this.isRegisteredByCurrentUser,
    );
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventID: json['eventID'],
      title: json['title'],
      description: json['description'],
      venue: json['venue'],
      posterURL: json['posterURL'],
      startDatetime: json['startDatetime'],
      endDatetime: json['endDatetime'],
      capacity: json['capacity'],
      registeredCount: json['registeredCount'],
      availableSeats: json['availableSeats'],
      categoryName: json['categoryName'],
      eventStatus: json['eventStatus'],
      isRegisteredByCurrentUser: json['isRegisteredByCurrentUser'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventID': eventID,
      'title': title,
      'description': description,
      'venue': venue,
      'posterURL': posterURL,
      'startDatetime': startDatetime,
      'endDatetime': endDatetime,
      'capacity': capacity,
      'registeredCount': registeredCount,
      'availableSeats': availableSeats,
      'categoryName': categoryName,
      'eventStatus': eventStatus,
      'isRegisteredByCurrentUser': isRegisteredByCurrentUser,
    };
  }
}