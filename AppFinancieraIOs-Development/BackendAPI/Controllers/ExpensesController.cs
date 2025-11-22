using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BackendAPI.Data;
using BackendAPI.Models;
using BackendAPI.DTOs;

namespace BackendAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ExpensesController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly ILogger<ExpensesController> _logger;

        public ExpensesController(AppDbContext context, ILogger<ExpensesController> logger)
        {
            _context = context;
            _logger = logger;
        }

        // GET: api/expenses
        [HttpGet]
        public async Task<ActionResult<IEnumerable<ExpenseResponseDto>>> GetExpenses(
            [FromQuery] DateTime? startDate = null,
            [FromQuery] DateTime? endDate = null,
            [FromQuery] ExpenseCategory? category = null)
        {
            try
            {
                var query = _context.Expenses.AsQueryable();

                if (startDate.HasValue)
                    query = query.Where(e => e.Date >= startDate.Value);

                if (endDate.HasValue)
                    query = query.Where(e => e.Date <= endDate.Value);

                if (category.HasValue)
                    query = query.Where(e => e.Category == category.Value);

                var expenses = await query
                    .OrderByDescending(e => e.Date)
                    .ToListAsync();

                var response = expenses.Select(e => new ExpenseResponseDto
                {
                    Id = e.Id,
                    Amount = e.Amount,
                    Category = e.Category,
                    Date = e.Date,
                    Description = e.Description,
                    IsRecurring = e.IsRecurring,
                    RecurringPeriod = e.RecurringPeriod,
                    Notes = e.Notes,
                    ReceiptImage = e.ReceiptImage,
                    CreatedAt = e.CreatedAt,
                    UpdatedAt = e.UpdatedAt
                });

                return Ok(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener gastos");
                return StatusCode(500, "Error interno del servidor");
            }
        }

        // GET: api/expenses/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<ExpenseResponseDto>> GetExpense(Guid id)
        {
            try
            {
                var expense = await _context.Expenses.FindAsync(id);

                if (expense == null)
                    return NotFound($"Gasto con ID {id} no encontrado");

                var response = new ExpenseResponseDto
                {
                    Id = expense.Id,
                    Amount = expense.Amount,
                    Category = expense.Category,
                    Date = expense.Date,
                    Description = expense.Description,
                    IsRecurring = expense.IsRecurring,
                    RecurringPeriod = expense.RecurringPeriod,
                    Notes = expense.Notes,
                    ReceiptImage = expense.ReceiptImage,
                    CreatedAt = expense.CreatedAt,
                    UpdatedAt = expense.UpdatedAt
                };

                return Ok(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener gasto {Id}", id);
                return StatusCode(500, "Error interno del servidor");
            }
        }

        // POST: api/expenses
        [HttpPost]
        public async Task<ActionResult<ExpenseResponseDto>> CreateExpense(ExpenseDto expenseDto)
        {
            try
            {
                var expense = new Expense
                {
                    Amount = expenseDto.Amount,
                    Category = expenseDto.Category,
                    Date = expenseDto.Date,
                    Description = expenseDto.Description,
                    IsRecurring = expenseDto.IsRecurring,
                    RecurringPeriod = expenseDto.RecurringPeriod,
                    Notes = expenseDto.Notes,
                    ReceiptImage = expenseDto.ReceiptImage
                };

                _context.Expenses.Add(expense);
                await _context.SaveChangesAsync();

                var response = new ExpenseResponseDto
                {
                    Id = expense.Id,
                    Amount = expense.Amount,
                    Category = expense.Category,
                    Date = expense.Date,
                    Description = expense.Description,
                    IsRecurring = expense.IsRecurring,
                    RecurringPeriod = expense.RecurringPeriod,
                    Notes = expense.Notes,
                    ReceiptImage = expense.ReceiptImage,
                    CreatedAt = expense.CreatedAt,
                    UpdatedAt = expense.UpdatedAt
                };

                return CreatedAtAction(nameof(GetExpense), new { id = expense.Id }, response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al crear gasto");
                return StatusCode(500, "Error interno del servidor");
            }
        }

        // PUT: api/expenses/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateExpense(Guid id, ExpenseDto expenseDto)
        {
            try
            {
                var expense = await _context.Expenses.FindAsync(id);

                if (expense == null)
                    return NotFound($"Gasto con ID {id} no encontrado");

                expense.Amount = expenseDto.Amount;
                expense.Category = expenseDto.Category;
                expense.Date = expenseDto.Date;
                expense.Description = expenseDto.Description;
                expense.IsRecurring = expenseDto.IsRecurring;
                expense.RecurringPeriod = expenseDto.RecurringPeriod;
                expense.Notes = expenseDto.Notes;
                expense.ReceiptImage = expenseDto.ReceiptImage;

                await _context.SaveChangesAsync();

                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al actualizar gasto {Id}", id);
                return StatusCode(500, "Error interno del servidor");
            }
        }

        // DELETE: api/expenses/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteExpense(Guid id)
        {
            try
            {
                var expense = await _context.Expenses.FindAsync(id);

                if (expense == null)
                    return NotFound($"Gasto con ID {id} no encontrado");

                _context.Expenses.Remove(expense);
                await _context.SaveChangesAsync();

                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al eliminar gasto {Id}", id);
                return StatusCode(500, "Error interno del servidor");
            }
        }

        // GET: api/expenses/summary
        [HttpGet("summary")]
        public async Task<ActionResult<object>> GetExpensesSummary(
            [FromQuery] DateTime? startDate = null,
            [FromQuery] DateTime? endDate = null)
        {
            try
            {
                var query = _context.Expenses.AsQueryable();

                if (startDate.HasValue)
                    query = query.Where(e => e.Date >= startDate.Value);

                if (endDate.HasValue)
                    query = query.Where(e => e.Date <= endDate.Value);

                var summary = new
                {
                    Total = await query.SumAsync(e => e.Amount),
                    Count = await query.CountAsync(),
                    ByCategory = await query
                        .GroupBy(e => e.Category)
                        .Select(g => new
                        {
                            Category = g.Key.ToString(),
                            Total = g.Sum(e => e.Amount),
                            Count = g.Count()
                        })
                        .ToListAsync()
                };

                return Ok(summary);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener resumen de gastos");
                return StatusCode(500, "Error interno del servidor");
            }
        }
    }
}

