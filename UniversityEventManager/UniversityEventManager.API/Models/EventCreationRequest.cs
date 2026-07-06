using System.ComponentModel.DataAnnotations;

namespace UniversityEventManager.API.Models
{
    public class EventCreationRequest
    {
        [Key]
        public long RequestID { get; set; }

        public string EventTitle { get; set; } = string.Empty;
        public string? EventDescription { get; set; }
        public string Venue { get; set; } = string.Empty;

        public long CategoryID { get; set; }

        public DateTime ProposedStartDatetime { get; set; }
        public DateTime ProposedEndDatetime { get; set; }

        public int RequestCapacity { get; set; }
        public string RequestStatus { get; set; } = "pending";

        public long SubmittedBy { get; set; }
        public DateTime SubmittedAt { get; set; }

        public long? ReviewedBy { get; set; }
        public DateTime? ReviewedAt { get; set; }

        public string? Remark { get; set; }
        public string? PosterURL { get; set; }
        public string? PosterS3Key { get; set; }
    }
}