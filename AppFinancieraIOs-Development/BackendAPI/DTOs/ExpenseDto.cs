using System;
using BackendAPI.Models;

namespace BackendAPI.DTOs
{
    public class ExpenseDto
    {
        public Guid? Id { get; set; }
        public decimal Amount { get; set; }
        public ExpenseCategory Category { get; set; }
        public DateTime Date { get; set; }
        public string Description { get; set; } = string.Empty;
        public bool IsRecurring { get; set; }
        public RecurringPeriod? RecurringPeriod { get; set; }
        public string? Notes { get; set; }
        public string? ReceiptImage { get; set; }
    }
    
    public class ExpenseResponseDto : ExpenseDto
    {
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }
}

