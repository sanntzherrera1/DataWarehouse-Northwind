# Registro de decisiones

## ADR-001: Left join y monitoreo de líneas huérfanas en fct_order_lines

**Fecha:** 2026-10-11
**Estado:** Aceptada

### Contexto
fct_order_lines parte de stg_order_details y se une con stg_orders para traer
order_date, customer_id, employee_id y shipper_id. Si una línea tiene un
order_id que no existe en orders (línea huérfana), un inner join la
descartaría sin aviso.

Hoy la fuente tiene una clave foránea de order_details hacia orders, así que
no se generan huérfanos. La decisión anticipa la Fase 2 (datos que llegan
tarde desde el generador) y la Fase 3 (BigQuery no aplica claves foráneas),
donde sí pueden aparecer.

### Decisión
Mantener el left join. Una línea huérfana queda en fct_order_lines con nulos
en las columnas que vienen de orders.

Se monitorea con el test relationships de fct_order_lines.order_id hacia
fct_orders, configurado con severity: warn: avisa desde la primera línea
huérfana sin frenar el build.

### Alternativas consideradas
- Inner join: descarta los huérfanos sin aviso y los reportes muestran menos
  ventas de las reales.
- Miembro desconocido o coalesce: haría que un error de carga parezca un
  dato válido en los reportes. Se reserva para faltantes legítimos del
  negocio, como una orden todavía no despachada.
- Test con severity: error: frena todo el pipeline ante una sola línea
  huérfana, aunque el resto de los modelos esté bien.

### Consecuencias
- No se pierden líneas: las huérfanas quedan visibles, con nulos.
- Un warning solo sirve si alguien lo revisa. Cuando aparece:
  1. Revisar el log de dbt build o del CI: cuántas líneas y qué order_id.
  2. Buscar la causa: ¿la orden falta en la fuente o se perdió en la carga?
  3. Corregir donde corresponda y volver a correr el build.
- En la Fase 3, este aviso se puede automatizar con una alerta desde Airflow.


## ADR-002: Modelo estrella en la capa de marts

**Fecha:** 2026-10-14
**Estado:** Aceptada

### Contexto
La capa de marts mezclaba dos modelos dimensionales. dim_products apuntaba
a dim_categories y dim_suppliers (snowflake), pero además ya traía
category_name copiado (star). El resultado era un híbrido: para llegar
al proveedor de una venta había que encadenar fact → dim_products → dim_suppliers.


### Decisión
Llevar todo a estrella: cada dimensión cuelga directo de las facts.

- dim_products se desnormaliza: hace join con stg_categories y stg_suppliers
  y suma category_name, supplier_name y supplier_country.
- Se eliminan dim_categories y dim_suppliers. Ninguna fact las usaba.
- Los tests relationships de dim_products pasan a apuntar a staging, para
  seguir detectando categorías o proveedores huérfanos.

### Alternativas consideradas
- Copo de nieve: dimensiones normalizadas, sin datos repetidos. Se descarta
  porque suma joins en cada consulta y no hay una ventaja real: las
  dimensiones son chicas

### Consecuencias
- Las consultas analíticas llegan a cualquier atributo de producto con un
  solo join desde la fact.
- Los nombres de categoría y proveedor se repiten en cada producto. No genera
  inconsistencias porque dbt reconstruye dim_products desde staging en cada
  corrida: si cambia un nombre en la fuente, se actualiza en todas las filas.
- La capa de staging sigue normalizada, 1 a 1 con la fuente. Solo se
  desnormaliza la capa de presentación.