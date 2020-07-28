using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MarshallAPI.Entities;

namespace MarshallAPI.DTO {
    public class KombiDTO : Kombi {
        public string OwnerName { get; set; }
    }
}