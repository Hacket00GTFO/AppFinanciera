using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BackendAPI.Models
{
    public class Income
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();
        
        [Required]
        [Column(TypeName = "decimal(18,2)")]
        public decimal GrossAmount { get; set; }
        
        [Required]
        [Column(TypeName = "decimal(18,2)")]
        public decimal NetAmount { get; set; }
        
        [Required]
        public DateTime Date { get; set; }
        
        [Required]
        public IncomeType Type { get; set; }
        
        [Required]
        [MaxLength(500)]
        public string Description { get; set; } = string.Empty;
        
        [Required]
        public bool IsRecurring { get; set; }
        
        public RecurringPeriod? RecurringPeriod { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
    
    public enum IncomeType
    {
        Freelance = 0,
        Employment = 1,
        Investment = 2,
        Other = 3
    }
    
    public enum RecurringPeriod
    {
        Weekly = 0,
        Biweekly = 1,
        Monthly = 2,
        Yearly = 3
    }
}

