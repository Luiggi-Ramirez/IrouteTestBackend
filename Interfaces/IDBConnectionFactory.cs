using MySqlConnector;

namespace IrouteTestBackend.Interfaces
{
    public interface IDBConnectionFactory
    {
        MySqlConnection CreateConnection();
    }
}
