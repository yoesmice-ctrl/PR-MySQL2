USE pro_mysql2;

DROP ROLE IF EXISTS 'Administrador_Sistema';
DROP ROLE IF EXISTS 'Gerente_Marketing';
DROP ROLE IF EXISTS 'Analista_Datos';
DROP ROLE IF EXISTS 'Empleado_Inventario';
DROP ROLE IF EXISTS 'Atencion_Cliente';
DROP ROLE IF EXISTS 'Auditor_Financiero';
DROP ROLE IF EXISTS 'Visitante';

CREATE ROLE 'Administrador_Sistema';
CREATE ROLE 'Gerente_Marketing';
CREATE ROLE 'Analista_Datos';
CREATE ROLE 'Empleado_Inventario';
CREATE ROLE 'Atencion_Cliente';
CREATE ROLE 'Auditor_Financiero';
CREATE ROLE 'Visitante';

CREATE USER IF NOT EXISTS 'admin_user'@'localhost' IDENTIFIED BY 'Admin#2026!';
CREATE USER IF NOT EXISTS 'marketing_user'@'localhost' IDENTIFIED BY 'Marketing#2026!';
CREATE USER IF NOT EXISTS 'inventory_user'@'localhost' IDENTIFIED BY 'Inventory#2026!';
CREATE USER IF NOT EXISTS 'support_user'@'localhost' IDENTIFIED BY 'Support#2026!';
CREATE USER IF NOT EXISTS 'analyst_user'@'localhost' IDENTIFIED BY 'Analyst#2026!';
CREATE USER IF NOT EXISTS 'auditor_user'@'localhost' IDENTIFIED BY 'Auditor#2026!';
CREATE USER IF NOT EXISTS 'visit_user'@'localhost' IDENTIFIED BY 'Visit#2026!';

GRANT ALL PRIVILEGES ON pro_mysql2.* TO 'Administrador_Sistema';
GRANT SELECT ON pro_mysql2.ventas TO 'Gerente_Marketing';
GRANT SELECT ON pro_mysql2.clientes TO 'Gerente_Marketing';
GRANT SELECT ON pro_mysql2.* TO 'Analista_Datos';
GRANT INSERT, UPDATE, DELETE ON pro_mysql2.productos TO 'Empleado_Inventario';
GRANT SELECT ON pro_mysql2.clientes TO 'Atencion_Cliente';
GRANT SELECT ON pro_mysql2.ventas TO 'Atencion_Cliente';
GRANT SELECT ON pro_mysql2.productos TO 'Atencion_Cliente';
GRANT SELECT ON pro_mysql2.ventas TO 'Auditor_Financiero';
GRANT SELECT ON pro_mysql2.productos TO 'Auditor_Financiero';
GRANT SELECT ON pro_mysql2.log_cambios_precio TO 'Auditor_Financiero';
GRANT SELECT ON pro_mysql2.productos TO 'Visitante';

GRANT 'Administrador_Sistema' TO 'admin_user'@'localhost';
GRANT 'Gerente_Marketing' TO 'marketing_user'@'localhost';
GRANT 'Empleado_Inventario' TO 'inventory_user'@'localhost';
GRANT 'Atencion_Cliente' TO 'support_user'@'localhost';
GRANT 'Analista_Datos' TO 'analyst_user'@'localhost';
GRANT 'Auditor_Financiero' TO 'auditor_user'@'localhost';
GRANT 'Visitante' TO 'visit_user'@'localhost';

SET DEFAULT ROLE ALL TO 'admin_user'@'localhost';
SET DEFAULT ROLE ALL TO 'marketing_user'@'localhost';
SET DEFAULT ROLE ALL TO 'inventory_user'@'localhost';
SET DEFAULT ROLE ALL TO 'support_user'@'localhost';
SET DEFAULT ROLE ALL TO 'analyst_user'@'localhost';
SET DEFAULT ROLE ALL TO 'auditor_user'@'localhost';
SET DEFAULT ROLE ALL TO 'visit_user'@'localhost';

CREATE VIEW v_info_clientes_basica AS
SELECT id_cliente, nombre, apellido, email, direccion_envio
FROM clientes;

GRANT SELECT ON pro_mysql2.v_info_clientes_basica TO 'Atencion_Cliente';

CREATE TABLE IF NOT EXISTS auditoria_login_usuario (
    id_login INT NOT NULL AUTO_INCREMENT,
    usuario VARCHAR(100),
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    ip VARCHAR(45),
    resultado ENUM('OK', 'FALLIDO'),
    PRIMARY KEY (id_login)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sucursal_permisos (
    id_sucursal_permiso INT NOT NULL AUTO_INCREMENT,
    id_sucursal INT NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_sucursal_permiso),
    CONSTRAINT fk_sucursal_permiso FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS password_policies (
    id_politica INT NOT NULL AUTO_INCREMENT,
    politica VARCHAR(255) NOT NULL,
    PRIMARY KEY (id_politica)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO password_policies (politica)
VALUES ('Longitud mínima de 8 caracteres, mayúsculas, números y caracteres especiales requeridos.')
ON DUPLICATE KEY UPDATE politica = VALUES(politica);

-- Política recomendada para MySQL 8:
-- INSTALL COMPONENT 'file://component_validate_password';
-- SET GLOBAL validate_password.policy = MEDIUM;
-- SET GLOBAL validate_password.length = 8;
