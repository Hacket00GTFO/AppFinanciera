using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BackendAPI.Data;
using BackendAPI.Models;
using BackendAPI.DTOs;

namespace BackendAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DeductionsController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly ILogger<DeductionsController> _logger;

        public DeductionsController(AppDbContext context, ILogger<DeductionsController> logger)
        {
            _context = context;
            _logger = logger;
        }

        // GET: api/deductions
        [HttpGet]
        public async Task<ActionResult<IEnumerable<DeductionResponseDto>>> GetDeductions(
            [FromQuery] DateTime? startDate = null,
            [FromQuery] DateTime? endDate = null)
        {
            try
            {
                var query = _context.Deductions.AsQueryable();

                if (startDate.HasValue)
                    query = query.Where(d => d.Date >= startDate.Value);

                if (endDate.HasValue)
                    query = query.Where(d => d.Date <= endDate.Value);

                var deductions = await query
                    .OrderByDescending(d => d.Date)
                    .ToListAsync();

                var response = deductions.Select(d => new DeductionResponseDto
                {
                    Id = d.Id,
                    Type = d.Type,
                    Amount = d.Amount,
                    Percentage = d.Percentage,
                    Date = d.Date,
                    Description = d.Description,
                    CreatedAt = d.CreatedAt,
                    UpdatedAt = d.UpdatedAt
                });

                return Ok(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener deducciones");
                return StatusCode(500, "Error interno del servidor");
            }
        }

        // GET: api/deductions/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<DeductionResponseDto>> GetDeduction(Guid id)
        {
            try
            {
                var deduction = await _context.Deductions.FindAsync(id);

                if (deduction == null)
                    return NotFound($"Deducción con ID {id} no encontrada");

                var response = new DeductionResponseDto
                {
                    Id = deduction.Id,
                    Type = deduction.Type,
                    Amount = deduction.Amount,
                    Percentage = deduction.Percentage,
                    Date = deduction.Date,
                    Description = deduction.Description,
                    CreatedAt = deduction.CreatedAt,
                    UpdatedAt = deduction.UpdatedAt
                };

                return Ok(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener deducción {Id}", id);
                return StatusCode(500, "Error interno del servidor");
            }
        }

        // POST: api/deductions
        [HttpPost]
        public async Task<ActionResult<DeductionResponseDto>> CreateDeduction(DeductionDto deductionDto)
        {
            try
            {
                var deduction = new Deduction
                {
                    Type = deductionDto.Type,
                    Amount = deductionDto.Amount,
                    Percentage = deductionDto.Percentage,
                    Date = deductionDto.Date,
                    Description = deductionDto.Description
                };

                _context.Deductions.Add(deduction);
                await _context.SaveChangesAsync();

                var response = new DeductionResponseDto
                {
                    Id = deduction.Id,
                    Type = deduction.Type,
                    Amount = deduction.Amount,
                    Percentage = deduction.Percentage,
                    Date = deduction.Date,
                    Description = deduction.Description,
                    CreatedAt = deduction.CreatedAt,
                    UpdatedAt = deduction.UpdatedAt
                };

                return CreatedAtAction(nameof(GetDeduction), new { id = deduction.Id }, response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al crear deducción");
                return StatusCode(500, "Error interno del servidor");
            }
        }

        // PUT: api/deductions/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateDeduction(Guid id, DeductionDto deductionDto)
        {
            try
            {
                var deduction = await _context.Deductions.FindAsync(id);

                if (deduction == null)
                    return NotFound($"Deducción con ID {id} no encontrada");

                deduction.Type = deductionDto.Type;
                deduction.Amount = deductionDto.Amount;
                deduction.Percentage = deductionDto.Percentage;
                deduction.Date = deductionDto.Date;
                deduction.Description = deductionDto.Description;

                await _context.SaveChangesAsync();

                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al actualizar deducción {Id}", id);
                return StatusCode(500, "Error interno del servidor");
            }
        }

        // DELETE: api/deductions/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteDeduction(Guid id)
        {
            try
            {
                var deduction = await _context.Deductions.FindAsync(id);

                if (deduction == null)
                    return NotFound($"Deducción con ID {id} no encontrada");

                _context.Deductions.Remove(deduction);
                await _context.SaveChangesAsync();

                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al eliminar deducción {Id}", id);
                return StatusCode(500, "Error interno del servidor");
            }
        }

        // GET: api/deductions/summary
        [HttpGet("summary")]
        public async Task<ActionResult<object>> GetDeductionsSummary(
            [FromQuery] DateTime? startDate = null,
            [FromQuery] DateTime? endDate = null)
        {
            try
            {
                var query = _context.Deductions.AsQueryable();

                if (startDate.HasValue)
                    query = query.Where(d => d.Date >= startDate.Value);

                if (endDate.HasValue)
                    query = query.Where(d => d.Date <= endDate.Value);

                var summary = new
                {
                    Total = await query.SumAsync(d => d.Amount),
                    Count = await query.CountAsync(),
                    ByType = await query
                        .GroupBy(d => d.Type)
                        .Select(g => new
                        {
                            Type = g.Key.ToString(),
                            Total = g.Sum(d => d.Amount),
                            Count = g.Count()
                        })
                        .ToListAsync()
                };

                return Ok(summary);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener resumen de deducciones");
                return StatusCode(500, "Error interno del servidor");
            }
        }
    }
}

