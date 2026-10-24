# Registro de decisiones

## ADR-001: Left join en fct_order_lines

**Fecha:** 2026-10-11
**Estado:** Aceptada

### Contexto
Si una línea de orden tiene un order_id que no existe en orders, un inner
join la descarta sin aviso. Hoy la fuente lo impide con una clave foránea,
pero Databricks no hace cumplir claves foráneas.

### Decisión
Left join: la línea huérfana queda con nulos. Un test relationships con
severity: warn avisa sin frenar el build.

### Alternativas
- Inner join: se pierden ventas sin que nadie se entere.
- Valor por defecto (coalesce): un error de carga parecería un dato válido.
- Test con severity: error: una sola línea frena todo el pipeline.

### Consecuencias
- No se pierden líneas.
- El warning hay que revisarlo en el log del build o del CI.


## ADR-002: Modelo estrella en marts

**Fecha:** 2026-10-14
**Estado:** Aceptada

### Contexto
dim_products apuntaba a dim_categories y dim_suppliers (snowflake), pero
también tenía category_name copiado. Quedaba un híbrido.

### Decisión
Todo en estrella: dim_products suma categoría y proveedor, y se eliminan
dim_categories y dim_suppliers.

### Alternativas
- Snowflake: más joins en cada consulta, sin ventaja con dimensiones chicas.

### Consecuencias
- Un solo join desde la fact a cualquier dato del producto.
- Los nombres se repiten, pero dbt reconstruye la tabla en cada corrida.


## ADR-003: BigQuery como data warehouse

**Fecha:** 2026-10-15
**Estado:** Reemplazada por ADR-004

### Contexto
Postgres era fuente y warehouse a la vez.

### Decisión
BigQuery como warehouse, en el sandbox gratuito. Postgres queda como fuente.

### Alternativas
- Postgres: no es un motor analítico.
- Snowflake / Databricks: más complejos.

### Consecuencias
- Hay que adaptar el SQL de Postgres.


## ADR-004: Databricks como data warehouse

**Fecha:** 2026-10-18
**Estado:** Aceptada

### Contexto
El proyecto necesita un warehouse en la nube, separado de la fuente.

### Decisión
Databricks Free Edition con capas medallion en el catálogo northwind:
bronze (PySpark), silver (staging + intermediate) y gold (marts). Postgres
queda como fuente y para desarrollo y CI.

### Consecuencias
- Sin costo.
- El proyecto dbt corre en dos motores (ver ADR-005).


## ADR-005: Bronze como string y SQL portable

**Fecha:** 2026-10-18
**Estado:** Aceptada

### Contexto
En Databricks fallaron dos cosas: dim_date usaba isodow y to_char, que Spark
no tiene, y el test de totales daba diferencias de centavos porque quantity
llegaba como string y la cuenta se hacía en double.

### Decisión
- Bronze guarda todo como string y staging castea cada columna.
- Macros day_of_week_iso y month_name según el motor.
- generate_schema_name para que los marts vayan a gold.

### Consecuencias
- Los montos cuadran al centavo.
- El mismo dbt build pasa en Postgres, Databricks y el CI.


## ADR-006: Orquestación con Databricks Jobs

**Fecha:** 2026-10-24
**Estado:** Aceptada

### Contexto
La ingesta y el dbt build se corrían a mano.

### Decisión
Un Job con dos tareas: ingest_bronze y después dbt_build. Corre todos los
días y manda un mail si falla.

### Alternativas
- Airflow: otra herramienta más, cuando todo ya está en Databricks.
- Declarative Pipelines: reemplazaría a dbt y sirve más para streaming.

### Consecuencias
- El pipeline corre sin depender de mi máquina.
