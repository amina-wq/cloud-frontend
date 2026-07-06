using System.ComponentModel.DataAnnotations;

namespace UniversityEventManager.API.Models
{
    public class Registration
    {
        [Key]
        public long RegistrationID { get; set; }

        public long EventID { get; set; }
        public long UserID { get; set; }

        public DateTime RegistrationDate { get; set; }
        public string RegistrationStatus { get; set; } = "registered";
        public string QrCode { get; set; } = string.Empty;
    }
}