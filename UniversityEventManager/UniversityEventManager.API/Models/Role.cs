using System.ComponentModel.DataAnnotations;

namespace UniversityEventManager.API.Models
{
    public class Role
    {
        [Key]
        public int RoleID { get; set; }

        public string RoleName { get; set; } = string.Empty;
    }
}