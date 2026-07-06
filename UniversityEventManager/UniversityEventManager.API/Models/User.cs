using System.ComponentModel.DataAnnotations;

namespace UniversityEventManager.API.Models
{
    public class User
    {
        [Key]
        public long UserID { get; set; }

        public string FullName { get; set; } = string.Empty;
        public string SchoolID { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string PasswordHash { get; set; } = string.Empty;
        public string? Organisation { get; set; }
        public int RoleID { get; set; }
        public string AccountStatus { get; set; } = "active";
        public DateTime CreatedAt { get; set; }
    }
}