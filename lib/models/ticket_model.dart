import 'event_model.dart';

class Ticket {
  final int registrationID;
  final int? userID;
  final String registrationStatus;
  final String qrCode;
  final Event event;
  final String attendanceStatus;

  Ticket({
    required this.registrationID,
    this.userID,
    required this.registrationStatus,
    required this.qrCode,
    required this.event,
    required this.attendanceStatus,
  });

  Ticket copyWith({
    int? registrationID,
    int? userID,
    String? registrationStatus,
    String? qrCode,
    Event? event,
    String? attendanceStatus,
  }) {
    return Ticket(
      registrationID: registrationID ?? this.registrationID,
      userID: userID ?? this.userID,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      qrCode: qrCode ?? this.qrCode,
      event: event ?? this.event,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
    );
  }

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      registrationID: json['registrationID'],
      userID: json['userID'],
      registrationStatus: json['registrationStatus'],
      qrCode: json['qrCode'],
      event: Event.fromJson(json['event']),
      attendanceStatus: json['attendanceStatus'] ?? 'not_checked_in',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'registrationID': registrationID,
      'userID': userID,
      'registrationStatus': registrationStatus,
      'qrCode': qrCode,
      'event': event.toJson(),
      'attendanceStatus': attendanceStatus,
    };
  }
}