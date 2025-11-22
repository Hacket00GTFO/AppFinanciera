using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BackendAPI.Models
{
    public class Expense
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();
        
        [Required]
        [Column(TypeName = "decimal(18,2)")]
        public decimal Amount { get; set; }
        
        [Required]
        public ExpenseCategory Category { get; set; }
        
        [Required]
        public DateTime Date { get; set; }
        
        [Required]
        [MaxLength(500)]
        public string Description { get; set; } = string.Empty;
        
        [Required]
        public bool IsRecurring { get; set; }
        
        public RecurringPeriod? RecurringPeriod { get; set; }
        
        [MaxLength(1000)]
        public string? Notes { get; set; }
        
        // Para almacenar imagen del recibo como base64 o ruta
        public string? ReceiptImage { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}

