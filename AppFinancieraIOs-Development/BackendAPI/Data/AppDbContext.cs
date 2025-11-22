using Microsoft.EntityFrameworkCore;
using BackendAPI.Models;

namespace BackendAPI.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }
        
        public DbSet<Income> Incomes { get; set; }
        public DbSet<Expense> Expenses { get; set; }
        public DbSet<Deduction> Deductions { get; set; }
        public DbSet<FinancialPeriod> FinancialPeriods { get; set; }
        public DbSet<TaxCalculation> TaxCalculations { get; set; }
        
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            
            // Configuración de Income
            modelBuilder.Entity<Income>(entity =>
            {
                entity.ToTable("Incomes");
                entity.HasKey(e => e.Id);
                entity.Property(e => e.GrossAmount).HasPrecision(18, 2);
                entity.Property(e => e.NetAmount).HasPrecision(18, 2);
                entity.Property(e => e.Description).IsRequired().HasMaxLength(500);
                entity.Property(e => e.Type).HasConversion<string>();
                entity.Property(e => e.RecurringPeriod).HasConversion<string>();
                entity.HasIndex(e => e.Date);
            });
            
            // Configuración de Expense
            modelBuilder.Entity<Expense>(entity =>
            {
                entity.ToTable("Expenses");
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Amount).HasPrecision(18, 2);
                entity.Property(e => e.Description).IsRequired().HasMaxLength(500);
                entity.Property(e => e.Category).HasConversion<string>();
                entity.Property(e => e.RecurringPeriod).HasConversion<string>();
                entity.HasIndex(e => e.Date);
                entity.HasIndex(e => e.Category);
            });
            
            // Configuración de Deduction
            modelBuilder.Entity<Deduction>(entity =>
            {
                entity.ToTable("Deductions");
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Amount).HasPrecision(18, 2);
                entity.Property(e => e.Percentage).HasPrecision(5, 2);
                entity.Property(e => e.Type).HasConversion<string>();
                entity.HasIndex(e => e.Date);
            });
            
            // Configuración de FinancialPeriod
            modelBuilder.Entity<FinancialPeriod>(entity =>
            {
                entity.ToTable("FinancialPeriods");
                entity.HasKey(e => e.Id);
                entity.Property(e => e.TotalIncome).HasPrecision(18, 2);
                entity.Property(e => e.TotalExpenses).HasPrecision(18, 2);
                entity.Property(e => e.TotalDeductions).HasPrecision(18, 2);
                entity.Property(e => e.Balance).HasPrecision(18, 2);
                entity.Property(e => e.Type).HasConversion<string>();
                entity.HasIndex(e => e.StartDate);
                entity.HasIndex(e => e.EndDate);
            });
            
            // Configuración de TaxCalculation
            modelBuilder.Entity<TaxCalculation>(entity =>
            {
                entity.ToTable("TaxCalculations");
                entity.HasKey(e => e.Id);
                entity.Property(e => e.GrossSalary).HasPrecision(18, 2);
                entity.Property(e => e.LowerLimit).HasPrecision(18, 2);
                entity.Property(e => e.ExcessOverLowerLimit).HasPrecision(18, 2);
                entity.Property(e => e.MarginalPercentage).HasPrecision(5, 2);
                entity.Property(e => e.MarginalTax).HasPrecision(18, 2);
                entity.Property(e => e.FixedTaxQuota).HasPrecision(18, 2);
                entity.Property(e => e.TotalISR).HasPrecision(18, 2);
                entity.Property(e => e.IMSS).HasPrecision(18, 2);
                entity.Property(e => e.EmploymentSubsidy).HasPrecision(18, 2);
                entity.Property(e => e.NetSalary).HasPrecision(18, 2);
                entity.HasIndex(e => e.Date);
            });
        }
        
        public override int SaveChanges()
        {
            UpdateTimestamps();
            return base.SaveChanges();
        }
        
        public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            UpdateTimestamps();
            return base.SaveChangesAsync(cancellationToken);
        }
        
        private void UpdateTimestamps()
        {
            var entries = ChangeTracker.Entries()
                .Where(e => e.State == EntityState.Added || e.State == EntityState.Modified);
                
            foreach (var entry in entries)
            {
                if (entry.Entity.GetType().GetProperty("UpdatedAt") != null)
                {
                    entry.Property("UpdatedAt").CurrentValue = DateTime.UtcNow;
                }
                
                if (entry.State == EntityState.Added && 
                    entry.Entity.GetType().GetProperty("CreatedAt") != null)
                {
                    entry.Property("CreatedAt").CurrentValue = DateTime.UtcNow;
                }
            }
        }
    }
}

