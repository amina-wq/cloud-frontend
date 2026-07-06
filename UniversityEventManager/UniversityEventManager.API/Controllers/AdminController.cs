using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using UniversityEventManager.API.Data;
using UniversityEventManager.API.Models;

namespace UniversityEventManager.API.Controllers
{
    [ApiController]
    [Route("api/admin")]
    [Authorize(Roles = "Admin")]
    public class AdminController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AdminController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("event-requests")]
        public async Task<IActionResult> GetAllEventRequests()
        {
            var requests = await _context.EventCreationRequests
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

        [HttpGet("event-requests/{requestID}")]
        public async Task<IActionResult> GetEventRequestById(long requestID)
        {
            var request = await _context.EventCreationRequests
                .Where(r => r.RequestID == requestID)
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
                .FirstOrDefaultAsync();

            if (request == null)
                return NotFound(new { message = "Event request not found" });

            return Ok(request);
        }

        [HttpPut("event-requests/{requestID}/approve")]
        public async Task<IActionResult> ApproveEventRequest(long requestID)
        {
            var adminIdValue = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(adminIdValue))
                return Unauthorized(new { message = "Invalid token" });

            long adminId = long.Parse(adminIdValue);

            var request = await _context.EventCreationRequests
                .FirstOrDefaultAsync(r => r.RequestID == requestID);

            if (request == null)
                return NotFound(new { message = "Event request not found" });

            if (request.RequestStatus != "pending")
                return BadRequest(new { message = "Only pending requests can be approved" });

            var eventAlreadyCreated = await _context.Events
                .AnyAsync(e => e.CreationRequestID == request.RequestID);

            if (eventAlreadyCreated)
                return BadRequest(new { message = "Event already created for this request" });

            request.RequestStatus = "approved";
            request.ReviewedBy = adminId;
            request.ReviewedAt = DateTime.Now;

            var newEvent = new Event
            {
                Title = request.EventTitle,
                Description = request.EventDescription,
                Venue = request.Venue,
                PosterURL = request.PosterURL,
                PosterS3Key = request.PosterS3Key,
                StartDatetime = request.ProposedStartDatetime,
                EndDatetime = request.ProposedEndDatetime,
                Capacity = request.RequestCapacity,
                EventStatus = "upcoming",
                CategoryID = request.CategoryID,
                OrganiserID = request.SubmittedBy,
                ApprovedBy = adminId,
                CreationRequestID = request.RequestID,
                CreatedAt = DateTime.Now
            };

            _context.Events.Add(newEvent);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Event request approved successfully",
                requestID = request.RequestID,
                requestStatus = request.RequestStatus,
                reviewedBy = request.ReviewedBy,
                reviewedAt = request.ReviewedAt
            });
        }

        [HttpPut("event-requests/{requestID}/reject")]
        public async Task<IActionResult> RejectEventRequest(long requestID, RejectEventRequestDto dto)
        {
            var adminIdValue = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(adminIdValue))
                return Unauthorized(new { message = "Invalid token" });

            long adminId = long.Parse(adminIdValue);

            var request = await _context.EventCreationRequests
                .FirstOrDefaultAsync(r => r.RequestID == requestID);

            if (request == null)
                return NotFound(new { message = "Event request not found" });

            if (request.RequestStatus != "pending")
                return BadRequest(new { message = "Only pending requests can be rejected" });

            request.RequestStatus = "rejected";
            request.Remark = dto.Remark;
            request.ReviewedBy = adminId;
            request.ReviewedAt = DateTime.Now;

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Event request rejected successfully",
                requestID = request.RequestID,
                requestStatus = request.RequestStatus,
                remark = request.Remark,
                reviewedBy = request.ReviewedBy,
                reviewedAt = request.ReviewedAt
            });
        }
    }

    public class RejectEventRequestDto
    {
        public string? Remark { get; set; }
    }
}
