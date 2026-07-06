using Microsoft.EntityFrameworkCore;
using UniversityEventManager.API.Models;

namespace UniversityEventManager.API.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<User> Users => Set<User>();
        public DbSet<Role> Roles => Set<Role>();
        public DbSet<EventCategory> EventCategories => Set<EventCategory>();
        public DbSet<Event> Events => Set<Event>();
        public DbSet<Registration> Registrations => Set<Registration>();
        public DbSet<Attendance> Attendances => Set<Attendance>();
        public DbSet<EventCreationRequest> EventCreationRequests => Set<EventCreationRequest>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // ============================
            // User
            // ============================
            modelBuilder.Entity<User>().ToTable("users").HasKey(x => x.UserID);

            // ============================
            // Role
            // ============================
            modelBuilder.Entity<Role>().ToTable("roles").HasKey(x => x.RoleID);

            // ============================
            // Event Category
            // ============================
            modelBuilder.Entity<EventCategory>().ToTable("event_categories").HasKey(x => x.CategoryID);

            // ============================
            // Registration
            // ============================
            modelBuilder.Entity<Registration>().ToTable("registrations").HasKey(x => x.RegistrationID);

            // ============================
            // Attendance
            // ============================
            modelBuilder.Entity<Attendance>().ToTable("attendance").HasKey(x => x.AttendanceID);

            // ============================
            // Event
            // ============================
            modelBuilder.Entity<Event>(entity =>
            {
                entity.ToTable("events");
                entity.HasKey(e => e.EventID);

                entity.Property(e => e.EventID).HasColumnName("eventID");
                entity.Property(e => e.Title).HasColumnName("title");
                entity.Property(e => e.Description).HasColumnName("description");
                entity.Property(e => e.Venue).HasColumnName("venue");
                entity.Property(e => e.PosterURL).HasColumnName("posterURL");
                entity.Property(e => e.PosterS3Key).HasColumnName("posterS3Key");
                entity.Property(e => e.StartDatetime).HasColumnName("startDatetime");
                entity.Property(e => e.EndDatetime).HasColumnName("endDatetime");
                entity.Property(e => e.Capacity).HasColumnName("capacity");
                entity.Property(e => e.EventStatus).HasColumnName("eventStatus");
                entity.Property(e => e.CategoryID).HasColumnName("categoryID");
                entity.Property(e => e.OrganiserID).HasColumnName("organiserID");
                entity.Property(e => e.ApprovedBy).HasColumnName("approvedBy");
                entity.Property(e => e.CreationRequestID).HasColumnName("creationRequestID");
                entity.Property(e => e.CreatedAt).HasColumnName("createdAt");
            });

            // ============================
            // Event Creation Request
            // ============================
            modelBuilder.Entity<EventCreationRequest>(entity =>
            {
                entity.ToTable("event_creation_request");
                entity.HasKey(x => x.RequestID);

                entity.Property(e => e.RequestID).HasColumnName("requestID");
                entity.Property(e => e.SubmittedBy).HasColumnName("submittedBy");
                entity.Property(e => e.EventTitle).HasColumnName("eventTitle");
                entity.Property(e => e.EventDescription).HasColumnName("eventDescription");
                entity.Property(e => e.Venue).HasColumnName("venue");
                entity.Property(e => e.PosterURL).HasColumnName("posterURL");
                entity.Property(e => e.PosterS3Key).HasColumnName("posterS3Key");
                entity.Property(e => e.CategoryID).HasColumnName("categoryID");
                entity.Property(e => e.ProposedStartDatetime).HasColumnName("proposedStartDatetime");
                entity.Property(e => e.ProposedEndDatetime).HasColumnName("proposedEndDatetime");
                entity.Property(e => e.RequestStatus).HasColumnName("requestedStatus");
                entity.Property(e => e.SubmittedAt).HasColumnName("submittedAt");
                entity.Property(e => e.ReviewedBy).HasColumnName("reviewedBy");
                entity.Property(e => e.ReviewedAt).HasColumnName("reviewedAt");
                entity.Property(e => e.Remark).HasColumnName("remark");
                entity.Property(e => e.RequestCapacity).HasColumnName("requestCapacity");
            });
        }
    }
}