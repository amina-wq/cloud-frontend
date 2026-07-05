class AppUser {
  final int userID;
  final String fullName;
  final String schoolID;
  final String email;
  final String organisation;
  final String role;
  final String accountStatus;

  AppUser({
    required this.userID,
    required this.fullName,
    required this.schoolID,
    required this.email,
    required this.organisation,
    required this.role,
    required this.accountStatus,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      userID: json['userID'],
      fullName: json['fullName'],
      schoolID: json['schoolID'],
      email: json['email'],
      organisation: json['organisation'],
      role: json['role'],
      accountStatus: json['accountStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'fullName': fullName,
      'schoolID': schoolID,
      'email': email,
      'organisation': organisation,
      'role': role,
      'accountStatus': accountStatus,
    };
  }
}