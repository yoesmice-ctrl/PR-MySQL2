USE pro_mysql2;

DELIMITER $$

-- Eliminar la función si ya existe para permitir ejecuciones repetidas del script.
DROP FUNCTION IF EXISTS fn_CalcularRentabilidadProducto$$

-- Función que calcula la rentabilidad total acumulada de un producto.
-- La lógica consiste en:
-- 1. Recorrer todos los detalles de venta del producto.
-- 2. Restar el costo del producto al precio unitario congelado de cada venta.
-- 3. Multiplicar por la cantidad vendida en ese detalle.
-- 4. Sumar todos los márgenes para obtener la rentabilidad total.
CREATE FUNCTION fn_CalcularRentabilidadProducto(p_id_producto INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE v_rentabilidad_total DECIMAL(12,2);

    -- Si el producto no existe, la rentabilidad es cero.
    IF NOT EXISTS (SELECT 1 FROM productos WHERE id_producto = p_id_producto) THEN
        RETURN 0;
    END IF;

    SELECT COALESCE(
            SUM((dv.precio_unitario_congelado - p.costo) * dv.cantidad),
            0
        )
    INTO v_rentabilidad_total
    FROM detalle_ventas dv
    INNER JOIN productos p
        ON p.id_producto = dv.id_producto
    WHERE dv.id_producto = p_id_producto;

    RETURN v_rentabilidad_total;
END$$

DELIMITER ;

-- Ejemplo de uso:
-- SELECT fn_CalcularRentabilidadProducto(1) AS rentabilidad_total;
