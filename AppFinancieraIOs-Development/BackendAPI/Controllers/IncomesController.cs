using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BackendAPI.Data;
using BackendAPI.Models;
using BackendAPI.DTOs;

namespace BackendAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class IncomesController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly ILogger<IncomesController> _logger;

        public IncomesController(AppDbContext context, ILogger<IncomesController> logger)
        {
            _context = context;
            _logger = logger;
        }

        // GET: api/incomes
        [HttpGet]
        public async Task<ActionResult<IEnumerable<IncomeResponseDto>>> GetIncomes(
            [FromQuery] DateTime? startDate = null,
            [FromQuery] DateTime? endDate = null)
        {
            try
            {
                var query = _context.Incomes.AsQueryable();

                if (startDate.HasValue)
                    query = query.Where(i => i.Date >= startDate.Value);

                if (endDate.HasValue)
                    query = query.Where(i => i.Date <= endDate.Value);

                var incomes = await query
                    .OrderByDescending(i => i.Date)
                    .ToListAsync();

                var response = incomes.Select(i => new IncomeResponseDto
                {
                    Id = i.Id,
                    GrossAmount = i.GrossAmount,
                    NetAmount = i.NetAmount,
                    Date = i.Date,
                    Type = i.Type,
                    Description = i.Description,
                    IsRecurring = i.IsRecurring,
                    RecurringPeriod = i.RecurringPeriod,
                    CreatedAt = i.CreatedAt,
                    UpdatedAt = i.UpdatedAt
                });

                return Ok(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener ingresos");
                return StatusCode(500, "Error interno del servidor");
            }
        }

        // GET: api/incomes/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<IncomeResponseDto>> GetIncome(Guid id)
        {
            try
            {
                var income = await _context.Incomes.FindAsync(id);

                if (income == null)
                    return NotFound($"Ingreso con ID {id} no encontrado");

                var response = new IncomeResponseDto
                {
                    Id = income.Id,
                    GrossAmount = income.GrossAmount,
                    NetAmount = income.NetAmount,
                    Date = income.Date,
                    Type = income.Type,
                    Description = income.Description,
                    IsRecurring = income.IsRecurring,
                    RecurringPeriod = income.RecurringPeriod,
                    CreatedAt = income.CreatedAt,
                    UpdatedAt = income.UpdatedAt
                };

                return Ok(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener ingreso {Id}", id);
                return StatusCode(500, "Error interno del servidor");
            }
        }

        // POST: api/incomes
        [HttpPost]
        public async Task<ActionResult<IncomeResponseDto>> CreateIncome(IncomeDto incomeDto)
        {
            try
            {
                var income = new Income
                {
                    GrossAmount = incomeDto.GrossAmount,
                    NetAmount = incomeDto.NetAmount,
                    Date = incomeDto.Date,
                    Type = incomeDto.Type,
                    Description = incomeDto.Description,
                    IsRecurring = incomeDto.IsRecurring,
                    RecurringPeriod = incomeDto.RecurringPeriod
                };

                _context.Incomes.Add(income);
                await _context.SaveChangesAsync();

                var response = new IncomeResponseDto
                {
                    Id = income.Id,
                    GrossAmount = income.GrossAmount,
                    NetAmount = income.NetAmount,
                    Date = income.Date,
                    Type = income.Type,
                    Description = income.Description,
                    IsRecurring = income.IsRecurring,
                    RecurringPeriod = income.RecurringPeriod,
                    CreatedAt = income.CreatedAt,
                    UpdatedAt = income.UpdatedAt
                };

                return CreatedAtAction(nameof(GetIncome), new { id = income.Id }, response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al crear ingreso");
                return StatusCode(500, "Error interno del servidor");
            }
        }

        // PUT: api/incomes/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateIncome(Guid id, IncomeDto incomeDto)
        {
            try
            {
                var income = await _context.Incomes.FindAsync(id);

                if (income == null)
                    return NotFound($"Ingreso con ID {id} no encontrado");

                income.GrossAmount = incomeDto.GrossAmount;
                income.NetAmount = incomeDto.NetAmount;
                income.Date = incomeDto.Date;
                income.Type = incomeDto.Type;
                income.Description = incomeDto.Description;
                income.IsRecurring = incomeDto.IsRecurring;
                income.RecurringPeriod = incomeDto.RecurringPeriod;

                await _context.SaveChangesAsync();

                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al actualizar ingreso {Id}", id);
                return StatusCode(500, "Error interno del servidor");
            }
        }

        // DELETE: api/incomes/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteIncome(Guid id)
        {
            try
            {
                var income = await _context.Incomes.FindAsync(id);

                if (income == null)
                    return NotFound($"Ingreso con ID {id} no encontrado");

                _context.Incomes.Remove(income);
                await _context.SaveChangesAsync();

                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al eliminar ingreso {Id}", id);
                return StatusCode(500, "Error interno del servidor");
            }
        }

        // GET: api/incomes/summary
        [HttpGet("summary")]
        public async Task<ActionResult<object>> GetIncomeSummary(
            [FromQuery] DateTime? startDate = null,
            [FromQuery] DateTime? endDate = null)
        {
            try
            {
                var query = _context.Incomes.AsQueryable();

                if (startDate.HasValue)
                    query = query.Where(i => i.Date >= startDate.Value);

                if (endDate.HasValue)
                    query = query.Where(i => i.Date <= endDate.Value);

                var summary = new
                {
                    TotalGross = await query.SumAsync(i => i.GrossAmount),
                    TotalNet = await query.SumAsync(i => i.NetAmount),
                    Count = await query.CountAsync(),
                    ByType = await query
                        .GroupBy(i => i.Type)
                        .Select(g => new
                        {
                            Type = g.Key.ToString(),
                            Total = g.Sum(i => i.GrossAmount),
                            Count = g.Count()
                        })
                        .ToListAsync()
                };

                return Ok(summary);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener resumen de ingresos");
                return StatusCode(500, "Error interno del servidor");
            }
        }
    }
}

