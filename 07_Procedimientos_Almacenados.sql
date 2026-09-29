USE ecommerce_bd;

DELIMITER $$

CREATE PROCEDURE sp_RealizarNuevaVenta(IN p_id_cliente INT, IN p_id_sucursal INT)
BEGIN
    DECLARE v_total DECIMAL(12,2) DEFAULT 0;
    INSERT INTO ventas (id_cliente, id_sucursal, fecha_venta, estado, total)
    VALUES (p_id_cliente, p_id_sucursal, NOW(), 'Pendiente de Pago', 0);
    SELECT LAST_INSERT_ID() AS id_venta_generada;
END$$

CREATE PROCEDURE sp_AgregarNuevoProducto(IN p_id_categoria INT, IN p_id_proveedor INT, IN p_nombre VARCHAR(150), IN p_descripcion TEXT, IN p_precio DECIMAL(10,2), IN p_costo DECIMAL(10,2), IN p_stock INT, IN p_sku VARCHAR(100))
BEGIN
    INSERT INTO productos (id_categoria, id_proveedor, nombre, descripcion, precio, costo, stock, sku)
    VALUES (p_id_categoria, p_id_proveedor, p_nombre, p_descripcion, p_precio, p_costo, p_stock, p_sku);
END$$

CREATE PROCEDURE sp_ActualizarDireccionCliente(IN p_id_cliente INT, IN p_nueva_direccion TEXT)
BEGIN
    UPDATE clientes SET direccion_envio = p_nueva_direccion WHERE id_cliente = p_id_cliente;
END$$

CREATE PROCEDURE sp_ProcesarDevolucion(IN p_id_detalle INT, IN p_cantidad INT)
BEGIN
    UPDATE productos p
    JOIN detalle_ventas dv ON dv.id_producto = p.id_producto
    SET p.stock = p.stock + p_cantidad
    WHERE dv.id_detalle = p_id_detalle;
END$$

CREATE PROCEDURE sp_ObtenerHistorialComprasCliente(IN p_id_cliente INT)
BEGIN
    SELECT v.id_venta, v.fecha_venta, v.total, v.estado
    FROM ventas v
    WHERE v.id_cliente = p_id_cliente;
END$$

CREATE PROCEDURE sp_AjustarNivelStock(IN p_id_producto INT, IN p_nuevo_stock INT, IN p_motivo VARCHAR(255))
BEGIN
    UPDATE productos SET stock = p_nuevo_stock WHERE id_producto = p_id_producto;
    INSERT INTO alertas_stock (id_producto, mensaje, fecha_alerta)
    VALUES (p_id_producto, p_motivo, NOW());
END$$

CREATE PROCEDURE sp_EliminarClienteDeFormaSegura(IN p_id_cliente INT)
BEGIN
    UPDATE clientes
    SET email = CONCAT('anonimo_', p_id_cliente, '@deleted.com'),
        password = 'ANONIMIZADO',
        direccion_envio = 'No disponible'
    WHERE id_cliente = p_id_cliente;
END$$

CREATE PROCEDURE sp_AplicarDescuentoPorCategoria(IN p_id_categoria INT, IN p_porcentaje DECIMAL(5,2))
BEGIN
    UPDATE productos
    SET precio = precio - (precio * p_porcentaje / 100)
    WHERE id_categoria = p_id_categoria;
END$$

CREATE PROCEDURE sp_GenerarReporteMensualVentas(IN p_anio INT, IN p_mes INT)
BEGIN
    SELECT DATE_FORMAT(fecha_venta, '%Y-%m') AS periodo, SUM(total) AS total_ventas
    FROM ventas
    WHERE YEAR(fecha_venta) = p_anio AND MONTH(fecha_venta) = p_mes
    GROUP BY DATE_FORMAT(fecha_venta, '%Y-%m');
END$$

CREATE PROCEDURE sp_CambiarEstadoPedido(IN p_id_venta INT, IN p_nuevo_estado VARCHAR(50))
BEGIN
    UPDATE ventas SET estado = p_nuevo_estado WHERE id_venta = p_id_venta;
END$$

