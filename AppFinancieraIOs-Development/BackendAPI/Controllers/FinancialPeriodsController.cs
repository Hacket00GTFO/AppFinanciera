using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BackendAPI.Data;
using BackendAPI.Models;
using BackendAPI.DTOs;

namespace BackendAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class FinancialPeriodsController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly ILogger<FinancialPeriodsController> _logger;

        public FinancialPeriodsController(AppDbContext context, ILogger<FinancialPeriodsController> logger)
        {
            _context = context;
            _logger = logger;
        }

        // GET: api/financialperiods
        [HttpGet]
        public async Task<ActionResult<IEnumerable<FinancialPeriodResponseDto>>> GetFinancialPeriods()
        {
            try
            {
                var periods = await _context.FinancialPeriods
                    .OrderByDescending(p => p.StartDate)
                    .ToListAsync();

                var response = periods.Select(p => new FinancialPeriodResponseDto
                {
                    Id = p.Id,
                    Type = p.Type,
                    StartDate = p.StartDate,
                    EndDate = p.EndDate,
                    TotalIncome = p.TotalIncome,
                    TotalExpenses = p.TotalExpenses,
                    TotalDeductions = p.TotalDeductions,
                    Balance = p.Balance,
                    IsCompleted = p.IsCompleted,
                    IsCurrentPeriod = p.IsCurrentPeriod(),
                    CreatedAt = p.CreatedAt,
                    UpdatedAt = p.UpdatedAt
                });

                return Ok(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener períodos financieros");
                return StatusCode(500, "Error interno del servidor");
            }
        }

        // GET: api/financialperiods/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<FinancialPeriodResponseDto>> GetFinancialPeriod(Guid id)
        {
            try
            {
                var period = await _context.FinancialPeriods.FindAsync(id);

                if (period == null)
                    return NotFound($"Período financiero con ID {id} no encontrado");

                var response = new FinancialPeriodResponseDto
                {
                    Id = period.Id,
                    Type = period.Type,
                    StartDate = period.StartDate,
                    EndDate = period.EndDate,
                    TotalIncome = period.TotalIncome,
                    TotalExpenses = period.TotalExpenses,
                    TotalDeductions = period.TotalDeductions,
                    Balance = period.Balance,
                    IsCompleted = period.IsCompleted,
                    IsCurrentPeriod = period.IsCurrentPeriod(),
                    CreatedAt = period.CreatedAt,
                    UpdatedAt = period.UpdatedAt
                };

                return Ok(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener período financiero {Id}", id);
                return StatusCode(500, "Error interno del servidor");
            }
        }

        // POST: api/financialperiods
        [HttpPost]
        public async Task<ActionResult<FinancialPeriodResponseDto>> CreateFinancialPeriod(FinancialPeriodDto periodDto)
        {
            try
            {
                var period = new FinancialPeriod
                {
                    Type = periodDto.Type,
                    StartDate = periodDto.StartDate,
                    EndDate = periodDto.EndDate ?? periodDto.StartDate.AddDays(periodDto.Type.GetDays() - 1),
                    TotalIncome = periodDto.TotalIncome,
                    TotalExpenses = periodDto.TotalExpenses,
                    TotalDeductions = periodDto.TotalDeductions,
                    Balance = periodDto.Balance,
                    IsCompleted = periodDto.IsCompleted
                };

                period.UpdateBalance();

                _context.FinancialPeriods.Add(period);
                await _context.SaveChangesAsync();

                var response = new FinancialPeriodResponseDto
                {
                    Id = period.Id,
                    Type = period.Type,
                    StartDate = period.StartDate,
                    EndDate = period.EndDate,
                    TotalIncome = period.TotalIncome,
                    TotalExpenses = period.TotalExpenses,
                    TotalDeductions = period.TotalDeductions,
                    Balance = period.Balance,
                    IsCompleted = period.IsCompleted,
                    IsCurrentPeriod = period.IsCurrentPeriod(),
                    CreatedAt = period.CreatedAt,
                    UpdatedAt = period.UpdatedAt
                };

                return CreatedAtAction(nameof(GetFinancialPeriod), new { id = period.Id }, response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al crear período financiero");
                return StatusCode(500, "Error interno del servidor");
            }
        }

        // PUT: api/financialperiods/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateFinancialPeriod(Guid id, FinancialPeriodDto periodDto)
        {
            try
            {
                var period = await _context.FinancialPeriods.FindAsync(id);

                if (period == null)
                    return NotFound($"Período financiero con ID {id} no encontrado");

                period.Type = periodDto.Type;
                period.StartDate = periodDto.StartDate;
                period.EndDate = periodDto.EndDate ?? periodDto.StartDate.AddDays(periodDto.Type.GetDays() - 1);
                period.TotalIncome = periodDto.TotalIncome;
                period.TotalExpenses = periodDto.TotalExpenses;
                period.TotalDeductions = periodDto.TotalDeductions;
                period.IsCompleted = periodDto.IsCompleted;

                period.UpdateBalance();

                await _context.SaveChangesAsync();

                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al actualizar período financiero {Id}", id);
                return StatusCode(500, "Error interno del servidor");
            }
        }

        // DELETE: api/financialperiods/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteFinancialPeriod(Guid id)
        {
            try
            {
                var period = await _context.FinancialPeriods.FindAsync(id);

                if (period == null)
                    return NotFound($"Período financiero con ID {id} no encontrado");

                _context.FinancialPeriods.Remove(period);
                await _context.SaveChangesAsync();

                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al eliminar período financiero {Id}", id);
                return StatusCode(500, "Error interno del servidor");
            }
        }

        // GET: api/financialperiods/current
        [HttpGet("current")]
        public async Task<ActionResult<FinancialPeriodResponseDto>> GetCurrentPeriod()
        {
            try
            {
                var now = DateTime.UtcNow;
                var period = await _context.FinancialPeriods
                    .Where(p => p.StartDate <= now && p.EndDate >= now)
                    .FirstOrDefaultAsync();

                if (period == null)
                    return NotFound("No hay período financiero activo");

                var response = new FinancialPeriodResponseDto
                {
                    Id = period.Id,
                    Type = period.Type,
                    StartDate = period.StartDate,
                    EndDate = period.EndDate,
                    TotalIncome = period.TotalIncome,
                    TotalExpenses = period.TotalExpenses,
                    TotalDeductions = period.TotalDeductions,
                    Balance = period.Balance,
                    IsCompleted = period.IsCompleted,
                    IsCurrentPeriod = true,
                    CreatedAt = period.CreatedAt,
                    UpdatedAt = period.UpdatedAt
                };

                return Ok(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener período actual");
                return StatusCode(500, "Error interno del servidor");
            }
        }
    }
}

