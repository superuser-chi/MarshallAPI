using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace MarshallAPI.Entities
{
    public class Route
    {
        public string RouteId { get; set; }
        public string From { get; set; }
        public string To { get; set; }


        public string MarshallId { get; set; }

        [JsonIgnore]
        public ICollection<Slot> Slots { get; set; }
    }
}
