using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using MarshallAPI.Data;
using MarshallAPI.DTO;
using MarshallAPI.Entities;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace MarshallAPI.Controllers {
    [Route ("api/[controller]")]
    [ApiController]
    public class SlotsController : ControllerBase {
        private readonly MarshallContext _context;
        private readonly IMapper _mapper;

        public SlotsController (MarshallContext context, IMapper mapper) {
            _context = context;
            _mapper = mapper;
        }

        // GET: api/Slots
        [HttpGet]
        public async Task<ActionResult<IEnumerable<SlotDTO>>> GetSlots () {
            var list = await _context.Slots
                .OrderByDescending (i => i.DayId)
                .ThenByDescending (i => i.Time)
                .Include (i => i.kombi.User).ToListAsync ();
            return Ok (_mapper.Map<IEnumerable<SlotDTO>> (list));
        }

        [HttpGet ("Days")]
        public async Task<ActionResult<IEnumerable<Slot>>> GetDays () {
            var today = DateTime.UtcNow.ToString ("yyyy/MM/dd");
            var currDayPresent = await _context.Days
                .AnyAsync (i => i.DateKey == today);
            if (!currDayPresent) {
                _context.Days.Add (new Day {
                    DateKey = today
                });
                try {
                    await _context.SaveChangesAsync ();
                } catch (DbUpdateConcurrencyException) {
                    throw;
                }
            }

            var list = await _context.Days.ToListAsync ();
            return Ok (list);
        }

        // GET: api/Slots/5
        [HttpGet ("{id}")]
        public async Task<ActionResult<Slot>> GetSlot (int id) {
            var slot = await _context.Slots.FindAsync (id);

            if (slot == null) {
                return NotFound ();
            }

            return slot;
        }

        // PUT: api/Slots/5
        // To protect from overposting attacks, enable the specific properties you want to bind to, for
        // more details, see https://go.microsoft.com/fwlink/?linkid=2123754.
        [HttpPut ("{id}")]
        public async Task<IActionResult> PutSlot (int id, Slot slot) {
            if (id != slot.SlotId) {
                return BadRequest ();
            }

            _context.Entry (slot).State = EntityState.Modified;

            try {
                await _context.SaveChangesAsync ();
            } catch (DbUpdateConcurrencyException) {
                if (!SlotExists (id)) {
                    return NotFound ();
                } else {
                    throw;
                }
            }

            return Ok (slot);
        }

        // POST: api/Slots
        // To protect from overposting attacks, enable the specific properties you want to bind to, for
        // more details, see https://go.microsoft.com/fwlink/?linkid=2123754.
        [HttpPost]
        public async Task<ActionResult<Slot>> PostSlot (Slot slot) {
            _context.Slots.Add (slot);
            await _context.SaveChangesAsync ();

            return CreatedAtAction ("GetSlot", new { id = slot.SlotId }, slot);
        }

        // DELETE: api/Slots/5
        [HttpDelete ("{id}")]
        public async Task<ActionResult<Slot>> DeleteSlot (int id) {
            var slot = await _context.Slots.FindAsync (id);
            if (slot == null) {
                return NotFound ();
            }

            _context.Slots.Remove (slot);
            await _context.SaveChangesAsync ();

            return slot;
        }

        [HttpDelete ("Days/{id}")]
        public async Task<ActionResult<Day>> DeleteDay (string id) {
            var day = await _context.Days.FindAsync (id);
            if (day == null) {
                return NotFound ();
            }

            _context.Days.Remove (day);
            await _context.SaveChangesAsync ();

            return day;
        }

        private bool SlotExists (int id) {
            return _context.Slots.Any (e => e.SlotId == id);
        }
        private bool DayExists (String DateKey) {
            return _context.Days.Any (e => e.DateKey == DateKey);
        }
    }
}