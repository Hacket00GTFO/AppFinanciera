using System;
using BackendAPI.Models;

namespace BackendAPI.DTOs
{
    public class DeductionDto
    {
        public Guid? Id { get; set; }
        public DeductionType Type { get; set; }
        public decimal Amount { get; set; }
        public decimal? Percentage { get; set; }
        public DateTime Date { get; set; }
        public string? Description { get; set; }
    }
    
    public class DeductionResponseDto : DeductionDto
    {
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }
}

