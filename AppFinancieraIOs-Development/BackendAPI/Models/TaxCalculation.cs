using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BackendAPI.Models
{
    public class TaxCalculation
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();
        
        [Required]
        [Column(TypeName = "decimal(18,2)")]
        public decimal GrossSalary { get; set; }
        
        [Column(TypeName = "decimal(18,2)")]
        public decimal LowerLimit { get; set; }
        
        [Column(TypeName = "decimal(18,2)")]
        public decimal ExcessOverLowerLimit { get; set; }
        
        [Column(TypeName = "decimal(5,2)")]
        public decimal MarginalPercentage { get; set; }
        
        [Column(TypeName = "decimal(18,2)")]
        public decimal MarginalTax { get; set; }
        
        [Column(TypeName = "decimal(18,2)")]
        public decimal FixedTaxQuota { get; set; }
        
        [Column(TypeName = "decimal(18,2)")]
        public decimal TotalISR { get; set; }
        
        [Column(TypeName = "decimal(18,2)")]
        public decimal IMSS { get; set; }
        
        [Column(TypeName = "decimal(18,2)")]
        public decimal EmploymentSubsidy { get; set; }
        
        [Required]
        public DateTime Date { get; set; }
        
        [Column(TypeName = "decimal(18,2)")]
        public decimal NetSalary { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
        
        public TaxCalculation()
        {
        }
        
        public TaxCalculation(decimal grossSalary)
        {
            GrossSalary = grossSalary;
            LowerLimit = 15487.72m; // Límite inferior 2024
            ExcessOverLowerLimit = Math.Max(0, grossSalary - LowerLimit);
            MarginalPercentage = 21.36m; // Porcentaje sobre excedente
            MarginalTax = ExcessOverLowerLimit * (MarginalPercentage / 100);
            FixedTaxQuota = 1640.18m; // Cuota fija del impuesto
            TotalISR = MarginalTax + FixedTaxQuota;
            IMSS = grossSalary * 0.0275m; // 2.75% del IMSS
            EmploymentSubsidy = 0.0m; // Se calcula según tablas del SAT
            Date = DateTime.UtcNow;
            NetSalary = grossSalary - TotalISR - IMSS + EmploymentSubsidy;
        }
    }
}

