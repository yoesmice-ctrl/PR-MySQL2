USE ecommerce_bd;

DELIMITER $$

CREATE TABLE IF NOT EXISTS log_cambios_precio (
    id_log INT NOT NULL AUTO_INCREMENT,
    id_producto INT NOT NULL,
    precio_anterior DECIMAL(10,2) NOT NULL,
    precio_nuevo DECIMAL(10,2) NOT NULL,
    fecha_cambio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_log),
    CONSTRAINT fk_log_precio_producto FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4$$

DROP TRIGGER IF EXISTS trg_audit_precio_producto_after_update$$
CREATE TRIGGER trg_audit_precio_producto_after_update
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    IF OLD.precio <> NEW.precio THEN
        INSERT INTO log_cambios_precio (id_producto, precio_anterior, precio_nuevo, fecha_cambio, usuario)
        VALUES (NEW.id_producto, OLD.precio, NEW.precio, NOW(), CURRENT_USER());
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_check_stock_before_insert_venta$$
CREATE TRIGGER trg_check_stock_before_insert_venta
BEFORE INSERT ON detalle_ventas
FOR EACH ROW
BEGIN
    DECLARE stock_actual INT;
    SELECT stock INTO stock_actual FROM productos WHERE id_producto = NEW.id_producto;
    IF stock_actual < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente para esta venta';
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_update_stock_after_insert_venta$$
CREATE TRIGGER trg_update_stock_after_insert_venta
AFTER INSERT ON detalle_ventas
FOR EACH ROW
BEGIN
    UPDATE productos
    SET stock = stock - NEW.cantidad
    WHERE id_producto = NEW.id_producto;
END$$

DROP TRIGGER IF EXISTS trg_prevent_delete_categoria_with_products$$
CREATE TRIGGER trg_prevent_delete_categoria_with_products
BEFORE DELETE ON categorias
FOR EACH ROW
BEGIN
    DECLARE productos_asociados INT;
    SELECT COUNT(*) INTO productos_asociados FROM productos WHERE id_categoria = OLD.id_categoria;
    IF productos_asociados > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar la categoría porque tiene productos asociados';
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_log_new_customer_after_insert$$
CREATE TRIGGER trg_log_new_customer_after_insert
AFTER INSERT ON clientes
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_login (usuario, fecha, intento_exitoso, ip, detalle)
    VALUES (NEW.email, UNIX_TIMESTAMP(NOW()), TRUE, 'system', 'Cliente registrado');
END$$

DROP TRIGGER IF EXISTS trg_update_total_gastado_cliente$$
CREATE TRIGGER trg_update_total_gastado_cliente
AFTER INSERT ON ventas
FOR EACH ROW
BEGIN
    UPDATE clientes
    SET total_gastado = total_gastado + NEW.total,
        fecha_ultimo_pedido = NEW.fecha_venta
    WHERE id_cliente = NEW.id_cliente;
END$$

DROP TRIGGER IF EXISTS trg_set_fecha_modificacion_producto$$
CREATE TRIGGER trg_set_fecha_modificacion_producto
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
    SET NEW.fecha_ultima_modificacion = NOW();
END$$

DROP TRIGGER IF EXISTS trg_prevent_negative_stock$$
CREATE TRIGGER trg_prevent_negative_stock
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
    IF NEW.stock < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El stock no puede ser negativo';
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_capitalize_nombre_cliente$$
CREATE TRIGGER trg_capitalize_nombre_cliente
BEFORE INSERT ON clientes
FOR EACH ROW
BEGIN
    SET NEW.nombre = CONCAT(UPPER(LEFT(NEW.nombre,1)), LOWER(SUBSTRING(NEW.nombre,2)));
    SET NEW.apellido = CONCAT(UPPER(LEFT(NEW.apellido,1)), LOWER(SUBSTRING(NEW.apellido,2)));
END$$

