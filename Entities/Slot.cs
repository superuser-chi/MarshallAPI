using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace MarshallAPI.Entities {
    public class Slot {
        public int SlotId { get; set; }
        public string KombiId { get; set; }
        public string DayId { get; set; }
        public string RouteId { get; set; }
        public string Time { get; set; }

        [JsonIgnore]
        public Kombi kombi { get; set; }

        [JsonIgnore]
        public Day Day { get; set; }

        [JsonIgnore]
        public Route Route { get; set; }
    }
}