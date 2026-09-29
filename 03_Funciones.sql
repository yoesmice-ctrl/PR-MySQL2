USE ecommerce_bd;

DELIMITER $$

CREATE FUNCTION fn_CalcularTotalVenta(id_venta_param INT) RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE total_venta DECIMAL(12,2);
    SELECT COALESCE(SUM(cantidad * precio_unitario_congelado), 0)
    INTO total_venta
    FROM detalle_ventas
    WHERE id_venta = id_venta_param;
    RETURN total_venta;
END$$

CREATE FUNCTION fn_VerificarDisponibilidadStock(id_producto_param INT, cantidad_param INT) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE stock_actual INT;
    SELECT stock INTO stock_actual FROM productos WHERE id_producto = id_producto_param;
    RETURN stock_actual >= cantidad_param;
END$$

CREATE FUNCTION fn_ObtenerPrecioProducto(id_producto_param INT) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE precio_actual DECIMAL(10,2);
    SELECT precio INTO precio_actual FROM productos WHERE id_producto = id_producto_param;
    RETURN precio_actual;
END$$

CREATE FUNCTION fn_CalcularEdadCliente(fecha_nacimiento_param DATE) RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, fecha_nacimiento_param, CURDATE());
END$$

CREATE FUNCTION fn_FormatearNombreCompleto(id_cliente_param INT) RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE nombre_completo VARCHAR(255);
    SELECT CONCAT(nombre, ' ', apellido) INTO nombre_completo FROM clientes WHERE id_cliente = id_cliente_param;
    RETURN nombre_completo;
END$$

CREATE FUNCTION fn_EsClienteNuevo(id_cliente_param INT) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE fecha_primera_compra DATETIME;
    SELECT MIN(fecha_venta) INTO fecha_primera_compra FROM ventas WHERE id_cliente = id_cliente_param;
    IF fecha_primera_compra IS NULL THEN
        RETURN FALSE;
    END IF;
    RETURN TIMESTAMPDIFF(DAY, fecha_primera_compra, NOW()) <= 30;
END$$

CREATE FUNCTION fn_CalcularCostoEnvio(peso_total DECIMAL(10,2)) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN peso_total * 0.12;
END$$

CREATE FUNCTION fn_AplicarDescuento(monto DECIMAL(12,2), porcentaje DECIMAL(5,2)) RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    RETURN monto - (monto * porcentaje / 100);
END$$

CREATE FUNCTION fn_ObtenerUltimaFechaCompra(id_cliente_param INT) RETURNS DATETIME
DETERMINISTIC
BEGIN
    DECLARE fecha_compra DATETIME;
    SELECT MAX(fecha_venta) INTO fecha_compra FROM ventas WHERE id_cliente = id_cliente_param;
    RETURN fecha_compra;
END$$

CREATE FUNCTION fn_ValidarFormatoEmail(email_param VARCHAR(150)) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    RETURN email_param REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$';
END$$

CREATE FUNCTION fn_ObtenerNombreCategoria(id_producto_param INT) RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE nombre_categoria VARCHAR(100);
    SELECT c.nombre INTO nombre_categoria
    FROM productos p
    JOIN categorias c ON c.id_categoria = p.id_categoria
    WHERE p.id_producto = id_producto_param;
    RETURN nombre_categoria;
END$$

CREATE FUNCTION fn_ContarVentasCliente(id_cliente_param INT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_ventas INT;
    SELECT COUNT(*) INTO total_ventas FROM ventas WHERE id_cliente = id_cliente_param;
    RETURN total_ventas;
END$$

CREATE FUNCTION fn_CalcularDiasDesdeUltimaCompra(id_cliente_param INT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE fecha_ultimo DATETIME;
    SELECT MAX(fecha_venta) INTO fecha_ultimo FROM ventas WHERE id_cliente = id_cliente_param;
    IF fecha_ultimo IS NULL THEN
        RETURN 0;
    END IF;
    RETURN DATEDIFF(CURDATE(), DATE(fecha_ultimo));
END$$

CREATE FUNCTION fn_DeterminarEstadoLealtad(id_cliente_param INT) RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE gasto_total DECIMAL(12,2);
    SELECT total_gastado INTO gasto_total FROM clientes WHERE id_cliente = id_cliente_param;
    IF gasto_total >= 5000 THEN
        RETURN 'Oro';
    ELSEIF gasto_total >= 2000 THEN
        RETURN 'Plata';
    ELSE
        RETURN 'Bronce';
    END IF;
END$$

CREATE FUNCTION fn_GenerarSKU(nombre_producto VARCHAR(150), categoria VARCHAR(100)) RETURNS VARCHAR(150)
DETERMINISTIC
BEGIN
    RETURN UPPER(CONCAT(SUBSTRING(REPLACE(nombre_producto, ' ', ''), 1, 5), '-', SUBSTRING(REPLACE(categoria, ' ', ''), 1, 3), '-', LPAD(FLOOR(RAND()*1000), 3, '0')));
END$$

CREATE FUNCTION fn_CalcularIVA(total_venta DECIMAL(12,2)) RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    RETURN total_venta * 0.19;
END$$

CREATE FUNCTION fn_ObtenerStockTotalPorCategoria(id_categoria_param INT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE stock_total INT;
    SELECT COALESCE(SUM(stock), 0) INTO stock_total FROM productos WHERE id_categoria = id_categoria_param;
    RETURN stock_total;
END$$

CREATE FUNCTION fn_EstimarFechaEntrega(id_cliente_param INT) RETURNS DATE
DETERMINISTIC
BEGIN
    DECLARE ciudad_cliente VARCHAR(100);
    SELECT s.ciudad INTO ciudad_cliente
    FROM clientes c
    JOIN sucursales s ON s.id_sucursal = c.id_sucursal
    WHERE c.id_cliente = id_cliente_param;
    IF ciudad_cliente = 'Bogotá' THEN
        RETURN DATE_ADD(CURDATE(), INTERVAL 3 DAY);
    ELSEIF ciudad_cliente = 'Medellín' THEN
        RETURN DATE_ADD(CURDATE(), INTERVAL 5 DAY);
    ELSE
        RETURN DATE_ADD(CURDATE(), INTERVAL 6 DAY);
    END IF;
END$$

CREATE FUNCTION fn_ConvertirMoneda(monto DECIMAL(12,2), tasa_cambio DECIMAL(10,4)) RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    RETURN monto * tasa_cambio;
END$$

CREATE FUNCTION fn_ValidarComplejidadContraseña(password_param VARCHAR(255)) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    RETURN LENGTH(password_param) >= 8 AND password_param REGEXP '[A-Z]' AND password_param REGEXP '[0-9]' AND password_param REGEXP '[^A-Za-z0-9]';
END$$

DELIMITER ;
