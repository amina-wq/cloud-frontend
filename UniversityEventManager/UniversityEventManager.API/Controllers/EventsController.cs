using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using UniversityEventManager.API.Data;
using UniversityEventManager.API.Models;

namespace UniversityEventManager.API.Controllers
{
    [ApiController]
    [Route("api/events")]
    public class EventsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public EventsController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/events
        [HttpGet]
        public async Task<IActionResult> GetEvents()
        {
            var events = await _context.Events
                .Where(e => e.EventStatus == "upcoming" || e.EventStatus == "active")
                .Select(e => new
                {
                    eventID = e.EventID,
                    title = e.Title,
                    description = e.Description,
                    venue = e.Venue,
                    posterURL = e.PosterURL,
                    startDatetime = e.StartDatetime,
                    endDatetime = e.EndDatetime,
                    capacity = e.Capacity,
                    registeredCount = _context.Registrations.Count(r =>
                        r.EventID == e.EventID &&
                        r.RegistrationStatus == "registered"),
                    availableSeats = e.Capacity -
                        _context.Registrations.Count(r =>
                            r.EventID == e.EventID &&
                            r.RegistrationStatus == "registered"),
                    categoryName = _context.EventCategories
                        .Where(c => c.CategoryID == e.CategoryID)
                        .Select(c => c.CategoryName)
                        .FirstOrDefault(),
                    eventStatus = e.EventStatus,
                    isRegisteredByCurrentUser = false
                })
                .OrderByDescending(e => e.registeredCount)
                .ToListAsync();

            return Ok(events);
        }

        // GET: api/events/1
        [HttpGet("{eventID}")]
        public async Task<IActionResult> GetEventById(long eventID)
        {
            var eventItem = await _context.Events
                .Where(e => e.EventID == eventID)
                .Select(e => new
                {
                    eventID = e.EventID,
                    title = e.Title,
                    description = e.Description,
                    venue = e.Venue,
                    posterURL = e.PosterURL,
                    startDatetime = e.StartDatetime,
                    endDatetime = e.EndDatetime,
                    capacity = e.Capacity,
                    registeredCount = _context.Registrations.Count(r =>
                        r.EventID == e.EventID &&
                        r.RegistrationStatus == "registered"),
                    availableSeats = e.Capacity -
                        _context.Registrations.Count(r =>
                            r.EventID == e.EventID &&
                            r.RegistrationStatus == "registered"),
                    categoryName = _context.EventCategories
                        .Where(c => c.CategoryID == e.CategoryID)
                        .Select(c => c.CategoryName)
                        .FirstOrDefault(),
                    eventStatus = e.EventStatus,
                    isRegisteredByCurrentUser = false
                })
                .FirstOrDefaultAsync();

            if (eventItem == null)
            {
                return NotFound(new
                {
                    message = "Event not found"
                });
            }

            return Ok(eventItem);
        }

        // POST: api/events/1/register
        [Authorize]
        [HttpPost("{eventID}/register")]
        public async Task<IActionResult> RegisterEvent(long eventID)
        {
            var userIdValue = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdValue))
            {
                return Unauthorized(new
                {
                    message = "Invalid token"
                });
            }

            long userId = long.Parse(userIdValue);

            var eventItem = await _context.Events
                .FirstOrDefaultAsync(e => e.EventID == eventID);

            if (eventItem == null)
            {
                return NotFound(new
                {
                    message = "Event not found"
                });
            }

            if (eventItem.EventStatus != "upcoming" &&
                eventItem.EventStatus != "active")
            {
                return BadRequest(new
                {
                    message = "Event is not open for registration"
                });
            }

            bool alreadyRegistered = await _context.Registrations.AnyAsync(r =>
                r.EventID == eventID &&
                r.UserID == userId &&
                r.RegistrationStatus == "registered");

            if (alreadyRegistered)
            {
                return BadRequest(new
                {
                    message = "You have already registered for this event"
                });
            }

            int registeredCount = await _context.Registrations.CountAsync(r =>
                r.EventID == eventID &&
                r.RegistrationStatus == "registered");

            if (registeredCount >= eventItem.Capacity)
            {
                return BadRequest(new
                {
                    message = "Event is full"
                });
            }

            Registration registration = new Registration
            {
                EventID = eventID,
                UserID = userId,
                RegistrationDate = DateTime.Now,
                RegistrationStatus = "registered",
                QrCode = Guid.NewGuid().ToString("N")
            };

            _context.Registrations.Add(registration);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Successfully registered",
                registrationID = registration.RegistrationID,
                qrCode = registration.QrCode
            });
        }
    }
}
