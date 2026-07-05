import 'event_model.dart';

class Ticket {
  final int registrationID;
  final String registrationStatus;
  final String qrCode;
  final Event event;
  final String attendanceStatus;

  Ticket({
    required this.registrationID,
    required this.registrationStatus,
    required this.qrCode,
    required this.event,
    required this.attendanceStatus,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      registrationID: json['registrationID'],
      registrationStatus: json['registrationStatus'],
      qrCode: json['qrCode'],
      event: Event.fromJson(json['event']),
      attendanceStatus: json['attendanceStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'registrationID': registrationID,
      'registrationStatus': registrationStatus,
      'qrCode': qrCode,
      'event': event.toJson(),
      'attendanceStatus': attendanceStatus,
    };
  }
}