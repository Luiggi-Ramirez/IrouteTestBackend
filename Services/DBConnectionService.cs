using MySqlConnector;
using Microsoft.Extensions.Configuration;
using IrouteTestBackend.Interfaces;

namespace IrouteTestBackend.Services
{
    public class DBConnectionService : IDBConnectionFactory
    {
        private readonly string _connectionString;

        public DBConnectionService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("MySql");

        }

        public MySqlConnection CreateConnection() 
        { 
            return new MySqlConnection(_connectionString);
        }
    }
}
