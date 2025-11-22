using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BackendAPI.Data;
using BackendAPI.Models;
using BackendAPI.DTOs;

namespace BackendAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TaxCalculationsController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly ILogger<TaxCalculationsController> _logger;

        public TaxCalculationsController(AppDbContext context, ILogger<TaxCalculationsController> logger)
        {
            _context = context;
            _logger = logger;
        }

        // GET: api/taxcalculations
        [HttpGet]
        public async Task<ActionResult<IEnumerable<TaxCalculationResponseDto>>> GetTaxCalculations()
        {
            try
            {
                var calculations = await _context.TaxCalculations
                    .OrderByDescending(t => t.Date)
                    .ToListAsync();

                var response = calculations.Select(t => new TaxCalculationResponseDto
                {
                    Id = t.Id,
                    GrossSalary = t.GrossSalary,
                    LowerLimit = t.LowerLimit,
                    ExcessOverLowerLimit = t.ExcessOverLowerLimit,
                    MarginalPercentage = t.MarginalPercentage,
                    MarginalTax = t.MarginalTax,
                    FixedTaxQuota = t.FixedTaxQuota,
                    TotalISR = t.TotalISR,
                    IMSS = t.IMSS,
                    EmploymentSubsidy = t.EmploymentSubsidy,
                    Date = t.Date,
                    NetSalary = t.NetSalary,
                    CreatedAt = t.CreatedAt,
                    UpdatedAt = t.UpdatedAt
                });

                return Ok(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener cálculos de impuestos");
                return StatusCode(500, "Error interno del servidor");
            }
        }

        // GET: api/taxcalculations/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<TaxCalculationResponseDto>> GetTaxCalculation(Guid id)
        {
            try
            {
                var calculation = await _context.TaxCalculations.FindAsync(id);

                if (calculation == null)
                    return NotFound($"Cálculo de impuestos con ID {id} no encontrado");

                var response = new TaxCalculationResponseDto
                {
                    Id = calculation.Id,
                    GrossSalary = calculation.GrossSalary,
                    LowerLimit = calculation.LowerLimit,
                    ExcessOverLowerLimit = calculation.ExcessOverLowerLimit,
                    MarginalPercentage = calculation.MarginalPercentage,
                    MarginalTax = calculation.MarginalTax,
                    FixedTaxQuota = calculation.FixedTaxQuota,
                    TotalISR = calculation.TotalISR,
                    IMSS = calculation.IMSS,
                    EmploymentSubsidy = calculation.EmploymentSubsidy,
                    Date = calculation.Date,
                    NetSalary = calculation.NetSalary,
                    CreatedAt = calculation.CreatedAt,
                    UpdatedAt = calculation.UpdatedAt
                };

                return Ok(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener cálculo de impuestos {Id}", id);
                return StatusCode(500, "Error interno del servidor");
            }
        }

        // POST: api/taxcalculations
        [HttpPost]
        public async Task<ActionResult<TaxCalculationResponseDto>> CreateTaxCalculation(TaxCalculationDto calculationDto)
        {
            try
            {
                var calculation = new TaxCalculation(calculationDto.GrossSalary);

                _context.TaxCalculations.Add(calculation);
                await _context.SaveChangesAsync();

                var response = new TaxCalculationResponseDto
                {
                    Id = calculation.Id,
                    GrossSalary = calculation.GrossSalary,
                    LowerLimit = calculation.LowerLimit,
                    ExcessOverLowerLimit = calculation.ExcessOverLowerLimit,
                    MarginalPercentage = calculation.MarginalPercentage,
                    MarginalTax = calculation.MarginalTax,
                    FixedTaxQuota = calculation.FixedTaxQuota,
                    TotalISR = calculation.TotalISR,
                    IMSS = calculation.IMSS,
                    EmploymentSubsidy = calculation.EmploymentSubsidy,
                    Date = calculation.Date,
                    NetSalary = calculation.NetSalary,
                    CreatedAt = calculation.CreatedAt,
                    UpdatedAt = calculation.UpdatedAt
                };

                return CreatedAtAction(nameof(GetTaxCalculation), new { id = calculation.Id }, response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al crear cálculo de impuestos");
                return StatusCode(500, "Error interno del servidor");
            }
        }

        // DELETE: api/taxcalculations/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTaxCalculation(Guid id)
        {
            try
            {
                var calculation = await _context.TaxCalculations.FindAsync(id);

                if (calculation == null)
                    return NotFound($"Cálculo de impuestos con ID {id} no encontrado");

                _context.TaxCalculations.Remove(calculation);
                await _context.SaveChangesAsync();

                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al eliminar cálculo de impuestos {Id}", id);
                return StatusCode(500, "Error interno del servidor");
            }
        }

        // POST: api/taxcalculations/calculate
        [HttpPost("calculate")]
        public ActionResult<TaxCalculationResponseDto> CalculateTax([FromBody] TaxCalculationDto calculationDto)
        {
            try
            {
                var calculation = new TaxCalculation(calculationDto.GrossSalary);

                var response = new TaxCalculationResponseDto
                {
                    Id = calculation.Id,
                    GrossSalary = calculation.GrossSalary,
                    LowerLimit = calculation.LowerLimit,
                    ExcessOverLowerLimit = calculation.ExcessOverLowerLimit,
                    MarginalPercentage = calculation.MarginalPercentage,
                    MarginalTax = calculation.MarginalTax,
                    FixedTaxQuota = calculation.FixedTaxQuota,
                    TotalISR = calculation.TotalISR,
                    IMSS = calculation.IMSS,
                    EmploymentSubsidy = calculation.EmploymentSubsidy,
                    Date = calculation.Date,
                    NetSalary = calculation.NetSalary,
                    CreatedAt = calculation.CreatedAt,
                    UpdatedAt = calculation.UpdatedAt
                };

                return Ok(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al calcular impuestos");
                return StatusCode(500, "Error interno del servidor");
            }
        }
    }
}

