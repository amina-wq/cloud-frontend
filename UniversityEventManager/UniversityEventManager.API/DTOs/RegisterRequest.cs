namespace UniversityEventManager.API.DTOs
{
    public class RegisterRequest
    {
        public string FullName { get; set; } = string.Empty;

        public string SchoolID { get; set; } = string.Empty;

        public string Email { get; set; } = string.Empty;

        public string Password { get; set; } = string.Empty;

        public string? Organisation { get; set; }
    }
}
