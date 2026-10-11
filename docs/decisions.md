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