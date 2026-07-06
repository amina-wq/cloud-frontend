using System.ComponentModel.DataAnnotations;

namespace UniversityEventManager.API.Models
{
    public class Attendance
    {
        [Key]
        public long AttendanceID { get; set; }

        public long RegistrationID { get; set; }
        public long CheckedBy { get; set; }

        public DateTime CheckInDatetime { get; set; }
        public string AttendanceStatus { get; set; } = "checked_in";
    }
}