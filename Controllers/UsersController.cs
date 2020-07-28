using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MarshallAPI.Data;
using MarshallAPI.DTO;
using MarshallAPI.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace MarshallAPI.Controllers {
    [Route ("api/[controller]")]
    [ApiController]
    public class UsersController : ControllerBase {
        private readonly UserManager<User> userManager;
        private readonly SignInManager<User> signInManager;
        private readonly MarshallContext context;
        public UsersController (MarshallContext _context,
            UserManager<User> _userManager, SignInManager<User> _signInManager) {
            context = _context;
            userManager = _userManager;
            signInManager = _signInManager;
        }
        // GET: api/<UsersController>
        [HttpGet]
        public IActionResult Get () {
            return Ok (userManager.Users.ToList ());
        }

        [HttpGet ("byroute")]
        public IActionResult GetUsersByRoute (string id) {
            return Ok (userManager.Users.Where (u => u.RouteId == id).ToList ());
        }

        // GET api/<UsersController>/5
        [HttpGet ("{id}")]
        public async Task<IActionResult> Get (string id) {
            return Ok (await userManager.FindByIdAsync (id));
        }

        // POST api/<UsersController>
        [HttpPost ("Login")]
        public async Task<IActionResult> Login ([FromBody] LoginDTO dto) {
            var result = await signInManager.PasswordSignInAsync (dto.username, dto.password, false, lockoutOnFailure : false);
            if (result.Succeeded) {
                return Ok (await userManager.FindByNameAsync (dto.username));
            }
            return BadRequest (new { message = "Username or password is incorrect" });
        }

        // POST api/<UsersController>
        [HttpPost ("Register")]
        public async Task<IActionResult> Register ([FromBody] RegisterDTO dto) {
            if (string.IsNullOrEmpty (dto.RouteId) || string.IsNullOrEmpty (dto.Username) ||
                string.IsNullOrEmpty (dto.Password) || string.IsNullOrEmpty (dto.PhoneNumber) ||
                string.IsNullOrEmpty (dto.Firstname) || string.IsNullOrEmpty (dto.Lastname)) {
                return BadRequest (new { message = "None of the fields can be empty" });
            }
            var route = context.Routes.FirstOrDefault (i => i.RouteId == dto.RouteId);
            if (route == null) {
                return BadRequest (new { message = "Cannot register user in non existent route" });
            }
            var user = new User { Firstname = dto.Firstname, Lastname = dto.Lastname, UserName = dto.Username, PhoneNumber = dto.PhoneNumber, RouteId = dto.RouteId };
            var result = await userManager.CreateAsync (user, dto.Password);
            if (result.Succeeded) {
                return Ok (await userManager.FindByNameAsync (dto.Username));
            }
            return BadRequest (new { message = "Could not register user" });
        }

        // PUT api/<UsersController>/5
        [HttpPut ("{id}")]
        public void Put (int id, [FromBody] string value) { }

        // DELETE api/<UsersController>/5
        [HttpDelete ("{id}")]
        public void Delete (int id) { }
    }
}