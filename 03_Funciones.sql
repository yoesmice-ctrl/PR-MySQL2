USE pro_mysql2;

DELIMITER $$

DROP FUNCTION IF EXISTS fn_total_venta_cliente$$
CREATE FUNCTION fn_total_venta_cliente(p_id_cliente INT) RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE total_venta DECIMAL(12,2);
    SELECT COALESCE(SUM(total), 0) INTO total_venta
    FROM ventas
    WHERE id_cliente = p_id_cliente;
    RETURN total_venta;
END$$

DROP FUNCTION IF EXISTS fn_stock_disponible$$
CREATE FUNCTION fn_stock_disponible(p_id_producto INT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE stock_actual INT;
    SELECT stock INTO stock_actual
    FROM productos
    WHERE id_producto = p_id_producto;
    RETURN stock_actual;
END$$

DROP FUNCTION IF EXISTS fn_nombre_completo_cliente$$
CREATE FUNCTION fn_nombre_completo_cliente(p_id_cliente INT) RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE nombre_completo VARCHAR(255);
    SELECT CONCAT(nombre, ' ', apellido) INTO nombre_completo
    FROM clientes
    WHERE id_cliente = p_id_cliente;
    RETURN nombre_completo;
END$$

DROP FUNCTION IF EXISTS fn_edad_cliente$$
CREATE FUNCTION fn_edad_cliente(fecha_nacimiento_param DATE) RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, fecha_nacimiento_param, CURDATE());
END$$

DROP FUNCTION IF EXISTS fn_ultima_compra_cliente$$
CREATE FUNCTION fn_ultima_compra_cliente(p_id_cliente INT) RETURNS DATETIME
DETERMINISTIC
BEGIN
    DECLARE fecha_compra DATETIME;
    SELECT MAX(fecha_venta) INTO fecha_compra
    FROM ventas
    WHERE id_cliente = p_id_cliente;
    RETURN fecha_compra;
END$$

DROP FUNCTION IF EXISTS fn_validar_email$$
CREATE FUNCTION fn_validar_email(email_param VARCHAR(150)) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    RETURN email_param REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
END$$

DROP FUNCTION IF EXISTS fn_iva$$
CREATE FUNCTION fn_iva(total_venta DECIMAL(12,2)) RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    RETURN total_venta * 0.19;
END$$

DROP FUNCTION IF EXISTS fn_precio_producto$$
CREATE FUNCTION fn_precio_producto(p_id_producto INT) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE precio_producto DECIMAL(10,2);
    SELECT precio INTO precio_producto
    FROM productos
    WHERE id_producto = p_id_producto;
    RETURN precio_producto;
END$$

DROP FUNCTION IF EXISTS fn_stock_por_categoria$$
CREATE FUNCTION fn_stock_por_categoria(p_id_categoria INT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE stock_total INT;
    SELECT COALESCE(SUM(stock), 0) INTO stock_total
    FROM productos
    WHERE id_categoria = p_id_categoria;
    RETURN stock_total;
END$$

DROP FUNCTION IF EXISTS fn_dias_desde_ultima_compra$$
CREATE FUNCTION fn_dias_desde_ultima_compra(p_id_cliente INT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE fecha_ultimo DATETIME;
    SELECT MAX(fecha_venta) INTO fecha_ultimo
    FROM ventas
    WHERE id_cliente = p_id_cliente;
    IF fecha_ultimo IS NULL THEN
        RETURN 0;
    END IF;
    RETURN DATEDIFF(CURDATE(), DATE(fecha_ultimo));
END$$

DELIMITER ;
