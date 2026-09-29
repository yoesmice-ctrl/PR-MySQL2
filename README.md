# Proyecto de Base de Datos para un E-commerce

<p align="center">
  <img src="https://img.shields.io/badge/MySQL-8.0+-4479A1?style=for-the-badge&logo=mysql&logoColor=white" alt="MySQL 8.0+" />
  <img src="https://img.shields.io/badge/Database-E-commerce-2E7D32?style=for-the-badge" alt="E-commerce Database" />
</p>

## Descripción general
Este proyecto consiste en el diseño e implementación de una base de datos relacional para una tienda en línea. Su objetivo es gestionar eficazmente productos, categorías, proveedores, clientes, ventas, detalle de ventas, stock, seguridad, auditorías y reportes analíticos para un sistema de comercio electrónico.

La base de datos fue diseñada teniendo en cuenta principios de integridad referencial, escalabilidad, seguridad y automatización de procesos mediante triggers, eventos y procedimientos almacenados.

## Nombre sugerido para el repositorio
Proyecto_BD_Avanzada_EquipoSQL

## Integrantes
- Nombre completo del integrante 1
- Nombre completo del integrante 2
- Nombre completo del integrante 3

## Objetivos del sistema
- Administrar el catálogo de productos.
- Organizar productos por categorías y proveedores.
- Registrar clientes y sus compras.
- Gestionar ventas y detalle de transacciones.
- Controlar el inventario y alertas de stock.
- Aplicar reglas de negocio con lógica automatizada.
- Generar reportes analíticos avanzados.
- Implementar seguridad por roles y permisos.

## Modelo de negocio
El sistema contempla las siguientes entidades principales:
- Categorías
- Proveedores
- Sucursales
- Productos
- Clientes
- Ventas
- Detalle de ventas
- Promociones
- Reseñas de productos

## Estructura del repositorio

| Archivo | Descripción |
|---|---|
| `01_Esquema_y_Datos.sql` | Creación de la base de datos, tablas, relaciones y datos iniciales. |
| `02_Consultas_Avanzadas.sql` | 20 consultas analíticas y de reporteo. |
| `03_Funciones.sql` | 20 funciones definidas por el usuario. |
| `04_Seguridad.sql` | Roles, usuarios, permisos y vista de seguridad. |
| `05_Triggers.sql` | 20 triggers y auditoría automatizada. |
| `06_Eventos.sql` | 20 eventos programados para mantenimiento y reportes. |
| `07_Procedimientos_Almacenados.sql` | 20 procedimientos almacenados con lógica transaccional. |
| `README.md` | Documentación principal del proyecto. |

## Requisitos previos
- MySQL 8.0 o superior
- Permisos de administrador para crear bases de datos, roles y eventos
- MySQL Workbench o acceso a línea de comandos
- Event Scheduler habilitado en el servidor

## Orden de ejecución
Para recrear correctamente la base de datos, se recomienda ejecutar los scripts en el siguiente orden:

1. `01_Esquema_y_Datos.sql`
2. `02_Consultas_Avanzadas.sql`
3. `03_Funciones.sql`
4. `04_Seguridad.sql`
5. `05_Triggers.sql`
6. `06_Eventos.sql`
7. `07_Procedimientos_Almacenados.sql`

## Ejecución con MySQL Workbench
1. Abrir MySQL Workbench.
2. Conectarse al servidor MySQL.
3. Ejecutar cada archivo `.sql` en orden.

## Ejecución desde terminal
```bash
mysql -u root -p < 01_Esquema_y_Datos.sql
mysql -u root -p < 02_Consultas_Avanzadas.sql
mysql -u root -p < 03_Funciones.sql
mysql -u root -p < 04_Seguridad.sql
mysql -u root -p < 05_Triggers.sql
mysql -u root -p < 06_Eventos.sql
mysql -u root -p < 07_Procedimientos_Almacenados.sql
```

## Ejecución manual en MySQL
```sql
CREATE DATABASE ecommerce_bd;
USE ecommerce_bd;
SOURCE 01_Esquema_y_Datos.sql;
SOURCE 02_Consultas_Avanzadas.sql;
SOURCE 03_Funciones.sql;
SOURCE 04_Seguridad.sql;
SOURCE 05_Triggers.sql;
SOURCE 06_Eventos.sql;
SOURCE 07_Procedimientos_Almacenados.sql;
```

## Validaciones incluidas
El proyecto cubre los siguientes aspectos clave:
- diseño relacional y normalización básica,
- integridad referencial,
- registro de datos iniciales,
- consultas avanzadas de analítica,
- funciones reutilizables,
- seguridad por roles,
- triggers y auditorías,
- eventos automatizados,
- procedimientos almacenados para lógica de negocio.

## Recomendaciones para entrega en GitHub
Antes de publicar el repositorio, se recomienda:
- crear un repositorio privado con nombre: `Proyecto_BD_Avanzada_EquipoSQL`,
- invitar al trainer como colaborador con permisos de lectura,
- mantener este README como portada del proyecto,
- documentar claramente el orden de ejecución para quien clone el repositorio.

## Siguiente paso recomendado
1. Inicializar el repositorio local.
2. Realizar el primer commit.
3. Crear el repositorio remoto en GitHub.
4. Hacer push de los archivos.
5. Invitar al trainer como colaborador.

## Conclusión
Este proyecto representa una base sólida para una entrega académica o profesional centrada en una base de datos para e-commerce, con enfoque en diseño, funcionalidad y administración de datos en MySQL.

> Está listo para ser presentado como proyecto final de base de datos avanzada.