CREATE PROCEDURE sp_RegistrarNuevoCliente(IN p_nombre VARCHAR(100), IN p_apellido VARCHAR(100), IN p_email VARCHAR(150), IN p_password VARCHAR(255), IN p_direccion TEXT)
BEGIN
    INSERT INTO clientes (nombre, apellido, email, password, direccion_envio)
    VALUES (p_nombre, p_apellido, p_email, p_password, p_direccion);
END$$

CREATE PROCEDURE sp_ObtenerDetallesProductoCompleto(IN p_id_producto INT)
BEGIN
    SELECT p.*, c.nombre AS categoria, pr.nombre AS proveedor
    FROM productos p
    JOIN categorias c ON c.id_categoria = p.id_categoria
    JOIN proveedores pr ON pr.id_proveedor = p.id_proveedor
    WHERE p.id_producto = p_id_producto;
END$$

CREATE PROCEDURE sp_FusionarCuentasCliente(IN p_id_cliente_origen INT, IN p_id_cliente_destino INT)
BEGIN
    UPDATE ventas SET id_cliente = p_id_cliente_destino WHERE id_cliente = p_id_cliente_origen;
    DELETE FROM clientes WHERE id_cliente = p_id_cliente_origen;
END$$

CREATE PROCEDURE sp_AsignarProductoAProveedor(IN p_id_producto INT, IN p_id_proveedor INT)
BEGIN
    UPDATE productos SET id_proveedor = p_id_proveedor WHERE id_producto = p_id_producto;
END$$

CREATE PROCEDURE sp_BuscarProductos(IN p_nombre VARCHAR(150), IN p_id_categoria INT, IN p_precio_min DECIMAL(10,2), IN p_precio_max DECIMAL(10,2))
BEGIN
    SELECT *
    FROM productos
    WHERE (p_nombre IS NULL OR nombre LIKE CONCAT('%', p_nombre, '%'))
      AND (p_id_categoria IS NULL OR id_categoria = p_id_categoria)
      AND (p_precio_min IS NULL OR precio >= p_precio_min)
      AND (p_precio_max IS NULL OR precio <= p_precio_max);
END$$

CREATE PROCEDURE sp_ObtenerDashboardAdmin()
BEGIN
    SELECT
        (SELECT COUNT(*) FROM ventas WHERE DATE(fecha_venta) = CURDATE()) AS ventas_hoy,
        (SELECT COUNT(*) FROM clientes WHERE DATE(fecha_registro) = CURDATE()) AS clientes_nuevos,
        (SELECT COALESCE(SUM(total),0) FROM ventas WHERE DATE(fecha_venta) = CURDATE()) AS ingreso_hoy;
END$$

CREATE PROCEDURE sp_ProcesarPago(IN p_id_venta INT, IN p_metodo VARCHAR(50), IN p_monto DECIMAL(12,2))
BEGIN
    UPDATE ventas
    SET estado = 'Procesando'
    WHERE id_venta = p_id_venta;

    INSERT INTO auditoria_permisos (usuario, accion, detalle)
    VALUES (CURRENT_USER(), 'PAGO', CONCAT('Venta ', p_id_venta, ' pagada con ', p_metodo, ' por ', p_monto));
END$$

CREATE PROCEDURE sp_AñadirReseñaProducto(IN p_id_producto INT, IN p_id_cliente INT, IN p_calificacion INT, IN p_comentario TEXT)
BEGIN
    INSERT INTO reseñas_productos (id_producto, id_cliente, calificacion, comentario)
    VALUES (p_id_producto, p_id_cliente, p_calificacion, p_comentario);
END$$

CREATE PROCEDURE sp_ObtenerProductosRelacionados(IN p_id_producto INT)
BEGIN
    SELECT DISTINCT p2.id_producto, p2.nombre
    FROM detalle_ventas dv1
    JOIN detalle_ventas dv2 ON dv1.id_venta = dv2.id_venta AND dv1.id_producto <> dv2.id_producto
    JOIN productos p2 ON p2.id_producto = dv2.id_producto
    WHERE dv1.id_producto = p_id_producto
    LIMIT 10;
END$$

CREATE PROCEDURE sp_MoverProductosEntreCategorias(IN p_id_categoria_origen INT, IN p_id_categoria_destino INT, IN p_id_producto INT)
BEGIN
    UPDATE productos
    SET id_categoria = p_id_categoria_destino
    WHERE id_producto = p_id_producto AND id_categoria = p_id_categoria_origen;
END$$

DELIMITER ;
