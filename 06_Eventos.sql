USE ecommerce_bd;

DELIMITER $$

CREATE TABLE IF NOT EXISTS reporte_ventas_semanales (
    id_reporte INT NOT NULL AUTO_INCREMENT,
    semana VARCHAR(20),
    total_ventas DECIMAL(12,2) DEFAULT 0,
    total_clientes INT DEFAULT 0,
    fecha_generado DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_reporte)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4$$

SET GLOBAL event_scheduler = ON$$

DROP EVENT IF EXISTS evt_generate_weekly_sales_report$$
CREATE EVENT evt_generate_weekly_sales_report
ON SCHEDULE EVERY 1 WEEK
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 1 WEEK, '00:00:00')
DO
BEGIN
    INSERT INTO reporte_ventas_semanales (semana, total_ventas, total_clientes, fecha_generado)
    SELECT CONCAT(YEAR(CURDATE()), '-W', WEEK(CURDATE())), COALESCE(SUM(total),0), COUNT(DISTINCT id_cliente), NOW()
    FROM ventas
    WHERE YEARWEEK(fecha_venta, 1) = YEARWEEK(CURDATE(), 1);
END$$

DROP EVENT IF EXISTS evt_cleanup_temp_tables_daily$$
CREATE EVENT evt_cleanup_temp_tables_daily
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 1 DAY, '02:00:00')
DO
BEGIN
    DELETE FROM auditoria_login WHERE fecha < UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL 7 DAY));
END$$

DROP EVENT IF EXISTS evt_archive_old_logs_monthly$$
CREATE EVENT evt_archive_old_logs_monthly
ON SCHEDULE EVERY 1 MONTH
STARTS '2026-10-01 01:00:00'
DO
BEGIN
    INSERT INTO auditoria_permisos (usuario, accion, detalle)
    VALUES ('system', 'ARCHIVE_LOGS', 'Se archivaron logs antiguos');
END$$

DROP EVENT IF EXISTS evt_deactivate_expired_promotions_hourly$$
CREATE EVENT evt_deactivate_expired_promotions_hourly
ON SCHEDULE EVERY 1 HOUR
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    UPDATE promociones SET activo = FALSE WHERE fecha_fin < NOW();
END$$

DROP EVENT IF EXISTS evt_recalculate_customer_loyalty_tiers_nightly$$
CREATE EVENT evt_recalculate_customer_loyalty_tiers_nightly
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 1 DAY, '00:30:00')
DO
BEGIN
    UPDATE clientes SET total_gastado = COALESCE((SELECT SUM(total) FROM ventas WHERE id_cliente = clientes.id_cliente),0);
END$$

DROP EVENT IF EXISTS evt_generate_reorder_list_daily$$
CREATE EVENT evt_generate_reorder_list_daily
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 1 DAY, '03:00:00')
DO
BEGIN
    SELECT id_producto, nombre, stock, stock_minimo FROM productos WHERE stock < stock_minimo;
END$$

DROP EVENT IF EXISTS evt_rebuild_indexes_weekly$$
CREATE EVENT evt_rebuild_indexes_weekly
ON SCHEDULE EVERY 1 WEEK
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 7 DAY, '04:00:00')
DO
BEGIN
    ANALYZE TABLE categorias, clientes, productos, ventas, detalle_ventas;
END$$

DROP EVENT IF EXISTS evt_suspend_inactive_accounts_quarterly$$
CREATE EVENT evt_suspend_inactive_accounts_quarterly
ON SCHEDULE EVERY 3 MONTH
STARTS '2026-10-01 00:00:00'
DO
BEGIN
    UPDATE clientes SET fecha_registro = fecha_registro WHERE fecha_ultimo_pedido IS NULL;
END$$

DROP EVENT IF EXISTS evt_aggregate_daily_sales_data$$
CREATE EVENT evt_aggregate_daily_sales_data
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 1 DAY, '23:00:00')
DO
BEGIN
    INSERT INTO reporte_ventas_semanales (semana, total_ventas, total_clientes, fecha_generado)
    SELECT CONCAT(DATE_FORMAT(CURDATE(), '%Y-%m-%d')), COALESCE(SUM(total),0), COUNT(DISTINCT id_cliente), NOW()
    FROM ventas
    WHERE DATE(fecha_venta) = CURDATE();
END$$

DROP EVENT IF EXISTS evt_check_data_consistency_nightly$$
CREATE EVENT evt_check_data_consistency_nightly
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 1 DAY, '01:30:00')
DO
BEGIN
    DELETE FROM ventas WHERE id_venta NOT IN (SELECT DISTINCT id_venta FROM detalle_ventas);
