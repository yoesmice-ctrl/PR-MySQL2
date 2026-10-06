USE pro_mysql2;

DELIMITER $$

DROP TRIGGER IF EXISTS trg_log_precio_producto$$
CREATE TRIGGER trg_log_precio_producto
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    IF OLD.precio <> NEW.precio THEN
        INSERT INTO log_cambios_precio (id_producto, precio_anterior, precio_nuevo, usuario)
        VALUES (NEW.id_producto, OLD.precio, NEW.precio, CURRENT_USER());
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_validar_stock_venta$$
CREATE TRIGGER trg_validar_stock_venta
BEFORE INSERT ON detalle_ventas
FOR EACH ROW
BEGIN
    DECLARE stock_actual INT;
    SELECT stock INTO stock_actual
    FROM productos
    WHERE id_producto = NEW.id_producto;

    IF stock_actual < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente para esta venta';
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_actualizar_stock_venta$$
CREATE TRIGGER trg_actualizar_stock_venta
AFTER INSERT ON detalle_ventas
FOR EACH ROW
BEGIN
    UPDATE productos
    SET stock = stock - NEW.cantidad
    WHERE id_producto = NEW.id_producto;
END$$

DROP TRIGGER IF EXISTS trg_recalcular_total_venta$$
CREATE TRIGGER trg_recalcular_total_venta
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

DROP TRIGGER IF EXISTS trg_log_estado_venta$$
CREATE TRIGGER trg_log_estado_venta
AFTER UPDATE ON ventas
FOR EACH ROW
BEGIN
    IF OLD.estado <> NEW.estado THEN
        INSERT INTO auditoria_pedidos (id_venta, estado_anterior, estado_nuevo)
        VALUES (NEW.id_venta, OLD.estado, NEW.estado);
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_validar_email_cliente$$
CREATE TRIGGER trg_validar_email_cliente
BEFORE INSERT ON clientes
FOR EACH ROW
BEGIN
    IF NEW.email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Formato de email inválido';
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_alerta_stock_bajo$$
CREATE TRIGGER trg_alerta_stock_bajo
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    IF NEW.stock < NEW.stock_minimo THEN
        INSERT INTO alertas_stock (id_producto, mensaje)
        VALUES (NEW.id_producto, CONCAT('Stock bajo para ', NEW.nombre, '. Stock actual: ', NEW.stock));
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_prevenir_referencia_auto$$
CREATE TRIGGER trg_prevenir_referencia_auto
BEFORE INSERT ON clientes_referidos
FOR EACH ROW
BEGIN
    IF NEW.id_cliente = NEW.id_cliente_referido THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un cliente no puede referirse a sí mismo';
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_actualizar_total_gastado$$
CREATE TRIGGER trg_actualizar_total_gastado
AFTER INSERT ON ventas
FOR EACH ROW
BEGIN
    UPDATE clientes
    SET total_gastado = total_gastado + NEW.total,
        fecha_ultimo_pedido = NEW.fecha_venta
    WHERE id_cliente = NEW.id_cliente;
END$$

DELIMITER ;
