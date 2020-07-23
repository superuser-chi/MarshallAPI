using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace MarshallAPI.Entities {
    public class Kombi {
        public string KombiId { get; set; }
        public string Plate { get; set; }
        public string UserId { get; set; }

        [JsonIgnore]
        public User User { get; set; }

        [JsonIgnore]
        public ICollection<Slot> Slots { get; set; }
    }
}