using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using UniversityEventManager.API.Data;
using UniversityEventManager.API.DTOs;
using UniversityEventManager.API.Models;

namespace UniversityEventManager.API.Controllers
{
    [Route("api/auth")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration;

        public AuthController(AppDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register(RegisterRequest request)
        {
            if (await _context.Users.AnyAsync(u => u.Email == request.Email))
                return BadRequest(new { message = "Email already exists" });

            if (await _context.Users.AnyAsync(u => u.SchoolID == request.SchoolID))
                return BadRequest(new { message = "School ID already exists" });

            if (!request.SchoolID.StartsWith("TP"))
                return BadRequest(new { message = "School ID must start with TP" });

            var userRole = await _context.Roles.FirstOrDefaultAsync(r => r.RoleName == "User");

            if (userRole == null)
                return BadRequest(new { message = "User role not found in database" });

            var user = new User
            {
                FullName = request.FullName,
                SchoolID = request.SchoolID,
                Email = request.Email,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                Organisation = request.Organisation ?? "APU",
                RoleID = userRole.RoleID,
                AccountStatus = "active",
                CreatedAt = DateTime.Now
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Account created successfully",
                user = new
                {
                    userID = user.UserID,
                    fullName = user.FullName,
                    schoolID = user.SchoolID,
                    email = user.Email,
                    organisation = user.Organisation,
                    role = "User",
                    accountStatus = user.AccountStatus
                }
            });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login(LoginRequest request)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == request.Email);

            if (user == null)
                return Unauthorized(new { message = "Invalid email or password" });

            if (!BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
                return Unauthorized(new { message = "Invalid email or password" });

            var role = await _context.Roles.FirstOrDefaultAsync(r => r.RoleID == user.RoleID);

            var token = GenerateJwtToken(user, role?.RoleName ?? "User");

            return Ok(new
            {
                token,
                user = new
                {
                    userID = user.UserID,
                    fullName = user.FullName,
                    schoolID = user.SchoolID,
                    email = user.Email,
                    organisation = user.Organisation,
                    role = role?.RoleName ?? "User",
                    accountStatus = user.AccountStatus
                }
            });
        }

        private string GenerateJwtToken(User user, string roleName)
        {
            var jwtKey = _configuration["Jwt:Key"]!;

            var claims = new[]
            {
                new Claim(ClaimTypes.NameIdentifier, user.UserID.ToString()),
                new Claim(ClaimTypes.Email, user.Email),
                new Claim(ClaimTypes.Role, roleName),
                new Claim("fullName", user.FullName)
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));
            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                claims: claims,
                expires: DateTime.Now.AddDays(7),
                signingCredentials: credentials
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}