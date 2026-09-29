USE ecommerce_bd;

-- 1. Listado de clientes
SELECT *
FROM clientes;

-- 2. Ventas con nombre del cliente y sucursal
SELECT v.id_venta, c.nombre, c.apellido, s.nombre AS sucursal, v.fecha_venta, v.estado, v.total
FROM ventas v
JOIN clientes c ON c.id_cliente = v.id_cliente
JOIN sucursales s ON s.id_sucursal = v.id_sucursal
ORDER BY v.fecha_venta DESC;

-- 3. Productos mas vendidos
SELECT p.nombre, SUM(dv.cantidad) AS cantidad_total
FROM detalle_ventas dv
JOIN productos p ON p.id_producto = dv.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY cantidad_total DESC;

-- 4. Total gastado por cliente
SELECT c.nombre, c.apellido, c.total_gastado
FROM clientes c
ORDER BY c.total_gastado DESC;

-- 5. Ventas pendientes o en proceso
SELECT *
FROM ventas
WHERE estado IN ('Pendiente de Pago', 'Procesando');

-- 6. Resumen de ventas por sucursal
SELECT s.nombre AS sucursal, COUNT(v.id_venta) AS total_ventas, SUM(v.total) AS monto_total
FROM sucursales s
LEFT JOIN ventas v ON v.id_sucursal = s.id_sucursal
GROUP BY s.id_sucursal, s.nombre
ORDER BY monto_total DESC;

-- 7. Top 5 productos con mayor precio
SELECT nombre, precio
FROM productos
ORDER BY precio DESC
LIMIT 5;

-- 8. Inventario actual con stock minimo
SELECT p.nombre, p.stock, p.stock_minimo, p.ubicacion
FROM productos p
ORDER BY p.stock ASC;

-- 9. Clientes con mas compras
SELECT c.nombre, c.apellido, COUNT(v.id_venta) AS cantidad_ventas
FROM clientes c
LEFT JOIN ventas v ON v.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellido
ORDER BY cantidad_ventas DESC;

-- 10. Promedio de calificacion por producto
SELECT p.nombre, ROUND(AVG(r.calificacion), 2) AS promedio_calificacion
FROM resenas_productos r
JOIN productos p ON p.id_producto = r.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY promedio_calificacion DESC;
