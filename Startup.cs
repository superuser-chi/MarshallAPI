using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using MarshallAPI.Data;
using MarshallAPI.Entities;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.DataProtection.AuthenticatedEncryption;
using Microsoft.AspNetCore.DataProtection.AuthenticatedEncryption.ConfigurationModel;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpsPolicy;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace MarshallAPI {
    public class Startup {
        public Startup (IConfiguration configuration) {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices (IServiceCollection services) {
            services.AddDbContext<MarshallContext> (options =>
                options.UseSqlServer (
                    Configuration.GetConnectionString ("WebApiDatabase")), ServiceLifetime.Transient);
            services.AddIdentity<User, IdentityRole> (options => options.SignIn.RequireConfirmedAccount = false)
                .AddEntityFrameworkStores<MarshallContext> ()
                .AddDefaultTokenProviders ();
            services.AddControllers ();
            services.AddSwaggerGen ();
            services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());
            services.AddDataProtection ().PersistKeysToFileSystem (new DirectoryInfo ($"{Directory.GetCurrentDirectory()}/Keys"))
                .UseCryptographicAlgorithms (new AuthenticatedEncryptorConfiguration () {
                    EncryptionAlgorithm = EncryptionAlgorithm.AES_256_CBC,
                        ValidationAlgorithm = ValidationAlgorithm.HMACSHA256
                });
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure (IApplicationBuilder app, IWebHostEnvironment env) {
            if (env.IsDevelopment ()) {
                app.UseDeveloperExceptionPage ();
            }
            app.UseCors (x => x
                .AllowAnyOrigin ()
                .AllowAnyMethod ()
                .AllowAnyHeader ());

            // Enable middleware to serve generated Swagger as a JSON endpoint.
            app.UseSwagger ();

            // Enable middleware to serve swagger-ui (HTML, JS, CSS, etc.),
            // specifying the Swagger JSON endpoint.
            app.UseSwaggerUI (c => {
                c.SwaggerEndpoint ("/swagger/v1/swagger.json", "Marshall API V1");
                c.RoutePrefix = string.Empty;
            });

            app.UseHttpsRedirection ();

            app.UseRouting ();

            app.UseAuthorization ();

            app.UseEndpoints (endpoints => {
                endpoints.MapControllers ();
            });
        }
    }
}