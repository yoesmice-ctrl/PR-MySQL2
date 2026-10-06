# Proyecto de Base de Datos para un E-commerce

## Descripción general
Este proyecto fue ajustado para quedar consistente y ejecutable en MySQL 8. La versión final usa una sola base de datos, `pro_mysql2`, con tablas, relaciones, triggers, eventos, procedimientos y seguridad alineados entre todos los archivos del repositorio.

## Base de datos
- Nombre: `pro_mysql2`
- Objetivo: gestionar clientes, productos, ventas, detalle de ventas, pagos, seguridad y reportes en un sistema de e-commerce.

## Orden recomendado de ejecución
1. `01_Esquema_y_Datos.sql`
2. `02_Consultas_Avanzadas.sql`
3. `03_Funciones.sql`
4. `05_Triggers.sql`
5. `06_Eventos.sql`
6. `07_Procedimientos_Almacenados.sql`
7. `04_Seguridad.sql`

## Ejecución desde terminal
```bash
mysql -u root -p < 01_Esquema_y_Datos.sql
mysql -u root -p < 02_Consultas_Avanzadas.sql
mysql -u root -p < 03_Funciones.sql
mysql -u root -p < 05_Triggers.sql
mysql -u root -p < 06_Eventos.sql
mysql -u root -p < 07_Procedimientos_Almacenados.sql
mysql -u root -p < 04_Seguridad.sql
```

## Correcciones aplicadas
- Se unificó el nombre de la base de datos a `pro_mysql2`.
- Se corrigieron referencias a tablas inexistentes.
- Se eliminó dependencia de nombres de objetos inconsistentes entre scripts.
- Se ajustaron triggers, eventos y procedimientos para que usen la misma estructura de datos.
- Se dejó una base compatible con MySQL 8 y con permisos por roles.

## Conclusión
La estructura final quedó lista para ser ejecutada con un único esquema consistente y sin errores de integración entre archivos.

