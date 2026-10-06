USE pro_mysql2;

-- 1. Productos más vendidos por unidades
SELECT p.id_producto, p.nombre, SUM(dv.cantidad) AS unidades_vendidas
FROM detalle_ventas dv
JOIN productos p ON p.id_producto = dv.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY unidades_vendidas DESC
LIMIT 10;

-- 2. Productos con menor volumen de ventas
SELECT p.id_producto, p.nombre, COALESCE(SUM(dv.cantidad), 0) AS unidades_vendidas
FROM productos p
LEFT JOIN detalle_ventas dv ON dv.id_producto = p.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY unidades_vendidas ASC
LIMIT 10;

-- 3. Clientes con mayor gasto total
SELECT id_cliente, nombre, apellido, total_gastado
FROM clientes
ORDER BY total_gastado DESC
LIMIT 5;

-- 4. Ventas mensuales
SELECT DATE_FORMAT(fecha_venta, '%Y-%m') AS mes, SUM(total) AS total_ventas
FROM ventas
GROUP BY DATE_FORMAT(fecha_venta, '%Y-%m')
ORDER BY mes;

-- 5. Nuevos clientes por trimestre
SELECT CONCAT(YEAR(fecha_registro), '-Q', QUARTER(fecha_registro)) AS trimestre,
       COUNT(*) AS nuevos_clientes
FROM clientes
GROUP BY CONCAT(YEAR(fecha_registro), '-Q', QUARTER(fecha_registro))
ORDER BY trimestre;

-- 6. Porcentaje de clientes con más de una compra
SELECT (COUNT(DISTINCT CASE WHEN total_compras > 1 THEN id_cliente END) * 100.0) / NULLIF(COUNT(DISTINCT id_cliente), 0) AS porcentaje_compra_repetida
FROM (
    SELECT v.id_cliente, COUNT(*) AS total_compras
    FROM ventas v
    GROUP BY v.id_cliente
) t;

-- 7. Productos comprados juntos
SELECT dv1.id_producto AS producto_a,
       dv2.id_producto AS producto_b,
       COUNT(*) AS veces_juntos
FROM detalle_ventas dv1
JOIN detalle_ventas dv2
  ON dv1.id_venta = dv2.id_venta
 AND dv1.id_producto < dv2.id_producto
GROUP BY dv1.id_producto, dv2.id_producto
ORDER BY veces_juntos DESC
LIMIT 10;

-- 8. Rotación por categoría
SELECT c.nombre AS categoria,
       ROUND(COALESCE(SUM(dv.cantidad),0) / NULLIF(COUNT(DISTINCT p.id_producto),0), 2) AS rotacion
FROM categorias c
LEFT JOIN productos p ON p.id_categoria = c.id_categoria
LEFT JOIN detalle_ventas dv ON dv.id_producto = p.id_producto
GROUP BY c.id_categoria, c.nombre
ORDER BY rotacion DESC;

-- 9. Productos por debajo del stock mínimo
SELECT p.id_producto, p.nombre, p.stock, p.stock_minimo
FROM productos p
WHERE p.stock < p.stock_minimo
ORDER BY p.stock ASC;

-- 10. Ventas por sucursal
SELECT s.ciudad, SUM(v.total) AS total_ventas
FROM ventas v
JOIN sucursales s ON s.id_sucursal = v.id_sucursal
GROUP BY s.ciudad
ORDER BY total_ventas DESC;

-- 11. Rendimiento por proveedor
SELECT pr.id_proveedor, pr.nombre,
       SUM(dv.cantidad * dv.precio_unitario_congelado) AS volumen
FROM proveedores pr
JOIN productos p ON p.id_proveedor = pr.id_proveedor
JOIN detalle_ventas dv ON dv.id_producto = p.id_producto
GROUP BY pr.id_proveedor, pr.nombre
ORDER BY volumen DESC;

-- 12. Ventas por hora del día
SELECT HOUR(fecha_venta) AS hora_dia, COUNT(*) AS total_ventas
FROM ventas
GROUP BY HOUR(fecha_venta)
ORDER BY total_ventas DESC;

-- 13. Estado de pedidos por cliente
SELECT c.id_cliente, c.nombre, c.apellido, COUNT(v.id_venta) AS total_pedidos,
       SUM(CASE WHEN v.estado = 'Entregado' THEN 1 ELSE 0 END) AS entregados
FROM clientes c
LEFT JOIN ventas v ON v.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellido
ORDER BY total_pedidos DESC;

-- 14. Margen bruto por producto
SELECT p.id_producto, p.nombre,
       ROUND(((p.precio - p.costo) / p.precio) * 100, 2) AS margen_porcentaje
FROM productos p
ORDER BY margen_porcentaje DESC;

-- 15. Promedio de calificación por producto
SELECT p.id_producto, p.nombre, ROUND(AVG(r.calificacion), 2) AS promedio_calificacion
FROM productos p
LEFT JOIN resenas_productos r ON r.id_producto = p.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY promedio_calificacion DESC;

-- 16. Ventas por cliente y sucursal
SELECT v.id_cliente, s.ciudad, SUM(v.total) AS total_ventas
FROM ventas v
JOIN sucursales s ON s.id_sucursal = v.id_sucursal
GROUP BY v.id_cliente, s.ciudad
ORDER BY total_ventas DESC;

-- 17. Clientes con mayor frecuencia de compra
SELECT c.id_cliente, c.nombre, c.apellido, COUNT(v.id_venta) AS compras
FROM clientes c
LEFT JOIN ventas v ON v.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellido
ORDER BY compras DESC
LIMIT 10;

-- 18. Productos con promedio de reseña alta
SELECT p.id_producto, p.nombre, ROUND(AVG(r.calificacion),2) AS promedio_resena
FROM productos p
JOIN resenas_productos r ON r.id_producto = p.id_producto
GROUP BY p.id_producto, p.nombre
HAVING AVG(r.calificacion) >= 4
ORDER BY promedio_resena DESC;

-- 19. Estado actual de stock por categoría
SELECT c.nombre AS categoria,
       SUM(p.stock) AS stock_total,
       SUM(CASE WHEN p.stock < p.stock_minimo THEN 1 ELSE 0 END) AS productos_bajo_stock
FROM categorias c
LEFT JOIN productos p ON p.id_categoria = c.id_categoria
GROUP BY c.id_categoria, c.nombre
ORDER BY stock_total DESC;

-- 20. Top 10 productos por ingreso
SELECT p.id_producto, p.nombre, ROUND(SUM(dv.cantidad * dv.precio_unitario_congelado), 2) AS ingresos
FROM detalle_ventas dv
JOIN productos p ON p.id_producto = dv.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY ingresos DESC
LIMIT 10;