DROP TRIGGER IF EXISTS trg_recalculate_total_venta_on_detalle_change$$
CREATE TRIGGER trg_recalculate_total_venta_on_detalle_change
AFTER INSERT ON detalle_ventas
FOR EACH ROW
BEGIN
    UPDATE ventas
    SET total = (
        SELECT COALESCE(SUM(cantidad * precio_unitario_congelado), 0)
        FROM detalle_ventas
        WHERE id_venta = NEW.id_venta
    )
    WHERE id_venta = NEW.id_venta;
END$$

DROP TRIGGER IF EXISTS trg_log_order_status_change$$
CREATE TRIGGER trg_log_order_status_change
AFTER UPDATE ON ventas
FOR EACH ROW
BEGIN
    IF OLD.estado <> NEW.estado THEN
        INSERT INTO auditoria_pedidos (id_venta, estado_anterior, estado_nuevo)
        VALUES (NEW.id_venta, OLD.estado, NEW.estado);
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_prevent_price_zero_or_less$$
CREATE TRIGGER trg_prevent_price_zero_or_less
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
    IF NEW.precio <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El precio debe ser mayor que cero';
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_send_stock_alert_on_low_stock$$
CREATE TRIGGER trg_send_stock_alert_on_low_stock
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    IF NEW.stock < NEW.stock_minimo THEN
        INSERT INTO alertas_stock (id_producto, mensaje, fecha_alerta)
        VALUES (NEW.id_producto, CONCAT('Stock bajo para el producto ', NEW.nombre, '. Stock actual: ', NEW.stock), NOW());
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_archive_deleted_venta$$
CREATE TRIGGER trg_archive_deleted_venta
BEFORE DELETE ON ventas
FOR EACH ROW
BEGIN
    INSERT INTO venta_archivada (id_venta, motivo, fecha_archivo)
    VALUES (OLD.id_venta, 'Eliminación programada por trigger', NOW());
END$$

DROP TRIGGER IF EXISTS trg_validate_email_format_on_customer$$
CREATE TRIGGER trg_validate_email_format_on_customer
BEFORE INSERT ON clientes
FOR EACH ROW
BEGIN
    IF NEW.email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Formato de email inválido';
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_update_last_order_date_customer$$
CREATE TRIGGER trg_update_last_order_date_customer
AFTER INSERT ON ventas
FOR EACH ROW
BEGIN
    UPDATE clientes
    SET fecha_ultimo_pedido = NEW.fecha_venta
    WHERE id_cliente = NEW.id_cliente;
END$$

DROP TRIGGER IF EXISTS trg_prevent_self_referral$$
CREATE TRIGGER trg_prevent_self_referral
BEFORE INSERT ON clientes_referidos
FOR EACH ROW
BEGIN
    IF NEW.id_cliente = NEW.id_cliente_referido THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un cliente no puede referirse a sí mismo';
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_log_permission_changes$$
CREATE TRIGGER trg_log_permission_changes
AFTER UPDATE ON clientes
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_permisos (usuario, accion, detalle)
    VALUES (CURRENT_USER(), 'UPDATE_CLIENTE', CONCAT('Se actualizó el cliente ', NEW.id_cliente));
END$$

DROP TRIGGER IF EXISTS trg_assign_default_category_on_null$$
CREATE TRIGGER trg_assign_default_category_on_null
BEFORE INSERT ON productos
FOR EACH ROW
BEGIN
    IF NEW.id_categoria IS NULL THEN
        SET NEW.id_categoria = 1;
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_update_producto_count_in_categoria$$
CREATE TRIGGER trg_update_producto_count_in_categoria
AFTER INSERT ON productos
FOR EACH ROW
BEGIN
    INSERT INTO producto_categoria_count (id_categoria, total_productos)
    VALUES (NEW.id_categoria, 1)
    ON DUPLICATE KEY UPDATE total_productos = total_productos + 1;
END$$

DELIMITER ;
