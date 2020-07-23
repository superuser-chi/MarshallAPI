using System;
using System.Collections.Generic;
using System.Text;
using System.Text.Encodings.Web;
using System.Threading.Tasks;
using MarshallAPI.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.WebUtilities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
namespace MarshallAPI.Data {
    public class SeedData {
        public static async Task Initialize (IServiceProvider serviceProvider, string testUserPw) {
            using (var context = new MarshallContext (
                serviceProvider.GetRequiredService<DbContextOptions<MarshallContext>> ())) {
                await SeedUsers (serviceProvider, testUserPw);
                await SeedRoutes (serviceProvider);
                await SeedRoles (serviceProvider);
            }
        }
        public static async Task SeedUsers (IServiceProvider serviceProvider, string password) {
            var userManager = serviceProvider.GetRequiredService<UserManager<User>> ();
            if (userManager == null) {
                throw new Exception ("User manager has not been registered");
            }
            User user = new User {
                UserName = "sysadmin",
                Firstname = "Gift",
                Lastname = "Mavuso",
                Email = "Slygazi@gmail.com",
                PhoneNumber = "76720635",
                Role = Role.Admin,
                RouteId = "None"
            };
            await userManager.CreateAsync (user, password);
        }
        public static async Task SeedRoles (IServiceProvider serviceProvider) {
            await AddRole (serviceProvider, Role.Admin);
            await AddRole (serviceProvider, Role.Marshal);
            await AddRole (serviceProvider, Role.Driver);
        }
        public static async Task SeedRoutes (IServiceProvider serviceProvider) {
            var context = serviceProvider.GetRequiredService<MarshallContext> ();
            if (context == null) {
                throw new Exception ("Database context has not been injected");
            }
            List<Route> routes = new List<Route> ();
            routes.AddRange (new [] {
                new Route {
                    From = "Mbabane",
                        To = "Mahwalala",
                },
                new Route {
                    From = "Mbabane",
                        To = "Manzini",
                },
                new Route {
                    From = "Mbabane",
                        To = "Nhlangano",
                },
                new Route {
                    From = "Mbabane",
                        To = "Mhlambanyatsi",
                },
                new Route {
                    From = "Mbabane",
                        To = "Zone 4",
                },
                new Route {
                    From = "Mbabane",
                        To = "Zone 2",
                },
                new Route {
                    From = "Mbabane",
                        To = "Thembelihle",
                },
                new Route {
                    From = "Mbabane",
                        To = "Pine Valley",
                },
                new Route {
                    From = "Mbabane",
                        To = "Sdvwashini",
                },
            });
            var seed = await context.Routes.AnyAsync ();
            // if there are no routes, assume its a fresh database and seed it with the routes
            if (!seed) {
                context.Routes.AddRange (routes);
                await context.SaveChangesAsync ();
            }
        }
        public static async Task AddRole (IServiceProvider serviceProvider, string role) {
            var roleManager = serviceProvider.GetService<RoleManager<IdentityRole>> ();

            if (roleManager == null) {
                throw new Exception ("roleManager null");
            }

            if (!await roleManager.RoleExistsAsync (role)) {
                await roleManager.CreateAsync (new IdentityRole (role));
            }
        }
    }
}