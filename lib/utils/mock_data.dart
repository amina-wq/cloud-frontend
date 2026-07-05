import '../models/category_model.dart';
import '../models/event_model.dart';
import '../models/event_request_model.dart';
import '../models/ticket_model.dart';
import '../models/user_model.dart';

class MockData {
  static final List<AppUser> users = [
    AppUser(
      userID: 1,
      fullName: 'Amina User',
      schoolID: 'TP123456',
      email: 'user@mail.com',
      organisation: 'APU',
      role: 'User',
      accountStatus: 'active',
    ),
    AppUser(
      userID: 2,
      fullName: 'Admin Staff',
      schoolID: 'ADM001',
      email: 'admin@mail.com',
      organisation: 'APU',
      role: 'Admin',
      accountStatus: 'active',
    ),
    AppUser(
      userID: 3,
      fullName: 'Scanner Staff',
      schoolID: 'SCN001',
      email: 'scanner@mail.com',
      organisation: 'APU',
      role: 'Scanner',
      accountStatus: 'active',
    ),
  ];

  static final List<EventCategory> categories = [
    EventCategory(categoryID: 1, categoryName: 'Workshop'),
    EventCategory(categoryID: 2, categoryName: 'Career Talk'),
    EventCategory(categoryID: 3, categoryName: 'Entertainment'),
    EventCategory(categoryID: 4, categoryName: 'Sports'),
  ];

  static final List<Event> events = [
    Event(
      eventID: 1,
      title: 'AI Workshop',
      description: 'A practical workshop about artificial intelligence and cloud applications.',
      venue: 'Auditorium 1',
      posterURL: '',
      startDatetime: '2026-07-10T10:00:00',
      endDatetime: '2026-07-10T12:00:00',
      capacity: 150,
      registeredCount: 120,
      availableSeats: 30,
      categoryName: 'Workshop',
      eventStatus: 'upcoming',
      isRegisteredByCurrentUser: true,
    ),
    Event(
      eventID: 2,
      title: 'Career Talk 2026',
      description: 'A career guidance session with industry speakers.',
      venue: 'Hall B',
      posterURL: '',
      startDatetime: '2026-07-15T14:00:00',
      endDatetime: '2026-07-15T16:00:00',
      capacity: 120,
      registeredCount: 95,
      availableSeats: 25,
      categoryName: 'Career Talk',
      eventStatus: 'upcoming',
      isRegisteredByCurrentUser: false,
    ),
    Event(
      eventID: 3,
      title: 'Campus Music Night',
      description: 'An evening event with student performances and music.',
      venue: 'Main Campus',
      posterURL: '',
      startDatetime: '2026-07-20T18:00:00',
      endDatetime: '2026-07-20T21:00:00',
      capacity: 200,
      registeredCount: 70,
      availableSeats: 130,
      categoryName: 'Entertainment',
      eventStatus: 'upcoming',
      isRegisteredByCurrentUser: false,
    ),
  ];

  static final List<EventRequest> eventRequests = [
    EventRequest(
      requestID: 1,
      eventTitle: 'AI Workshop',
      eventDescription: 'A workshop about AI and cloud computing.',
      venue: 'Auditorium 1',
      posterURL: '',
      categoryName: 'Workshop',
      proposedStartDatetime: '2026-07-10T10:00:00',
      proposedEndDatetime: '2026-07-10T12:00:00',
      requestCapacity: 150,
      requestStatus: 'approved',
      submittedAt: '2026-07-01T09:00:00',
      reviewedAt: '2026-07-02T12:00:00',
      remark: 'Approved by admin.',
      submittedByName: 'Amina User',
    ),
    EventRequest(
      requestID: 2,
      eventTitle: 'Startup Sharing Session',
      eventDescription: 'A student sharing session about startup ideas.',
      venue: 'Room B-05',
      posterURL: '',
      categoryName: 'Career Talk',
      proposedStartDatetime: '2026-07-25T11:00:00',
      proposedEndDatetime: '2026-07-25T13:00:00',
      requestCapacity: 80,
      requestStatus: 'pending',
      submittedAt: '2026-07-05T10:30:00',
      reviewedAt: null,
      remark: null,
      submittedByName: 'Amina User',
    ),
    EventRequest(
      requestID: 3,
      eventTitle: 'Gaming Night',
      eventDescription: 'A casual gaming event for students.',
      venue: 'Lab C-01',
      posterURL: '',
      categoryName: 'Entertainment',
      proposedStartDatetime: '2026-07-28T18:00:00',
      proposedEndDatetime: '2026-07-28T21:00:00',
      requestCapacity: 60,
      requestStatus: 'rejected',
      submittedAt: '2026-07-03T14:00:00',
      reviewedAt: '2026-07-04T09:00:00',
      remark: 'Venue is not available.',
      submittedByName: 'Amina User',
    ),
  ];

  static final List<Ticket> tickets = [
    Ticket(
      registrationID: 1,
      registrationStatus: 'registered',
      qrCode: 'QR-AI-WORKSHOP-USER-1',
      event: events[0],
      attendanceStatus: 'not_checked_in',
    ),
  ];

  static final List<String> usedQrCodes = [];
}