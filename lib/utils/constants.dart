class AppConstants {
  static const String appName = 'University Event Manager';

  // Later we will replace this with deployed ASP.NET backend URL.
  static const String baseUrl = 'http://localhost:5000/api';

  // Our application is only for APU.
  static const String universityName = 'APU';

  // Temporary: true while backend is not ready.
  // Later change to false when real API is connected.
  static const bool useMockData = true;
}