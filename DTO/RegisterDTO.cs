using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MarshallAPI.DTO
{
    public class RegisterDTO
    {
        public string Username { get; set; }
        public string Password { get; set; }
        public string RouteId { get; set; }
        public string PhoneNumber { get; set; }
        public string Firstname { get; set; }
        public string Lastname { get; set; }
    }
}
