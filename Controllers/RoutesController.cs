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
    public class RoutesController : ControllerBase {
        private readonly MarshallContext _context;

        public RoutesController (MarshallContext context) {
            _context = context;
        }

        // GET: api/Routes
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Route>>> GetRoutes () {
            return await _context.Routes.ToListAsync ();
        }

        // GET: api/Routes/5
        [HttpGet ("{id}")]
        public async Task<ActionResult<Route>> GetRoute (string id) {
            var route = await _context.Routes.FindAsync (id);

            if (route == null) {
                return NotFound ();
            }

            return route;
        }

        // PUT: api/Routes/5
        // To protect from overposting attacks, enable the specific properties you want to bind to, for
        // more details, see https://go.microsoft.com/fwlink/?linkid=2123754.
        [HttpPut ("{id}")]
        public async Task<IActionResult> PutRoute (string id, Route route) {
            if (id != route.RouteId) {
                return BadRequest ();
            }

            _context.Entry (route).State = EntityState.Modified;

            try {
                await _context.SaveChangesAsync ();
            } catch (DbUpdateConcurrencyException) {
                if (!RouteExists (id)) {
                    return NotFound ();
                } else {
                    throw;
                }
            }

            return Ok (route);
        }

        // POST: api/Routes
        // To protect from overposting attacks, enable the specific properties you want to bind to, for
        // more details, see https://go.microsoft.com/fwlink/?linkid=2123754.
        [HttpPost]
        public async Task<ActionResult<Route>> PostRoute (Route route) {
            _context.Routes.Add (route);
            await _context.SaveChangesAsync ();

            return CreatedAtAction ("GetRoute", new { id = route.RouteId }, route);
        }

        // DELETE: api/Routes/5
        [HttpDelete ("{id}")]
        public async Task<ActionResult<Route>> DeleteRoute (string id) {
            var route = await _context.Routes.FindAsync (id);
            if (route == null) {
                return NotFound ();
            }

            _context.Routes.Remove (route);
            await _context.SaveChangesAsync ();

            return route;
        }

        private bool RouteExists (string id) {
            return _context.Routes.Any (e => e.RouteId == id);
        }
    }
}