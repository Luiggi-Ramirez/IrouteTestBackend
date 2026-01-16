using IrouteTestBackend.DTOs;

namespace IrouteTestBackend.Interfaces{
    public interface ICommerceService
    {
        Task<int> ImportCsvAsync(IFormFile file);
        Task<int> ProcessQuarentineAsync(DateTime processDate);
        Task<List<QuarentineDTO>> GetQuarentineListAsync();
    }
}