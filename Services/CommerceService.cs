using IrouteTestBackend.DTOs;
using IrouteTestBackend.Interfaces;
using MySqlConnector;
using System.Data;
using System.Globalization;
using System.Text.Json;

namespace IrouteTestBackend.Services
{
    public class CommerceService : ICommerceService
    {
        private readonly string _connectionString;

        public CommerceService(IConfiguration configuration)
        {
             _connectionString = configuration.GetConnectionString("MySql");
        }

        public async Task<int> ImportCsvAsync(IFormFile file)
        {
            var lista = new List<CommerceDTO>();

            using (var reader = new StreamReader(file.OpenReadStream()))
            {
                // nos saltamos el header
                var header = await reader.ReadLineAsync();

                // recorremos todas las filas hasta que termie
                while (!reader.EndOfStream)
                {
                    var line = await reader.ReadLineAsync();
                    if (string.IsNullOrWhiteSpace(line)) continue;

                    var values = line.Split(';'); // Delimitador por punto y coma

                    // Parsear fecha d/M/yyyy a yyyy-MM-dd para MySQL
                    if (DateTime.TryParseExact(values[0], "d/M/yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime dt))
                    {
                        lista.Add(new CommerceDTO
                        {
                            pc_processdate = dt.ToString("yyyy-MM-dd"),
                            pc_nomcomred = values[1],
                            pc_numdoc = values[2]
                        });
                    }
                }
            }

            using (var conn = new MySqlConnection(_connectionString))
            {
                await conn.OpenAsync();
                // Iniciamos transacción
                using (var trans = await conn.BeginTransactionAsync())
                {
                    try
                    {
                        foreach (var item in lista)
                        {
                            // Llamamos al SP por cada fila, pero dentro de la misma transacción
                            using (var cmd = new MySqlCommand("sp_create_commerce", conn, trans))
                            {
                                cmd.CommandType = CommandType.StoredProcedure;
                                cmd.Parameters.AddWithValue("@p_date", item.pc_processdate);
                                cmd.Parameters.AddWithValue("@p_name", item.pc_nomcomred);
                                cmd.Parameters.AddWithValue("@p_doc", item.pc_numdoc);
                                await cmd.ExecuteNonQueryAsync();
                            }
                        }
                        // Bulk save
                        await trans.CommitAsync(); 
                    }
                    catch
                    {
                        // Si algo falla, hacemos rollback
                        await trans.RollbackAsync(); 
                        throw;
                    }
                }
            }
            return lista.Count;
        }

        public async Task<int> ProcessQuarentineAsync(DateTime processDate)
        {
            using (var conn = new MySqlConnection(_connectionString))
            {
                await conn.OpenAsync();
                using (var cmd = new MySqlCommand("sp_process_quarantine", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@p_date", processDate.ToString("yyyy-MM-dd"));

                    // El SP debe retornar el COUNT de registros movidos
                    return Convert.ToInt32(await cmd.ExecuteScalarAsync());
                }
            }
        }

        public async Task<List<QuarentineDTO>> GetQuarentineListAsync()
        {
            var result = new List<QuarentineDTO>();
            using (var conn = new MySqlConnection(_connectionString))
            {
                await conn.OpenAsync();
                using (var cmd = new MySqlCommand("SELECT * FROM commerce_quarentine", conn))
                {
                    using (var reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            result.Add(new QuarentineDTO
                            {
                                pc_processdate = reader["pc_processdate"].ToString(),
                                pc_nomcomred = reader["pc_nomcomred"].ToString(),
                                pc_numdoc = reader["pc_numdoc"].ToString(),
                                motivo = reader["motivo"].ToString()
                            });
                        }
                    }
                }
            }
            return result;
        }
    }
}
