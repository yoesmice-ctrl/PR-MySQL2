DROP DATABASE IF EXISTS ecommerce_bd;
CREATE DATABASE ecommerce_bd CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ecommerce_bd;

SET NAMES utf8mb4;

CREATE TABLE categorias (
    id_categoria INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    PRIMARY KEY (id_categoria)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE proveedores (
    id_proveedor INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(150) NOT NULL,
    email_contacto VARCHAR(150) NOT NULL UNIQUE,
    telefono_contacto VARCHAR(30),
    PRIMARY KEY (id_proveedor)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE sucursales (
    id_sucursal INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    ciudad VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_sucursal)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE clientes (
    id_cliente INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    direccion_envio TEXT,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_nacimiento DATE NULL,
    total_gastado DECIMAL(12,2) NOT NULL DEFAULT 0,
    fecha_ultimo_pedido DATETIME NULL,
    id_sucursal INT NULL,
    PRIMARY KEY (id_cliente),
    CONSTRAINT fk_clientes_sucursal FOREIGN KEY (id_sucursal)
        REFERENCES sucursales(id_sucursal)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE productos (
    id_producto INT NOT NULL AUTO_INCREMENT,
    id_categoria INT NOT NULL,
    id_proveedor INT NOT NULL,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    costo DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (costo >= 0),
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    sku VARCHAR(100) NOT NULL UNIQUE,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_ultima_modificacion DATETIME NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    stock_minimo INT NOT NULL DEFAULT 5,
    ubicacion VARCHAR(120) DEFAULT 'Bodega Central',
    PRIMARY KEY (id_producto),
    CONSTRAINT fk_productos_categoria FOREIGN KEY (id_categoria)
        REFERENCES categorias(id_categoria)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_productos_proveedor FOREIGN KEY (id_proveedor)
        REFERENCES proveedores(id_proveedor)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE ventas (
    id_venta INT NOT NULL AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    id_sucursal INT NOT NULL,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('Pendiente de Pago','Procesando','Enviado','Entregado','Cancelado') NOT NULL DEFAULT 'Pendiente de Pago',
    total DECIMAL(12,2) NOT NULL DEFAULT 0,
    PRIMARY KEY (id_venta),
    CONSTRAINT fk_ventas_cliente FOREIGN KEY (id_cliente)
        REFERENCES clientes(id_cliente)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_ventas_sucursal FOREIGN KEY (id_sucursal)
        REFERENCES sucursales(id_sucursal)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE detalle_ventas (
    id_detalle INT NOT NULL AUTO_INCREMENT,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario_congelado DECIMAL(10,2) NOT NULL CHECK (precio_unitario_congelado > 0),
    PRIMARY KEY (id_detalle),
    CONSTRAINT fk_detalle_venta FOREIGN KEY (id_venta)
        REFERENCES ventas(id_venta)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_detalle_producto FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE promociones (
    id_promocion INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(150) NOT NULL,
    porcentaje_descuento DECIMAL(5,2) NOT NULL DEFAULT 0,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id_promocion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE clientes_referidos (
    id_referencia INT NOT NULL AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    id_cliente_referido INT NOT NULL,
    PRIMARY KEY (id_referencia),
    CONSTRAINT fk_referencia_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    CONSTRAINT fk_referencia_referido FOREIGN KEY (id_cliente_referido) REFERENCES clientes(id_cliente)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE log_cambios_precio (
    id_log INT NOT NULL AUTO_INCREMENT,
    id_producto INT NOT NULL,
    precio_anterior DECIMAL(10,2) NOT NULL,
    precio_nuevo DECIMAL(10,2) NOT NULL,
    fecha_cambio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_log),
    CONSTRAINT fk_log_precio_producto FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE alertas_stock (
    id_alerta INT NOT NULL AUTO_INCREMENT,
    id_producto INT NOT NULL,
    mensaje VARCHAR(255) NOT NULL,
    fecha_alerta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_alerta),
    CONSTRAINT fk_alerta_producto FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE auditoria_pedidos (
    id_auditoria INT NOT NULL AUTO_INCREMENT,
    id_venta INT NOT NULL,
    estado_anterior VARCHAR(50),
    estado_nuevo VARCHAR(50),
    fecha_cambio DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_auditoria),
    CONSTRAINT fk_auditoria_venta FOREIGN KEY (id_venta)
        REFERENCES ventas(id_venta)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE auditoria_permisos (
    id_auditoria_permiso INT NOT NULL AUTO_INCREMENT,
    usuario VARCHAR(100) NOT NULL,
    accion VARCHAR(100) NOT NULL,
    fecha_cambio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    detalle VARCHAR(255),
    PRIMARY KEY (id_auditoria_permiso)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE venta_archivada (
    id_venta_archivada INT NOT NULL AUTO_INCREMENT,
    id_venta INT NOT NULL,
    motivo VARCHAR(200),
    fecha_archivo DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_venta_archivada)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE producto_categoria_count (
    id_categoria INT NOT NULL,
    total_productos INT NOT NULL DEFAULT 0,
    PRIMARY KEY (id_categoria),
    CONSTRAINT fk_count_categoria FOREIGN KEY (id_categoria)
        REFERENCES categorias(id_categoria)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE auditoria_login (
    id_auditoria_login INT NOT NULL AUTO_INCREMENT,
    usuario VARCHAR(100) NOT NULL,
    fecha INT NOT NULL,
    intento_exitoso BOOLEAN NOT NULL,
    ip VARCHAR(45),
    detalle VARCHAR(255),
    PRIMARY KEY (id_auditoria_login)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE resenas_productos (
    id_resena INT NOT NULL AUTO_INCREMENT,
    id_producto INT NOT NULL,
    id_cliente INT NOT NULL,
    calificacion INT NOT NULL CHECK (calificacion BETWEEN 1 AND 5),
    comentario TEXT,
    fecha_resena DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_resena),
    CONSTRAINT fk_resena_producto FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_resena_cliente FOREIGN KEY (id_cliente)
        REFERENCES clientes(id_cliente)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE reporte_ventas_semanales (
    id_reporte INT NOT NULL AUTO_INCREMENT,
    semana VARCHAR(20),
    total_ventas DECIMAL(12,2) DEFAULT 0,
    total_clientes INT DEFAULT 0,
    fecha_generado DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_reporte)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO sucursales (nombre, ciudad) VALUES
('Casa Matriz', 'Bogota'),
('Sucursal Norte', 'Medellin'),
('Sucursal Sur', 'Cali');

INSERT INTO categorias (nombre, descripcion) VALUES
('Electronica', 'Dispositivos y equipos digitales.'),
('Ropa', 'Prendas y accesorios de moda.'),
('Hogar', 'Articulos para el hogar y oficina.'),
('Deportes', 'Equipos y accesorios deportivos.');

INSERT INTO proveedores (nombre, email_contacto, telefono_contacto) VALUES
('TechSupply S.A.S.', 'ventas@techsupply.com', '3001112233'),
('Moda Norte Ltda.', 'info@modanorte.com', '3012223344'),
('HomePlus Co.', 'ventas@homeplus.com', '3023334455'),
('SportWorld', 'contacto@sportworld.com', '3034445566');

INSERT INTO clientes (nombre, apellido, email, password, direccion_envio, fecha_registro, fecha_nacimiento, id_sucursal) VALUES
('Ana', 'Garcia', 'ana.garcia@email.com', 'hash_ana', 'Calle 10 #20-30, Bogota', '2024-01-15 10:00:00', '1992-05-20', 1),
('Luis', 'Perez', 'luis.perez@email.com', 'hash_luis', 'Carrera 5 #15-10, Medellin', '2024-02-10 11:00:00', '1988-11-12', 2),
('Maria', 'Lopez', 'maria.lopez@email.com', 'hash_maria', 'Avenida 9 #99-12, Cali', '2024-03-20 08:30:00', '1995-08-03', 3),
('Carlos', 'Ramirez', 'carlos.ramirez@email.com', 'hash_carlos', 'Diagonal 25 #13-44, Bogota', '2024-04-05 15:40:00', '1990-02-18', 1),
('Sofia', 'Martinez', 'sofia.martinez@email.com', 'hash_sofia', 'Calle 50 #60-30, Bogota', '2024-05-11 09:15:00', '1993-07-22', 1),
('Mateo', 'Castro', 'mateo.castro@email.com', 'hash_mateo', 'Carrera 70 #8-10, Medellin', '2024-06-07 12:15:00', '1987-09-15', 2),
('Valeria', 'Sanchez', 'valeria.sanchez@email.com', 'hash_valeria', 'Avenida 14 #40-20, Cali', '2024-07-31 16:45:00', '1991-12-09', 3),
('Daniel', 'Ortiz', 'daniel.ortiz@email.com', 'hash_daniel', 'Calle 3 #11-23, Bogota', '2024-08-14 18:20:00', '1989-04-25', 1);

INSERT INTO productos (id_categoria, id_proveedor, nombre, descripcion, precio, costo, stock, sku, activo, stock_minimo, ubicacion) VALUES
(1, 1, 'Laptop X15', 'Laptop de alto rendimiento para trabajo y estudio.', 2200.00, 1600.00, 12, 'LAP-X15-001', TRUE, 4, 'A1-01'),
(1, 1, 'Mouse Gamer Pro', 'Mouse ergonomico con sensor de alta precision.', 75.00, 35.00, 80, 'MOU-GPR-005', TRUE, 15, 'B2-10'),
(2, 2, 'Camiseta Basica', 'Camiseta de algodon, corte regular.', 35.00, 14.00, 120, 'ROPA-CAM-020', TRUE, 25, 'C1-04'),
(2, 2, 'Chaqueta Deportiva', 'Chaqueta ligera y comoda para uso diario.', 140.00, 75.00, 40, 'ROPA-CHA-045', TRUE, 10, 'C2-02'),
(3, 3, 'Lampara LED', 'Luz LED de bajo consumo para escritorio.', 60.00, 30.00, 55, 'HOG-LED-110', TRUE, 12, 'D1-06'),
(4, 4, 'Balon Futbol', 'Balon de futbol profesional para entrenamiento.', 90.00, 55.00, 30, 'DEP-BAL-200', TRUE, 8, 'E1-03');

INSERT INTO ventas (id_cliente, id_sucursal, fecha_venta, estado, total) VALUES
(1, 1, '2024-01-20 09:30:00', 'Entregado', 0),
(2, 2, '2024-02-18 10:00:00', 'Enviado', 0),
(1, 1, '2024-03-12 11:15:00', 'Entregado', 0),
(3, 3, '2024-04-15 14:45:00', 'Procesando', 0),
(4, 1, '2024-05-25 16:10:00', 'Pendiente de Pago', 0),
(5, 1, '2024-06-08 18:40:00', 'Entregado', 0),
(6, 2, '2024-08-01 09:05:00', 'Cancelado', 0),
(7, 3, '2024-09-05 12:00:00', 'Entregado', 0),
(8, 1, '2024-10-20 15:25:00', 'Enviado', 0),
(1, 1, '2024-11-11 09:00:00', 'Entregado', 0);

INSERT INTO detalle_ventas (id_venta, id_producto, cantidad, precio_unitario_congelado) VALUES
(1, 1, 1, 2200.00),
(1, 2, 2, 75.00),
(2, 3, 3, 35.00),
(2, 5, 1, 60.00),
(3, 1, 1, 2200.00),
(4, 4, 1, 140.00),
(4, 6, 2, 90.00),
(5, 2, 5, 75.00),
(6, 3, 4, 35.00),
(6, 4, 1, 140.00),
(7, 6, 1, 90.00),
(8, 5, 3, 60.00),
(9, 1, 1, 2200.00),
(10, 2, 4, 75.00),
(10, 3, 2, 35.00);

UPDATE ventas v
SET total = (
    SELECT ROUND(SUM(dv.cantidad * dv.precio_unitario_congelado), 2)
    FROM detalle_ventas dv
    WHERE dv.id_venta = v.id_venta
);

UPDATE clientes c
SET total_gastado = (
    SELECT COALESCE(SUM(v.total), 0)
    FROM ventas v
    WHERE v.id_cliente = c.id_cliente
),
fecha_ultimo_pedido = (
    SELECT MAX(v.fecha_venta)
    FROM ventas v
    WHERE v.id_cliente = c.id_cliente
);

INSERT INTO promociones (nombre, porcentaje_descuento, fecha_inicio, fecha_fin, activo) VALUES
('Black Friday', 15.00, '2024-11-15 00:00:00', '2024-11-30 23:59:59', TRUE),
('Navidad', 10.00, '2024-12-01 00:00:00', '2024-12-25 23:59:59', TRUE),
('Semana Tecnologica', 20.00, '2024-08-10 00:00:00', '2024-08-20 23:59:59', FALSE);

INSERT INTO clientes_referidos (id_cliente, id_cliente_referido) VALUES
(1, 2),
(2, 3),
(4, 5),
(6, 8);

INSERT INTO resenas_productos (id_producto, id_cliente, calificacion, comentario) VALUES
(1, 1, 5, 'Excelente producto y muy buen rendimiento.'),
(2, 2, 4, 'Buen mouse para gaming.'),
(3, 3, 5, 'Muy comoda y buena calidad.'),
(4, 4, 4, 'Satisfecho con la compra.'),
(5, 5, 3, 'Cumple bien su funcion.'),
(6, 6, 5, 'Muy buena relacion calidad-precio.');

SELECT 'Esquema y datos cargados correctamente.' AS estado;
