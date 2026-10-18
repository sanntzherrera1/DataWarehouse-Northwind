# Northwind Data Warehouse (dbt + Databricks)
[![dbt ci](https://github.com/sanntzherrera1/DataWarehouse-Northwind/actions/workflows/dbt-ci.yml/badge.svg)](https://github.com/sanntzherrera1/DataWarehouse-Northwind/actions/workflows/dbt-ci.yml)

Pipeline ELT que lleva la base transaccional **Northwind** a un modelo dimensional (star schema) con **arquitectura medallion** (bronze → silver → gold) en **Databricks**, transformado con **dbt**. El mismo proyecto dbt corre también sobre **PostgreSQL** local, que se usa para desarrollo y CI.

## 🎯 Objetivo

Convertir datos crudos de una base transaccional (ventas, clientes, productos) en un modelo limpio y testeado, capaz de responder preguntas reales de negocio.

## 🛠️ Stack

Databricks Free Edition (Unity Catalog, Delta, PySpark) · dbt Core (dbt-databricks, dbt-postgres) · PostgreSQL (Docker) · Python · GitHub Actions

## 🏗️ Arquitectura

```
PostgreSQL (Docker, fuente)
   │  export a CSV
   ▼
Volume northwind.bronze.raw_files
   │  notebook PySpark
   ▼
BRONZE  northwind.bronze   8 tablas Delta, copia cruda (todo string)
   │  dbt
   ▼
SILVER  northwind.silver   staging (tipado y limpieza) + intermediate
   │  dbt
   ▼
GOLD    northwind.gold     star schema: 5 dimensiones + 2 hechos
```

| Capa medallion | Capa dbt | Materialización |
|---|---|---|
| Bronze | `source('northwind', ...)` | Tablas Delta cargadas con PySpark |
| Silver | `staging/` + `intermediate/` | Vistas |
| Gold | `marts/` | Tablas |

El proyecto dbt es portable: con `--target databricks` lee de `northwind.bronze`; con el target por defecto lee del esquema `public` de Postgres. Las diferencias de dialecto SQL se resuelven con macros (ver [ADR-005](docs/decisions.md)).

## 📐 Modelo de datos

- **Staging:** 8 vistas, una por tabla fuente, con limpieza y tipado.
- **Intermediate:** `int_order_lines_enriched`, líneas de orden con el importe calculado.
- **Marts:** star schema con 5 dimensiones (`dim_customers`, `dim_employees`, `dim_products`, `dim_shippers`, `dim_date`) y 2 tablas de hechos.

| Tabla de hechos | Grain |
|---|---|
| `fct_orders` | Una fila por orden |
| `fct_order_lines` | Una fila por producto dentro de una orden |

## ✅ Calidad de datos

71 tests, en cada capa:
- **Fuente (15):** claves primarias únicas y no nulas.
- **Staging (21):** claves, rangos (precios, cantidades, descuentos) y fechas coherentes.
- **Intermediate (5):** grain, nulos e integridad de productos.
- **Marts (28):** integridad entre dimensiones y hechos, grain y calendario.
- **Reconciliación (2):** `freight` y el total de las órdenes coinciden exactamente entre capas.

Las decisiones de diseño están documentadas en [`docs/decisions.md`](docs/decisions.md).

## 🔁 Integración continua

En cada push, GitHub Actions recrea el proyecto desde cero en una máquina limpia: levanta Postgres, carga Northwind y corre `dbt build` con todos los modelos y tests. Si algo se rompe, el badge se pone en rojo.

Las credenciales no están en el código: el perfil de `ci/profiles.yml` las lee de variables de entorno, y el token de Databricks vive solo en `~/.dbt/profiles.yml`, fuera del repo.

## 🚀 Cómo levantarlo

### 1. Postgres local (fuente)

```bash
cp .env.example .env        # completá tus valores
docker compose up -d
```

La primera vez, Postgres ejecuta `db/northwind.sql` y deja Northwind en el esquema `public` de la base definida en `POSTGRES_DB`.

> **Ojo:** la carga corre solo cuando el volumen está vacío. Para recrear todo: `docker compose down -v` y volver a levantar.

### 2. dbt

```bash
python3 -m venv venv
source venv/bin/activate          # Windows: venv\Scripts\activate
pip install -r requirements.txt
cd project_dbt_transform
dbt deps
dbt build                         # contra Postgres
```

La conexión se configura en `~/.dbt/profiles.yml` (fuera del repo):

```yaml
project_dbt_transform:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      port: 5432
      user: <POSTGRES_USER>
      password: <POSTGRES_PASSWORD>
      dbname: <POSTGRES_DB>
      schema: dbt_dev
      threads: 4
    databricks:
      type: databricks
      host: <workspace>.cloud.databricks.com
      http_path: /sql/1.0/warehouses/<id>
      token: <token personal>
      catalog: northwind
      schema: silver
      threads: 4
```

### 3. Databricks

1. Exportar las tablas de Postgres a CSV (desde la raíz del repo):

```bash
mkdir -p data/raw && for t in categories customers employees order_details orders products shippers suppliers; do
  docker compose exec -T postgres psql -U <POSTGRES_USER> -d <POSTGRES_DB> \
    -c "\copy $t to stdout with csv header" > data/raw/$t.csv
done
```

2. Crear el catálogo `northwind`, el esquema `bronze` y el volume `raw_files`, y subir los CSV al volume.
3. Correr el notebook de ingesta para crear las tablas de bronze.
4. Construir silver y gold:

```bash
dbt build --target databricks
```

## 📊 Estado actual

- [x] Infraestructura local (Docker + Postgres)
- [x] Staging, intermediate y marts (star schema)
- [x] 71 tests de calidad en todas las capas
- [x] CI con GitHub Actions (`dbt build` en cada push)
- [x] Medallion en Databricks: bronze (PySpark), silver y gold (dbt)
- [x] Proyecto dbt portable Postgres ↔ Databricks
- [ ] Tipado completo de todas las columnas en staging
- [ ] Notebook de ingesta versionado en el repo
- [ ] Orquestación con Databricks Jobs (ingesta → dbt)
- [ ] Ingesta incremental
