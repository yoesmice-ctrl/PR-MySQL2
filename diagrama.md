# Diagrama conceptual

Relaciones principales:

- Un cliente puede tener muchos pedidos.
- Un empleado puede atender muchos pedidos.
- Un pedido puede incluir muchos productos.
- Un producto puede aparecer en muchos pedidos.
- Un pedido puede tener uno o varios pagos.

## Entidades

Cliente
- id_cliente
- nombre
- apellido
- email
- telefono
- direccion

Empleado
- id_empleado
- nombre
- apellido
- cargo
- email
- fecha_contratacion

Producto
- id_producto
- nombre
- categoria
- precio
- stock
- descripcion

Pedido
- id_pedido
- id_cliente
- id_empleado
- fecha_pedido
- estado
- total

DetallePedido
- id_detalle
- id_pedido
- id_producto
- cantidad
- precio_unitario

Pago
- id_pago
- id_pedido
- metodo_pago
- monto
- fecha_pago
- estado
