using System;
using BackendAPI.Models;

namespace BackendAPI.DTOs
{
    public class FinancialPeriodDto
    {
        public Guid? Id { get; set; }
        public PeriodType Type { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public decimal TotalIncome { get; set; }
        public decimal TotalExpenses { get; set; }
        public decimal TotalDeductions { get; set; }
        public decimal Balance { get; set; }
        public bool IsCompleted { get; set; }
    }
    
    public class FinancialPeriodResponseDto : FinancialPeriodDto
    {
        public bool IsCurrentPeriod { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }
}

