using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations.Schema;

namespace MarshallAPI.Entities
{
    [Table("AspNetUsers")]
    public partial class User : IdentityUser
    {
        public string RouteId { get; set; }
        public string Firstname { get; set; }
        public string Lastname { get; set; }
    }
}
