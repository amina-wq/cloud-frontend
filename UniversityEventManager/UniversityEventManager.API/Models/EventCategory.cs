using System.ComponentModel.DataAnnotations;

namespace UniversityEventManager.API.Models
{
    public class EventCategory
    {
        [Key]
        public long CategoryID { get; set; }

        public string CategoryName { get; set; } = string.Empty;
    }
}