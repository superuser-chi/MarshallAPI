using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MarshallAPI.Data;
using MarshallAPI.Entities;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace MarshallAPI.Controllers {
    [Route ("api/[controller]")]
    [ApiController]
    public class KombisController : ControllerBase {
        private readonly MarshallContext _context;

        public KombisController (MarshallContext context) {
            _context = context;
        }

        // GET: api/Kombis
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Kombi>>> GetKombis () {
            return await _context.Kombis.ToListAsync ();
        }

        // GET: api/Kombis/5
        [HttpGet ("{id}")]
        public async Task<ActionResult<Kombi>> GetKombi (string id) {
            var kombi = await _context.Kombis.FindAsync (id);

            if (kombi == null) {
                return NotFound ();
            }

            return kombi;
        }

        // PUT: api/Kombis/5
        // To protect from overposting attacks, enable the specific properties you want to bind to, for
        // more details, see https://go.microsoft.com/fwlink/?linkid=2123754.
        [HttpPut ("{id}")]
        public async Task<IActionResult> PutKombi (string id, Kombi kombi) {
            if (id != kombi.KombiId) {
                return BadRequest ();
            }

            _context.Entry (kombi).State = EntityState.Modified;

            try {
                await _context.SaveChangesAsync ();
            } catch (DbUpdateConcurrencyException) {
                if (!KombiExists (id)) {
                    return NotFound ();
                } else {
                    throw;
                }
            }

            return Ok (kombi);
        }

        // POST: api/Kombis
        // To protect from overposting attacks, enable the specific properties you want to bind to, for
        // more details, see https://go.microsoft.com/fwlink/?linkid=2123754.
        [HttpPost]
        public async Task<ActionResult<Kombi>> PostKombi (Kombi kombi) {
            _context.Kombis.Add (kombi);
            await _context.SaveChangesAsync ();

            return CreatedAtAction ("GetKombi", new { id = kombi.KombiId }, kombi);
        }

        // DELETE: api/Kombis/5
        [HttpDelete ("{id}")]
        public async Task<ActionResult<Kombi>> DeleteKombi (string id) {
            var kombi = await _context.Kombis.FindAsync (id);
            if (kombi == null) {
                return NotFound ();
            }

            _context.Kombis.Remove (kombi);
            await _context.SaveChangesAsync ();

            return kombi;
        }

        private bool KombiExists (string id) {
            return _context.Kombis.Any (e => e.KombiId == id);
        }
    }
}