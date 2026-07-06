using System.ComponentModel.DataAnnotations;

namespace UniversityEventManager.API.Models
{
    public class Event
    {
        [Key]
        public long EventID { get; set; }

        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string Venue { get; set; } = string.Empty;
        public string? PosterURL { get; set; }
        public string? PosterS3Key { get; set; }

        public DateTime StartDatetime { get; set; }
        public DateTime EndDatetime { get; set; }

        public int Capacity { get; set; }
        public string EventStatus { get; set; } = "upcoming";

        public long CategoryID { get; set; }
        public long OrganiserID { get; set; }
        public long ApprovedBy { get; set; }
        public long CreationRequestID { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}