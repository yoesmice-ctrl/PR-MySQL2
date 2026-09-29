USE ecommerce_bd;

-- 1. Top 10 productos mas vendidos por ingresos
SELECT p.id_producto, p.nombre,
       SUM(dv.cantidad) AS unidades_vendidas,
       SUM(dv.cantidad * dv.precio_unitario_congelado) AS ingresos
FROM detalle_ventas dv
JOIN productos p ON p.id_producto = dv.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY ingresos DESC
LIMIT 10;

-- 2. Productos con bajas ventas
WITH ventas_producto AS (
    SELECT p.id_producto, p.nombre, COALESCE(SUM(dv.cantidad), 0) AS unidades_vendidas
    FROM productos p
    LEFT JOIN detalle_ventas dv ON dv.id_producto = p.id_producto
    GROUP BY p.id_producto, p.nombre
), ranking AS (
    SELECT *, NTILE(10) OVER (ORDER BY unidades_vendidas ASC) AS percentil
    FROM ventas_producto
)
SELECT *
FROM ranking
WHERE percentil = 1;

-- 3. Clientes VIP por gasto total
SELECT c.id_cliente, c.nombre, c.apellido, c.total_gastado AS ltv
FROM clientes c
ORDER BY c.total_gastado DESC
LIMIT 5;

-- 4. Ventas mensuales totales
SELECT DATE_FORMAT(fecha_venta, '%Y-%m') AS mes_venta, SUM(total) AS total_ventas
FROM ventas
GROUP BY DATE_FORMAT(fecha_venta, '%Y-%m')
ORDER BY mes_venta;

-- 5. Nuevos clientes por trimestre
SELECT CONCAT(YEAR(fecha_registro), '-Q', QUARTER(fecha_registro)) AS trimestre,
       COUNT(*) AS nuevos_clientes
FROM clientes
GROUP BY CONCAT(YEAR(fecha_registro), '-Q', QUARTER(fecha_registro))
ORDER BY trimestre;

-- 6. Porcentaje de clientes con compra repetida
SELECT (
    (SELECT COUNT(*) FROM (
        SELECT id_cliente
        FROM ventas
        GROUP BY id_cliente
        HAVING COUNT(*) > 1
    ) t) * 100.0 / NULLIF(COUNT(*), 0)
) AS porcentaje_compra_repetida
FROM clientes;

-- 7. Productos comprados juntos en la misma venta
SELECT dv1.id_producto AS producto_a,
       dv2.id_producto AS producto_b,
       COUNT(*) AS veces_juntos
FROM detalle_ventas dv1
JOIN detalle_ventas dv2 ON dv1.id_venta = dv2.id_venta AND dv1.id_producto < dv2.id_producto
GROUP BY dv1.id_producto, dv2.id_producto
ORDER BY veces_juntos DESC
LIMIT 10;

-- 8. Rotacion de inventario por categoria
SELECT c.nombre AS categoria,
       ROUND((SUM(dv.cantidad) / NULLIF(SUM(p.stock), 0)), 2) AS rotacion_inventario
FROM categorias c
LEFT JOIN productos p ON p.id_categoria = c.id_categoria
LEFT JOIN detalle_ventas dv ON dv.id_producto = p.id_producto
GROUP BY c.id_categoria, c.nombre
ORDER BY rotacion_inventario DESC;

-- 9. Productos por debajo del stock minimo
SELECT p.id_producto, p.nombre, p.stock, p.stock_minimo, p.ubicacion
FROM productos p
WHERE p.stock < p.stock_minimo
ORDER BY p.stock ASC;

-- 10. Simulacion de carrito abandonado
SELECT c.id_cliente, c.nombre, c.apellido, COUNT(*) AS productos_en_carrito
FROM clientes c
JOIN resenas_productos r ON r.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellido
HAVING COUNT(*) > 0;

-- 11. Rendimiento de proveedores
SELECT pr.id_proveedor, pr.nombre,
       SUM(dv.cantidad * dv.precio_unitario_congelado) AS volumen_ventas
FROM proveedores pr
JOIN productos p ON p.id_proveedor = pr.id_proveedor
JOIN detalle_ventas dv ON dv.id_producto = p.id_producto
GROUP BY pr.id_proveedor, pr.nombre
ORDER BY volumen_ventas DESC;

