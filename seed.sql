USE pro_mysql2;

INSERT INTO categorias (nombre, descripcion) VALUES
('Tecnología', 'Productos electrónicos y accesorios'),
('Oficina', 'Material y accesorios para oficina'),
('Hogar', 'Productos del hogar'),
('Deportes', 'Artículos deportivos'),
('Moda', 'Ropa y accesorios');

INSERT INTO proveedores (nombre, contacto, telefono, email) VALUES
('Tech Supply', 'Ana Vega', '555-1010', 'ana@techsupply.com'),
('Office Plus', 'Luis Díaz', '555-1011', 'luis@officeplus.com'),
('Home Essentials', 'Carla Ruiz', '555-1012', 'carla@homeessentials.com');

INSERT INTO sucursales (nombre, ciudad, direccion) VALUES
('Principal Bogotá', 'Bogotá', 'Cra 10 #20-15'),
('Medellín Norte', 'Medellín', 'Cl 50 #30-40');

INSERT INTO clientes (nombre, apellido, email, telefono, direccion, direccion_envio, fecha_nacimiento, password, id_sucursal) VALUES
('Ana', 'García', 'ana.garcia@email.com', '555-2001', 'Calle 1 #10-20', 'Calle 1 #10-20', '1995-04-15', 'Pass123!', 1),
('Luis', 'Pérez', 'luis.perez@email.com', '555-2002', 'Avenida 5 #15-30', 'Avenida 5 #15-30', '1990-06-20', 'Pass123!', 1),
('María', 'López', 'maria.lopez@email.com', '555-2003', 'Carrera 7 #25-10', 'Carrera 7 #25-10', '1998-09-10', 'Pass123!', 2),
('Carlos', 'Ramírez', 'carlos.ramirez@email.com', '555-2004', 'Diagonal 9 #12-40', 'Diagonal 9 #12-40', '1989-12-03', 'Pass123!', 2),
('Sofía', 'Martínez', 'sofia.martinez@email.com', '555-2005', 'Calle 11 #8-15', 'Calle 11 #8-15', '2000-01-22', 'Pass123!', 1);

INSERT INTO empleados (nombre, apellido, cargo, email, fecha_contratacion, id_sucursal) VALUES
('Pedro', 'Castro', 'Vendedor', 'pedro.castro@email.com', '2022-02-15', 1),
('Valentina', 'Suárez', 'Supervisor', 'valentina.suarez@email.com', '2021-05-10', 1),
('Javier', 'Torres', 'Atención al cliente', 'javier.torres@email.com', '2023-01-20', 2);

INSERT INTO productos (id_categoria, id_proveedor, nombre, descripcion, precio, costo, stock, stock_minimo, ubicacion, sku) VALUES
(1, 1, 'Laptop Lenovo IdeaPad', 'Laptop para trabajo y estudio', 1200.00, 800.00, 15, 5, 'A1-01', 'LAP-001'),
(1, 1, 'Mouse Logitech', 'Mouse inalámbrico ergonómico', 35.00, 18.00, 60, 10, 'A2-05', 'MOU-002'),
(1, 1, 'Teclado Mecánico', 'Teclado gamer con switches azules', 90.00, 50.00, 25, 8, 'A2-10', 'TEK-003'),
(1, 2, 'Monitor 24 pulgadas', 'Monitor Full HD con HDMI', 250.00, 160.00, 18, 6, 'B1-04', 'MON-004'),
(2, 2, 'Impresora Multifunción', 'Impresora con escáner y copiado', 180.00, 110.00, 12, 4, 'B2-02', 'IMP-005'),
(1, 1, 'Cámara Web HD', 'Cámara para videollamadas', 70.00, 38.00, 30, 8, 'A3-02', 'CAM-006');

INSERT INTO ventas (id_cliente, id_sucursal, fecha_venta, estado, total) VALUES
(1, 1, '2026-09-01 10:15:00', 'Entregado', 0.00),
(2, 1, '2026-09-05 12:00:00', 'En proceso', 0.00),
(3, 2, '2026-09-10 09:30:00', 'Enviado', 0.00),
(4, 2, '2026-09-15 15:45:00', 'Pendiente', 0.00),
(5, 1, '2026-09-20 18:10:00', 'Entregado', 0.00);

INSERT INTO detalle_ventas (id_venta, id_producto, cantidad, precio_unitario_congelado) VALUES
(1, 1, 1, 1200.00),
(1, 2, 2, 35.00),
(2, 3, 1, 90.00),
(2, 5, 1, 180.00),
(3, 4, 1, 250.00),
(3, 6, 2, 70.00),
(4, 2, 3, 35.00),
(5, 1, 1, 1200.00),
(5, 3, 1, 90.00);

UPDATE ventas v
SET total = (
    SELECT ROUND(SUM(dv.cantidad * dv.precio_unitario_congelado), 2)
    FROM detalle_ventas dv
    WHERE dv.id_venta = v.id_venta
);

INSERT INTO pagos (id_venta, metodo_pago, monto, fecha_pago, estado) VALUES
(1, 'Tarjeta', 1270.00, '2026-09-01 11:00:00', 'Pagado'),
(2, 'Transferencia', 270.00, '2026-09-05 12:35:00', 'Pagado'),
(3, 'PayPal', 390.00, '2026-09-10 10:00:00', 'Pagado'),
(4, 'Efectivo', 105.00, '2026-09-15 16:00:00', 'Pendiente'),
(5, 'Tarjeta', 1290.00, '2026-09-20 18:40:00', 'Pagado');

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

INSERT INTO promociones (nombre, descripcion, porcentaje_descuento, fecha_inicio, fecha_fin, activo) VALUES
('Descuento Tech', 'Descuento del 10% en tecnología', 10.00, '2026-09-01 00:00:00', '2026-10-31 23:59:59', TRUE),
('Oferta Oficina', 'Descuento del 15% en oficina', 15.00, '2026-09-10 00:00:00', '2026-10-15 23:59:59', TRUE);

INSERT INTO resenas_productos (id_producto, id_cliente, calificacion, comentario) VALUES
(1, 1, 5, 'Muy buen rendimiento y calidad.'),
(2, 2, 4, 'Cumple bien con lo esperado.'),
(3, 3, 5, 'Excelente teclado para trabajar.'),
(5, 4, 3, 'Buena impresora, pero tarda un poco.');

INSERT INTO producto_categoria_count (id_categoria, total_productos)
SELECT id_categoria, COUNT(*)
FROM productos
GROUP BY id_categoria;
