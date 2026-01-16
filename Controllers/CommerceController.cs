using IrouteTestBackend.Interfaces;
using IrouteTestBackend.DTOs;
using Microsoft.AspNetCore.Connections;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Reflection.PortableExecutable;

namespace IrouteTestBackend.Controllers
{
    [Route("api/commerce/")]
    [ApiController]
    public class CommerceController : ControllerBase
    {
        private readonly ICommerceService _service;

        public CommerceController(ICommerceService service) => _service = service;

        [HttpPost("upload")]
        public async Task<IActionResult> UploadCSV(IFormFile file)
        {
            if (file == null || file.Length == 0) return BadRequest("El archivo está vacío.");
            if (!file.FileName.StartsWith("commerce_")) return BadRequest("Nombre de archivo inválido.");
            if (!file.FileName.EndsWith(".csv")) return BadRequest("Formato de archivo inválido.");

            await _service.ImportCsvAsync(file);
            return Ok("Archivo procesado e insertado.");
        }

        [HttpPost("process-validation")]
        public async Task<IActionResult> ProcessValidation([FromBody] ProcessDateDTO processDate)
        {
            int totalQuarantine = await _service.ProcessQuarentineAsync(processDate.processDate);
            return Ok(new { registros_quarantine = totalQuarantine });
        }

        [HttpGet("quarentine")]
        public async Task<IActionResult> GetQuarentine()
        {
            return Ok(await _service.GetQuarentineListAsync());
        }
    }
}