-- 12. Ventas por ciudad
SELECT s.ciudad, SUM(v.total) AS total_ventas
FROM ventas v
JOIN sucursales s ON s.id_sucursal = v.id_sucursal
GROUP BY s.ciudad
ORDER BY total_ventas DESC;

-- 13. Ventas por hora del dia
SELECT HOUR(fecha_venta) AS hora_dia, COUNT(*) AS cantidad_ventas
FROM ventas
GROUP BY HOUR(fecha_venta)
ORDER BY cantidad_ventas DESC;

-- 14. Impacto de promociones
SELECT p.nombre,
       SUM(CASE WHEN v.fecha_venta < '2024-11-15' THEN dv.cantidad * dv.precio_unitario_congelado ELSE 0 END) AS ventas_antes,
       SUM(CASE WHEN v.fecha_venta BETWEEN '2024-11-15' AND '2024-11-30' THEN dv.cantidad * dv.precio_unitario_congelado ELSE 0 END) AS ventas_durante,
       SUM(CASE WHEN v.fecha_venta > '2024-11-30' THEN dv.cantidad * dv.precio_unitario_congelado ELSE 0 END) AS ventas_despues
FROM ventas v
JOIN detalle_ventas dv ON dv.id_venta = v.id_venta
JOIN productos p ON p.id_producto = dv.id_producto
GROUP BY p.nombre;

-- 15. Analisis de cohorte
SELECT DATE_FORMAT(MIN(v.fecha_venta), '%Y-%m') AS mes_primera_compra,
       DATE_FORMAT(v.fecha_venta, '%Y-%m') AS mes_compra,
       COUNT(DISTINCT v.id_cliente) AS clientes_activos
FROM ventas v
GROUP BY DATE_FORMAT(v.fecha_venta, '%Y-%m')
ORDER BY mes_primera_compra, mes_compra;

-- 16. Margen de beneficio por producto
SELECT p.id_producto, p.nombre,
       ROUND(((p.precio - p.costo) / p.precio) * 100, 2) AS margen_porcentaje
FROM productos p
ORDER BY margen_porcentaje DESC;

-- 17. Tiempo promedio entre compras
SELECT c.id_cliente, c.nombre, c.apellido,
       AVG(DATEDIFF(v2.fecha_venta, v1.fecha_venta)) AS dias_promedio_entre_compras
FROM ventas v1
JOIN ventas v2 ON v2.id_cliente = v1.id_cliente AND v2.id_venta > v1.id_venta
JOIN clientes c ON c.id_cliente = v1.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellido;

-- 18. Productos mas vistos vs comprados
SELECT p.nombre,
       COALESCE(SUM(dv.cantidad), 0) AS comprados,
       COUNT(r.id_resena) AS vistos_simulados
FROM productos p
LEFT JOIN detalle_ventas dv ON dv.id_producto = p.id_producto
LEFT JOIN resenas_productos r ON r.id_producto = p.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY comprados DESC;

-- 19. Segmentacion RFM
SELECT c.id_cliente,
       c.nombre,
       c.apellido,
       DATEDIFF(CURDATE(), MAX(v.fecha_venta)) AS recencia,
       COUNT(v.id_venta) AS frecuencia,
       c.total_gastado AS monetario,
       CASE
           WHEN DATEDIFF(CURDATE(), MAX(v.fecha_venta)) <= 30 AND COUNT(v.id_venta) >= 2 THEN 'VIP'
           WHEN DATEDIFF(CURDATE(), MAX(v.fecha_venta)) <= 60 THEN 'Activos'
           ELSE 'En riesgo'
       END AS segmento
FROM clientes c
LEFT JOIN ventas v ON v.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellido, c.total_gastado
ORDER BY segmento, monetario DESC;

-- 20. Proyeccion simple de demanda
SELECT c.nombre AS categoria,
       ROUND(AVG(dv.cantidad), 2) * 30 AS demanda_proyectada_mensual
FROM detalle_ventas dv
JOIN productos p ON p.id_producto = dv.id_producto
JOIN categorias c ON c.id_categoria = p.id_categoria
GROUP BY c.id_categoria, c.nombre
ORDER BY demanda_proyectada_mensual DESC;
