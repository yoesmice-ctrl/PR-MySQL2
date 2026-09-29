USE pro_mysql2;

INSERT INTO clientes (nombre, apellido, email, telefono, direccion) VALUES
('Ana', 'García', 'ana.garcia@email.com', '555-1001', 'Calle 1 #10-20'),
('Luis', 'Pérez', 'luis.perez@email.com', '555-1002', 'Avenida 5 #15-30'),
('María', 'López', 'maria.lopez@email.com', '555-1003', 'Carrera 7 #25-10'),
('Carlos', 'Ramírez', 'carlos.ramirez@email.com', '555-1004', 'Diagonal 9 #12-40'),
('Sofía', 'Martínez', 'sofia.martinez@email.com', '555-1005', 'Calle 11 #8-15');

INSERT INTO empleados (nombre, apellido, cargo, email, fecha_contratacion) VALUES
('Pedro', 'Castro', 'Vendedor', 'pedro.castro@email.com', '2022-02-15'),
('Valentina', 'Suárez', 'Supervisor', 'valentina.suarez@email.com', '2021-05-10'),
('Javier', 'Torres', 'Atención al cliente', 'javier.torres@email.com', '2023-01-20');

INSERT INTO productos (nombre, categoria, precio, stock, descripcion) VALUES
('Laptop Lenovo IdeaPad', 'Tecnología', 1200.00, 15, 'Laptop para trabajo y estudio.'),
('Mouse Logitech', 'Tecnología', 35.00, 60, 'Mouse inalámbrico ergonómico.'),
('Teclado Mecánico', 'Tecnología', 90.00, 25, 'Teclado gamer con switches azules.'),
('Monitor 24"', 'Tecnología', 250.00, 18, 'Monitor Full HD con conexión HDMI.'),
('Impresora Multifunción', 'Oficina', 180.00, 12, 'Impresora con escáner y copiado.'),
('Cámara Web HD', 'Tecnología', 70.00, 30, 'Cámara para videollamadas y streaming.');

INSERT INTO pedidos (id_cliente, id_empleado, fecha_pedido, estado, total) VALUES
(1, 1, '2026-09-01 10:15:00', 'Entregado', 0.00),
(2, 1, '2026-09-05 12:00:00', 'En proceso', 0.00),
(3, 2, '2026-09-10 09:30:00', 'Enviado', 0.00),
(4, 3, '2026-09-15 15:45:00', 'Pendiente', 0.00),
(5, 2, '2026-09-20 18:10:00', 'Entregado', 0.00);

INSERT INTO detalle_pedidos (id_pedido, id_producto, cantidad, precio_unitario) VALUES
(1, 1, 1, 1200.00),
(1, 2, 2, 35.00),
(2, 3, 1, 90.00),
(2, 5, 1, 180.00),
(3, 4, 1, 250.00),
(3, 6, 2, 70.00),
(4, 2, 3, 35.00),
(5, 1, 1, 1200.00),
(5, 3, 1, 90.00);

UPDATE pedidos
SET total = (
    SELECT ROUND(SUM(cantidad * precio_unitario), 2)
    FROM detalle_pedidos
    WHERE detalle_pedidos.id_pedido = pedidos.id_pedido
)
WHERE id_pedido BETWEEN 1 AND 5;

INSERT INTO pagos (id_pedido, metodo_pago, monto, fecha_pago, estado) VALUES
(1, 'Tarjeta', 1270.00, '2026-09-01 11:00:00', 'Pagado'),
(2, 'Transferencia', 270.00, '2026-09-05 12:35:00', 'Pagado'),
(3, 'PayPal', 390.00, '2026-09-10 10:00:00', 'Pagado'),
(4, 'Efectivo', 105.00, '2026-09-15 16:00:00', 'Pendiente'),
(5, 'Tarjeta', 1290.00, '2026-09-20 18:40:00', 'Pagado');
