using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BackendAPI.Models
{
    public class Deduction
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();
        
        [Required]
        public DeductionType Type { get; set; }
        
        [Required]
        [Column(TypeName = "decimal(18,2)")]
        public decimal Amount { get; set; }
        
        [Column(TypeName = "decimal(5,2)")]
        public decimal? Percentage { get; set; }
        
        [Required]
        public DateTime Date { get; set; }
        
        [MaxLength(500)]
        public string? Description { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
    
    public enum DeductionType
    {
        ISR = 0,
        IMSS = 1,
        EmploymentSubsidy = 2,
        Other = 3
    }
}

