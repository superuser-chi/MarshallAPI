using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.AspNetCore.Identity;

namespace MarshallAPI.Entities {
    [Table ("AspNetUsers")]
    public partial class User : IdentityUser {
        public string RouteId { get; set; }
        public string Firstname { get; set; }
        public string Lastname { get; set; }

        public string Role { get; set; }
        public string Token { get; set; }
    }
}