using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using UniversityEventManager.API.Data;

namespace UniversityEventManager.API.Controllers
{
    [ApiController]
    [Route("api/users")]
    public class UsersController : ControllerBase
    {
        private readonly AppDbContext _context;

        public UsersController(AppDbContext context)
        {
            _context = context;
        }

        // ============================
        // GET /api/users/me
        // ============================
        [Authorize]
        [HttpGet("me")]
        public async Task<IActionResult> GetCurrentUser()
        {
            var userIdValue = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdValue))
                return Unauthorized(new { message = "Invalid token" });

            var userId = long.Parse(userIdValue);

            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.UserID == userId);

            if (user == null)
                return NotFound(new { message = "User not found" });

            var role = await _context.Roles
                .FirstOrDefaultAsync(r => r.RoleID == user.RoleID);

            return Ok(new
            {
                userID = user.UserID,
                fullName = user.FullName,
                schoolID = user.SchoolID,
                email = user.Email,
                organisation = user.Organisation,
                role = role?.RoleName ?? "User",
                accountStatus = user.AccountStatus
            });
        }

        // ============================
        // GET /api/users/me/tickets
        // ============================
        [Authorize]
        [HttpGet("me/tickets")]
        public async Task<IActionResult> GetMyTickets()
        {
            var userIdValue = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdValue))
                return Unauthorized(new { message = "Invalid token" });

            var userId = long.Parse(userIdValue);

            var tickets = await _context.Registrations
                .Where(r => r.UserID == userId &&
                            r.RegistrationStatus == "registered")
                .Select(r => new
                {
                    registrationID = r.RegistrationID,
                    eventID = r.EventID,
                    registrationDate = r.RegistrationDate,
                    registrationStatus = r.RegistrationStatus,
                    qrCode = r.QrCode
                })
                .ToListAsync();

            return Ok(tickets);
        }
    }
}