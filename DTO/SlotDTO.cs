using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MarshallAPI.Entities;

namespace MarshallAPI.DTO {
    public class SlotDTO : Slot {
        public string OwnerName { get; set; }
        public string KombiPlate { get; set; }
        public string RouteName { get; set; }
    }
}