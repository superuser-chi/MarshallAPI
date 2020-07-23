using System;
using System.Collections.Generic;
using System.Text;
using MarshallAPI.Entities;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace MarshallAPI.Data {
    public class MarshallContext : IdentityDbContext {
        public virtual DbSet<User> Users { get; set; }
        public virtual DbSet<Kombi> Kombis { get; set; }
        public virtual DbSet<Day> Days { get; set; }
        public virtual DbSet<Route> Routes { get; set; }
        public virtual DbSet<Slot> Slots { get; set; }
        public MarshallContext (DbContextOptions<MarshallContext> options) : base (options) { }

        protected override void OnModelCreating (ModelBuilder modelBuilder) {
            modelBuilder.Entity<Slot> (entity => {
                base.OnModelCreating (modelBuilder);

                entity.HasKey (e => e.SlotId);

                entity.HasOne (e => e.kombi)
                    .WithMany (k => k.Slots)
                    .HasForeignKey (e => e.KombiId);

                entity.HasOne (e => e.Day)
                    .WithMany (k => k.Slots)
                    .HasForeignKey (e => e.DayId);

                entity.HasOne (e => e.Route)
                    .WithMany (k => k.Slots)
                    .HasForeignKey (e => e.RouteId);
            });
            modelBuilder.Entity<Kombi> (entity => {
                base.OnModelCreating (modelBuilder);

                entity.HasKey (e => e.KombiId);
                entity.Property (e => e.KombiId)
                    .ValueGeneratedOnAdd ();
            });
            modelBuilder.Entity<Day> (entity => {
                base.OnModelCreating (modelBuilder);

                entity.HasKey (e => e.DayId);
                entity.Property (e => e.DayId)
                    .ValueGeneratedOnAdd ();
            });
            modelBuilder.Entity<Route> (entity => {
                base.OnModelCreating (modelBuilder);

                entity.HasKey (e => e.RouteId);
                entity.Property (e => e.RouteId)
                    .ValueGeneratedOnAdd ();
                entity.Property (e => e.From).IsRequired ();
                entity.Property (e => e.To).IsRequired ();
            });
        }
    }
}