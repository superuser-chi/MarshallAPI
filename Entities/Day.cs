using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace MarshallAPI.Entities
{
    public class Day
    {
        public string DayId { get; set; }
        [JsonIgnore]
        public ICollection<Slot> Slots { get; set; }
    }
}
