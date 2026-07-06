using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using UniversityEventManager.API.Data;

namespace UniversityEventManager.API.Controllers
{
    [ApiController]
    [Route("api/categories")]
    public class CategoriesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public CategoriesController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetCategories()
        {
            var categories = await _context.EventCategories
                .Select(c => new
                {
                    categoryID = c.CategoryID,
                    categoryName = c.CategoryName
                })
                .ToListAsync();

            return Ok(categories);
        }
    }
}