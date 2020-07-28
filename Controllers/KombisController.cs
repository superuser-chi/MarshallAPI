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
    public class KombisController : ControllerBase {
        private readonly MarshallContext _context;
        private readonly IMapper _mapper;

        public KombisController (MarshallContext context, IMapper mapper) {
            _context = context;
            _mapper = mapper;
        }

        // GET: api/Kombis
        [HttpGet]
        public async Task<ActionResult<IEnumerable<KombiDTO>>> GetKombis () {
            var list = await _context.Kombis
                .Include (i => i.User)
                .ToListAsync ();
            return Ok (_mapper.Map<IEnumerable<KombiDTO>> (list));
        }
        // GET: api/Kombis
        [HttpGet ("byroute")]
        public async Task<ActionResult<IEnumerable<KombiDTO>>> GetKombisByRoute (string id) {
            var list = await _context.Kombis
                .Include (i => i.User)
                .Where (k => k.User.RouteId == id)
                .ToListAsync ();
            return Ok (_mapper.Map<IEnumerable<KombiDTO>> (list));
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