using System;

namespace BackendAPI.DTOs
{
    public class TaxCalculationDto
    {
        public Guid? Id { get; set; }
        public decimal GrossSalary { get; set; }
    }
    
    public class TaxCalculationResponseDto
    {
        public Guid Id { get; set; }
        public decimal GrossSalary { get; set; }
        public decimal LowerLimit { get; set; }
        public decimal ExcessOverLowerLimit { get; set; }
        public decimal MarginalPercentage { get; set; }
        public decimal MarginalTax { get; set; }
        public decimal FixedTaxQuota { get; set; }
        public decimal TotalISR { get; set; }
        public decimal IMSS { get; set; }
        public decimal EmploymentSubsidy { get; set; }
        public DateTime Date { get; set; }
        public decimal NetSalary { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }
}

