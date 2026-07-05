class CheckInResult {
  final bool success;
  final String message;
  final String? eventTitle;
  final String? venue;
  final String? userName;
  final String? studentID;
  final String? attendanceStatus;
  final String? checkInDatetime;

  CheckInResult({
    required this.success,
    required this.message,
    this.eventTitle,
    this.venue,
    this.userName,
    this.studentID,
    this.attendanceStatus,
    this.checkInDatetime,
  });

  factory CheckInResult.fromJson(Map<String, dynamic> json) {
    return CheckInResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      eventTitle: json['eventTitle'],
      venue: json['venue'],
      userName: json['userName'],
      studentID: json['studentID'],
      attendanceStatus: json['attendanceStatus'],
      checkInDatetime: json['checkInDatetime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'eventTitle': eventTitle,
      'venue': venue,
      'userName': userName,
      'studentID': studentID,
      'attendanceStatus': attendanceStatus,
      'checkInDatetime': checkInDatetime,
    };
  }
}