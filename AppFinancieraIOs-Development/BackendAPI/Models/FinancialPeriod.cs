using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BackendAPI.Models
{
    public class FinancialPeriod
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();
        
        [Required]
        public PeriodType Type { get; set; }
        
        [Required]
        public DateTime StartDate { get; set; }
        
        [Required]
        public DateTime EndDate { get; set; }
        
        [Column(TypeName = "decimal(18,2)")]
        public decimal TotalIncome { get; set; }
        
        [Column(TypeName = "decimal(18,2)")]
        public decimal TotalExpenses { get; set; }
        
        [Column(TypeName = "decimal(18,2)")]
        public decimal TotalDeductions { get; set; }
        
        [Column(TypeName = "decimal(18,2)")]
        public decimal Balance { get; set; }
        
        [Required]
        public bool IsCompleted { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
        
        public void UpdateBalance()
        {
            Balance = TotalIncome - TotalExpenses - TotalDeductions;
        }
        
        public bool IsCurrentPeriod()
        {
            var now = DateTime.UtcNow;
            return now >= StartDate && now <= EndDate;
        }
    }
    
    public enum PeriodType
    {
        Weekly = 0,
        Biweekly = 1,
        Monthly = 2
    }
    
    public static class PeriodTypeExtensions
    {
        public static int GetDays(this PeriodType periodType)
        {
            return periodType switch
            {
                PeriodType.Weekly => 7,
                PeriodType.Biweekly => 15,
                PeriodType.Monthly => 30,
                _ => 30
            };
        }
    }
}