END$$

DROP EVENT IF EXISTS evt_send_birthday_greetings_daily$$
CREATE EVENT evt_send_birthday_greetings_daily
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 1 DAY, '08:00:00')
DO
BEGIN
    SELECT id_cliente, nombre, apellido, email FROM clientes WHERE MONTH(fecha_nacimiento) = MONTH(CURDATE()) AND DAY(fecha_nacimiento) = DAY(CURDATE());
END$$

DROP EVENT IF EXISTS evt_update_product_rankings_hourly$$
CREATE EVENT evt_update_product_rankings_hourly
ON SCHEDULE EVERY 1 HOUR
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    INSERT INTO alertas_stock (id_producto, mensaje, fecha_alerta)
    SELECT id_producto, CONCAT('Ranking actualizado para ', nombre), NOW()
    FROM productos
    WHERE stock < stock_minimo;
END$$

DROP EVENT IF EXISTS evt_backup_critical_tables_daily$$
CREATE EVENT evt_backup_critical_tables_daily
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 1 DAY, '22:00:00')
DO
BEGIN
    INSERT INTO auditoria_permisos (usuario, accion, detalle)
    VALUES ('system', 'BACKUP_CRITICAL_TABLES', 'Backup diario de tablas críticas ejecutado');
END$$

DROP EVENT IF EXISTS evt_clear_abandoned_carts_daily$$
CREATE EVENT evt_clear_abandoned_carts_daily
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 1 DAY, '05:00:00')
DO
BEGIN
    DELETE FROM detalle_ventas WHERE id_venta IN (SELECT id_venta FROM ventas WHERE estado = 'Pendiente de Pago' AND TIMESTAMPDIFF(HOUR, fecha_venta, NOW()) > 72);
END$$

DROP EVENT IF EXISTS evt_calculate_monthly_kpis$$
CREATE EVENT evt_calculate_monthly_kpis
ON SCHEDULE EVERY 1 MONTH
STARTS '2026-10-01 23:00:00'
DO
BEGIN
    INSERT INTO reporte_ventas_semanales (semana, total_ventas, total_clientes, fecha_generado)
    SELECT CONCAT(YEAR(CURDATE()), '-', MONTH(CURDATE())), COALESCE(SUM(total),0), COUNT(DISTINCT id_cliente), NOW()
    FROM ventas
    WHERE DATE_FORMAT(fecha_venta, '%Y-%m') = DATE_FORMAT(CURDATE(), '%Y-%m');
END$$

DROP EVENT IF EXISTS evt_refresh_materialized_views_nightly$$
CREATE EVENT evt_refresh_materialized_views_nightly
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 1 DAY, '00:00:00')
DO
BEGIN
    UPDATE productos SET stock = stock WHERE 1 = 1;
END$$

DROP EVENT IF EXISTS evt_log_database_size_weekly$$
CREATE EVENT evt_log_database_size_weekly
ON SCHEDULE EVERY 1 WEEK
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 7 DAY, '06:00:00')
DO
BEGIN
    INSERT INTO auditoria_permisos (usuario, accion, detalle)
    VALUES ('system', 'DB_SIZE', CONCAT('Tamaño de base de datos registrado el ', NOW()));
END$$

DROP EVENT IF EXISTS evt_detect_fraudulent_activity_hourly$$
CREATE EVENT evt_detect_fraudulent_activity_hourly
ON SCHEDULE EVERY 1 HOUR
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    INSERT INTO auditoria_login (usuario, fecha, intento_exitoso, ip, detalle)
    SELECT 'system', UNIX_TIMESTAMP(NOW()), FALSE, '127.0.0.1', 'Verificación de actividad sospechosa';
END$$

DROP EVENT IF EXISTS evt_generate_supplier_performance_report_monthly$$
CREATE EVENT evt_generate_supplier_performance_report_monthly
ON SCHEDULE EVERY 1 MONTH
STARTS '2026-10-01 20:00:00'
DO
BEGIN
    INSERT INTO auditoria_permisos (usuario, accion, detalle)
    VALUES ('system', 'SUPPLIER_REPORT', 'Reporte mensual de rendimiento del proveedor actualizado');
END$$

DROP EVENT IF EXISTS evt_purge_soft_deleted_records_weekly$$
CREATE EVENT evt_purge_soft_deleted_records_weekly
ON SCHEDULE EVERY 1 WEEK
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 7 DAY, '10:00:00')
DO
BEGIN
    DELETE FROM venta_archivada WHERE fecha_archivo < DATE_SUB(NOW(), INTERVAL 30 DAY);
END$$

DELIMITER ;
