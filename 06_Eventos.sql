USE pro_mysql2;

DELIMITER $$

SET GLOBAL event_scheduler = ON$$

DROP EVENT IF EXISTS evt_reporte_ventas_semanal$$
CREATE EVENT evt_reporte_ventas_semanal
ON SCHEDULE EVERY 1 WEEK
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 1 WEEK, '00:00:00')
DO
BEGIN
    INSERT INTO reporte_ventas_semanales (semana, total_ventas, total_clientes, fecha_generado)
    SELECT CONCAT(YEAR(CURDATE()), '-W', WEEK(CURDATE())),
           COALESCE(SUM(total), 0),
           COUNT(DISTINCT id_cliente),
           NOW()
    FROM ventas
    WHERE YEARWEEK(fecha_venta, 1) = YEARWEEK(CURDATE(), 1);
END$$

DROP EVENT IF EXISTS evt_limpiar_auditoria_diaria$$
CREATE EVENT evt_limpiar_auditoria_diaria
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 1 DAY, '02:00:00')
DO
BEGIN
    DELETE FROM auditoria_login
    WHERE fecha < DATE_SUB(NOW(), INTERVAL 7 DAY);
END$$

DROP EVENT IF EXISTS evt_actualizar_promociones$$
CREATE EVENT evt_actualizar_promociones
ON SCHEDULE EVERY 1 HOUR
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    UPDATE promociones
    SET activo = FALSE
    WHERE fecha_fin < NOW();
END$$

DROP EVENT IF EXISTS evt_recalcular_total_clientes$$
CREATE EVENT evt_recalcular_total_clientes
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 1 DAY, '00:30:00')
DO
BEGIN
    UPDATE clientes c
    SET total_gastado = (
        SELECT COALESCE(SUM(v.total), 0)
        FROM ventas v
        WHERE v.id_cliente = c.id_cliente
    );
END$$

DROP EVENT IF EXISTS evt_alerta_stock_diaria$$
CREATE EVENT evt_alerta_stock_diaria
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 1 DAY, '03:00:00')
DO
BEGIN
    INSERT INTO alertas_stock (id_producto, mensaje, fecha_alerta)
    SELECT id_producto,
           CONCAT('Revisión de inventario para ', nombre),
           NOW()
    FROM productos
    WHERE stock < stock_minimo;
END$$

DROP EVENT IF EXISTS evt_reporte_ventas_mensual$$
CREATE EVENT evt_reporte_ventas_mensual
ON SCHEDULE EVERY 1 MONTH
STARTS '2026-10-01 23:00:00'
DO
BEGIN
    INSERT INTO reporte_ventas_semanales (semana, total_ventas, total_clientes, fecha_generado)
    SELECT CONCAT(YEAR(CURDATE()), '-', LPAD(MONTH(CURDATE()), 2, '0')),
           COALESCE(SUM(total), 0),
           COUNT(DISTINCT id_cliente),
           NOW()
    FROM ventas
    WHERE DATE_FORMAT(fecha_venta, '%Y-%m') = DATE_FORMAT(CURDATE(), '%Y-%m');
END$$

DELIMITER ;
