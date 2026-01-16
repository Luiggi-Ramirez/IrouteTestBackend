# IrouteTestBackend
## Ejecución
### Setear la base de datos
1. Crear la base de datos iroute_db_test en MySql en mi caso use XAMPP
2. Ejecutar el contenido del archivo sql del proyecto en la base de datos creada

### Ejecutar el proyecto
1. Clonar el repositorio en Visual Studio
2. Restaurar los paquetes NuGet
3. Iniciar el server

### Ejecutar los tests
1. Abrir postman
2. Importar la colección iroute_test.postman_collection.json
3. Ejecutar los endpoints de la colección

### Información adicional
- El proyecto utiliza .NET 8
- El proyecto utiliza MySql en xampp como base de datos
- El proyecto utiliza store procedures para las operaciones con la base de datos y se encuentran en el .sql
- El proyecto usa inyeccion de dependencias para de acoplar los servicios
- No me pasaron csvs de prueba así que tome los campos de lo especificado en el enunciado
- No alacancé a implementar el login ya que tuve que avanzar con el front
