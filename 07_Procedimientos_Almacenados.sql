USE pro_mysql2;

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_RealizarNuevaVenta$$
CREATE PROCEDURE sp_RealizarNuevaVenta(
    IN p_id_cliente INT,
    IN p_id_sucursal INT,
    IN p_id_producto INT,
    IN p_cantidad INT
)
BEGIN
    DECLARE v_total DECIMAL(12,2);
    DECLARE v_id_venta INT;

    IF p_cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad debe ser mayor que cero';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM clientes WHERE id_cliente = p_id_cliente) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente no existe';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM productos WHERE id_producto = p_id_producto) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto no existe';
    END IF;

    IF (SELECT stock FROM productos WHERE id_producto = p_id_producto) < p_cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay stock suficiente';
    END IF;

    START TRANSACTION;

    INSERT INTO ventas (id_cliente, id_sucursal, fecha_venta, estado, total)
    VALUES (p_id_cliente, p_id_sucursal, NOW(), 'Pendiente de Pago', 0);

    SET v_id_venta = LAST_INSERT_ID();

    INSERT INTO detalle_ventas (id_venta, id_producto, cantidad, precio_unitario_congelado)
    VALUES (v_id_venta, p_id_producto, p_cantidad, (SELECT precio FROM productos WHERE id_producto = p_id_producto));

    UPDATE productos
    SET stock = stock - p_cantidad
    WHERE id_producto = p_id_producto;

    SET v_total = (
        SELECT COALESCE(SUM(cantidad * precio_unitario_congelado), 0)
        FROM detalle_ventas
        WHERE id_venta = v_id_venta
    );

    UPDATE ventas
    SET total = v_total
    WHERE id_venta = v_id_venta;

    COMMIT;
    SELECT v_id_venta AS id_venta_generada, v_total AS total_venta;
END$$

DROP PROCEDURE IF EXISTS sp_AgregarNuevoProducto$$
CREATE PROCEDURE sp_AgregarNuevoProducto(
    IN p_id_categoria INT,
    IN p_id_proveedor INT,
    IN p_nombre VARCHAR(150),
    IN p_descripcion TEXT,
    IN p_precio DECIMAL(10,2),
    IN p_costo DECIMAL(10,2),
    IN p_stock INT,
    IN p_sku VARCHAR(100)
)
BEGIN
    INSERT INTO productos (id_categoria, id_proveedor, nombre, descripcion, precio, costo, stock, sku)
    VALUES (p_id_categoria, p_id_proveedor, p_nombre, p_descripcion, p_precio, p_costo, p_stock, p_sku);
END$$

DROP PROCEDURE IF EXISTS sp_ActualizarDireccionCliente$$
CREATE PROCEDURE sp_ActualizarDireccionCliente(IN p_id_cliente INT, IN p_nueva_direccion TEXT)
BEGIN
    UPDATE clientes
    SET direccion_envio = p_nueva_direccion
    WHERE id_cliente = p_id_cliente;
END$$

DROP PROCEDURE IF EXISTS sp_GenerarReporteMensualVentas$$
CREATE PROCEDURE sp_GenerarReporteMensualVentas(IN p_anio INT, IN p_mes INT)
BEGIN
    SELECT DATE_FORMAT(fecha_venta, '%Y-%m') AS periodo,
           SUM(total) AS total_ventas
    FROM ventas
    WHERE YEAR(fecha_venta) = p_anio
      AND MONTH(fecha_venta) = p_mes
    GROUP BY DATE_FORMAT(fecha_venta, '%Y-%m');
END$$

DROP PROCEDURE IF EXISTS sp_CambiarEstadoPedido$$
CREATE PROCEDURE sp_CambiarEstadoPedido(IN p_id_venta INT, IN p_nuevo_estado VARCHAR(50))
BEGIN
    UPDATE ventas
    SET estado = p_nuevo_estado
    WHERE id_venta = p_id_venta;
END$$

DROP PROCEDURE IF EXISTS sp_RegistrarNuevoCliente$$
CREATE PROCEDURE sp_RegistrarNuevoCliente(
    IN p_nombre VARCHAR(100),
    IN p_apellido VARCHAR(100),
    IN p_email VARCHAR(150),
    IN p_password VARCHAR(255),
    IN p_direccion TEXT
)
BEGIN
    INSERT INTO clientes (nombre, apellido, email, password, direccion_envio)
    VALUES (p_nombre, p_apellido, p_email, p_password, p_direccion);
END$$

DROP PROCEDURE IF EXISTS sp_ObtenerDashboardAdmin$$
CREATE PROCEDURE sp_ObtenerDashboardAdmin()
BEGIN
    SELECT
        (SELECT COUNT(*) FROM ventas WHERE DATE(fecha_venta) = CURDATE()) AS ventas_hoy,
        (SELECT COUNT(*) FROM clientes WHERE DATE(fecha_registro) = CURDATE()) AS clientes_nuevos,
        (SELECT COALESCE(SUM(total), 0) FROM ventas WHERE DATE(fecha_venta) = CURDATE()) AS ingreso_hoy;
END$$

DROP PROCEDURE IF EXISTS sp_AñadirReseñaProducto$$
CREATE PROCEDURE sp_AñadirReseñaProducto(
    IN p_id_producto INT,
    IN p_id_cliente INT,
    IN p_calificacion INT,
    IN p_comentario TEXT
)
BEGIN
    INSERT INTO resenas_productos (id_producto, id_cliente, calificacion, comentario)
    VALUES (p_id_producto, p_id_cliente, p_calificacion, p_comentario);
END$$

DROP PROCEDURE IF EXISTS sp_ObtenerProductosRelacionados$$
CREATE PROCEDURE sp_ObtenerProductosRelacionados(IN p_id_producto INT)
BEGIN
    SELECT DISTINCT p2.id_producto, p2.nombre
    FROM detalle_ventas dv1
    JOIN detalle_ventas dv2 ON dv1.id_venta = dv2.id_venta
    JOIN productos p2 ON p2.id_producto = dv2.id_producto
    WHERE dv1.id_producto = p_id_producto
      AND dv2.id_producto <> p_id_producto
    LIMIT 10;
END$$

DROP PROCEDURE IF EXISTS sp_MoverProductosEntreCategorias$$
CREATE PROCEDURE sp_MoverProductosEntreCategorias(IN p_id_categoria_origen INT, IN p_id_categoria_destino INT, IN p_id_producto INT)
BEGIN
    UPDATE productos
    SET id_categoria = p_id_categoria_destino
    WHERE id_producto = p_id_producto AND id_categoria = p_id_categoria_origen;
END$$

DELIMITER ;
