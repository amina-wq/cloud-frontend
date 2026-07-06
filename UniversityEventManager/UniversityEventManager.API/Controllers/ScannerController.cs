using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using UniversityEventManager.API.Data;
using UniversityEventManager.API.Models;

namespace UniversityEventManager.API.Controllers
{
    [ApiController]
    [Route("api/scanner")]
    [Authorize(Roles = "Scanner")]
    public class ScannerController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ScannerController(AppDbContext context)
        {
            _context = context;
        }

        [HttpPost("check-in")]
        public async Task<IActionResult> CheckIn(CheckInRequest request)
        {
            var scannerIdValue = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(scannerIdValue))
                return Unauthorized(new { message = "Invalid token" });

            long scannerId = long.Parse(scannerIdValue);

            var registration = await _context.Registrations
                .FirstOrDefaultAsync(r => r.QrCode == request.QrCode);

            if (registration == null)
            {
                return Ok(new
                {
                    success = false,
                    message = "Invalid QR code."
                });
            }

            if (registration.RegistrationStatus != "registered")
            {
                return Ok(new
                {
                    success = false,
                    message = "This registration is not valid."
                });
            }

            var existingAttendance = await _context.Attendances
                .FirstOrDefaultAsync(a => a.RegistrationID == registration.RegistrationID);

            var eventItem = await _context.Events
                .FirstOrDefaultAsync(e => e.EventID == registration.EventID);

            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.UserID == registration.UserID);

            if (existingAttendance != null)
            {
                return Ok(new
                {
                    success = false,
                    message = "This QR code has already been used.",
                    eventTitle = eventItem?.Title,
                    venue = eventItem?.Venue,
                    attendanceStatus = existingAttendance.AttendanceStatus
                });
            }

            var attendance = new Attendance
            {
                RegistrationID = registration.RegistrationID,
                CheckedBy = scannerId,
                CheckInDatetime = DateTime.Now,
                AttendanceStatus = "checked_in"
            };

            _context.Attendances.Add(attendance);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                success = true,
                message = "Check-in successful.",
                eventTitle = eventItem?.Title,
                venue = eventItem?.Venue,
                userName = user?.FullName,
                studentID = user?.SchoolID,
                attendanceStatus = attendance.AttendanceStatus,
                checkInDatetime = attendance.CheckInDatetime
            });
        }
    }

    public class CheckInRequest
    {
        public string QrCode { get; set; } = string.Empty;
    }
}