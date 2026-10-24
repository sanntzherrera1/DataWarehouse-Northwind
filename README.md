# Northwind Data Warehouse (dbt + Databricks)
[![dbt ci](https://github.com/sanntzherrera1/DataWarehouse-Northwind/actions/workflows/dbt-ci.yml/badge.svg)](https://github.com/sanntzherrera1/DataWarehouse-Northwind/actions/workflows/dbt-ci.yml)

Pipeline ELT que lleva la base transaccional **Northwind** a un modelo dimensional (star schema) con **arquitectura medallion** (bronze → silver → gold) en **Databricks**, transformado con **dbt**. El mismo proyecto dbt corre también sobre **PostgreSQL** local, que se usa para desarrollo y CI.

## 🎯 Objetivo

Convertir datos crudos de una base transaccional (ventas, clientes, productos) en un modelo limpio y testeado, capaz de responder preguntas reales de negocio.

## 🛠️ Stack

Databricks Free Edition (Unity Catalog, Delta, PySpark, Jobs, AI/BI Dashboards, Genie) · dbt Core (dbt-databricks, dbt-postgres) · PostgreSQL (Docker) · Python · GitHub Actions

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
   │
   ▼
Dashboard AI/BI + Genie (preguntas en lenguaje natural)
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

## ⚙️ Orquestación y consumo

Un Databricks Job corre el pipeline todos los días: `ingest_bronze` (notebook) → `dbt_build` (silver + gold y tests), con aviso por mail si falla y timeout por tarea.

Sobre gold hay un dashboard con ventas por mes, top productos, ventas por país y KPIs, y un espacio de Genie para consultar el modelo en lenguaje natural.

## ⚠️ Limitaciones

- Postgres corre en local, así que la exportación de CSV al volume es manual. En un entorno real, Databricks leería la fuente por JDBC o con un conector de ingesta.
- Los datos son estáticos: cada corrida recarga todo (overwrite), sin carga incremental.

## 🚀 Cómo levantarlo

### 1. Postgres (fuente)

```bash
cp .env.example .env        # completá tus valores
docker compose up -d
```

La primera vez carga Northwind en el esquema `public`. Para recrear todo: `docker compose down -v`.

### 2. dbt contra Postgres

```bash
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
cd project_dbt_transform && dbt deps
dbt build
```

La conexión va en `~/.dbt/profiles.yml` (fuera del repo), con un target `dev` para Postgres y otro `databricks`.

### 3. Databricks

1. Exportar las tablas de Postgres a CSV y subirlas al volume `northwind.bronze.raw_files`.
2. Correr [`ingestion/01_ingest_bronze.py`](ingestion/01_ingest_bronze.py) para crear bronze.
3. Construir silver y gold: `dbt build --target databricks`.

## 📊 Estado actual

- [x] Infraestructura local (Docker + Postgres)
- [x] Staging, intermediate y marts (star schema)
- [x] 71 tests de calidad en todas las capas
- [x] CI con GitHub Actions (`dbt build` en cada push)
- [x] Medallion en Databricks: bronze (PySpark), silver y gold (dbt)
- [x] Proyecto dbt portable Postgres ↔ Databricks
- [x] Tipado completo de todas las columnas en staging
- [x] Notebook de ingesta versionado en el repo
- [x] Orquestación con Databricks Jobs (ingesta → dbt)
- [x] Dashboard AI/BI y Genie sobre gold
