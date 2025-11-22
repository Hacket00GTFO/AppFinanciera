using System;
using BackendAPI.Models;

namespace BackendAPI.DTOs
{
    public class IncomeDto
    {
        public Guid? Id { get; set; }
        public decimal GrossAmount { get; set; }
        public decimal NetAmount { get; set; }
        public DateTime Date { get; set; }
        public IncomeType Type { get; set; }
        public string Description { get; set; } = string.Empty;
        public bool IsRecurring { get; set; }
        public RecurringPeriod? RecurringPeriod { get; set; }
    }
    
    public class IncomeResponseDto : IncomeDto
    {
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }
}

