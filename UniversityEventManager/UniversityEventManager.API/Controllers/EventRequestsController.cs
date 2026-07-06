using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using UniversityEventManager.API.Data;
using UniversityEventManager.API.Models;

namespace UniversityEventManager.API.Controllers
{
    [ApiController]
    [Route("api/event-requests")]
    [Authorize]
    public class EventRequestsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public EventRequestsController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("my")]
        public async Task<IActionResult> GetMyEventRequests()
        {
            var userIdValue = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdValue))
                return Unauthorized(new { message = "Invalid token" });

            long userId = long.Parse(userIdValue);

            var requests = await _context.EventCreationRequests
                .Where(r => r.SubmittedBy == userId)
                .Select(r => new
                {
                    requestID = r.RequestID,
                    eventTitle = r.EventTitle,
                    eventDescription = r.EventDescription,
                    venue = r.Venue,
                    posterURL = r.PosterURL,
                    categoryName = _context.EventCategories
                        .Where(c => c.CategoryID == r.CategoryID)
                        .Select(c => c.CategoryName)
                        .FirstOrDefault(),
                    proposedStartDatetime = r.ProposedStartDatetime,
                    proposedEndDatetime = r.ProposedEndDatetime,
                    requestCapacity = r.RequestCapacity,
                    requestStatus = r.RequestStatus,
                    submittedAt = r.SubmittedAt,
                    reviewedAt = r.ReviewedAt,
                    remark = r.Remark,
                    submittedByName = _context.Users
                        .Where(u => u.UserID == r.SubmittedBy)
                        .Select(u => u.FullName)
                        .FirstOrDefault()
                })
                .ToListAsync();

            return Ok(requests);
        }

        [HttpPost]
        public async Task<IActionResult> CreateEventRequest(CreateEventRequestDto request)
        {
            var userIdValue = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdValue))
                return Unauthorized(new { message = "Invalid token" });

            long userId = long.Parse(userIdValue);

            if (request.ProposedEndDatetime <= request.ProposedStartDatetime)
                return BadRequest(new { message = "End datetime must be after start datetime" });

            if (request.RequestCapacity <= 0)
                return BadRequest(new { message = "Capacity must be greater than 0" });

            var categoryExists = await _context.EventCategories
                .AnyAsync(c => c.CategoryID == request.CategoryID);

            if (!categoryExists)
                return BadRequest(new { message = "Invalid category" });

            var eventRequest = new EventCreationRequest
            {
                EventTitle = request.EventTitle,
                EventDescription = request.EventDescription,
                Venue = request.Venue,
                CategoryID = request.CategoryID,
                ProposedStartDatetime = request.ProposedStartDatetime,
                ProposedEndDatetime = request.ProposedEndDatetime,
                RequestCapacity = request.RequestCapacity,
                RequestStatus = "pending",
                SubmittedBy = userId,
                SubmittedAt = DateTime.Now,
                ReviewedBy = null,
                ReviewedAt = null,
                Remark = null,
                PosterURL = "",
                PosterS3Key = null
            };

            _context.EventCreationRequests.Add(eventRequest);
            await _context.SaveChangesAsync();

            var categoryName = await _context.EventCategories
                .Where(c => c.CategoryID == eventRequest.CategoryID)
                .Select(c => c.CategoryName)
                .FirstOrDefaultAsync();

            var userName = await _context.Users
                .Where(u => u.UserID == userId)
                .Select(u => u.FullName)
                .FirstOrDefaultAsync();

            return Ok(new
            {
                requestID = eventRequest.RequestID,
                eventTitle = eventRequest.EventTitle,
                eventDescription = eventRequest.EventDescription,
                venue = eventRequest.Venue,
                posterURL = eventRequest.PosterURL,
                categoryName,
                proposedStartDatetime = eventRequest.ProposedStartDatetime,
                proposedEndDatetime = eventRequest.ProposedEndDatetime,
                requestCapacity = eventRequest.RequestCapacity,
                requestStatus = eventRequest.RequestStatus,
                submittedAt = eventRequest.SubmittedAt,
                reviewedAt = eventRequest.ReviewedAt,
                remark = eventRequest.Remark,
                submittedByName = userName
            });
        }
    }

    public class CreateEventRequestDto
    {
        public string EventTitle { get; set; } = string.Empty;
        public string? EventDescription { get; set; }
        public string Venue { get; set; } = string.Empty;
        public long CategoryID { get; set; }
        public DateTime ProposedStartDatetime { get; set; }
        public DateTime ProposedEndDatetime { get; set; }
        public int RequestCapacity { get; set; }
    }
}
