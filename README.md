# Northwind Data Warehouse (dbt + PostgreSQL)
[![dbt ci](https://github.com/sanntzherrera1/DataWarehouse-Northwind/actions/workflows/dbt-ci.yml/badge.svg)](https://github.com/sanntzherrera1/DataWarehouse-Northwind/actions/workflows/dbt-ci.yml)

Pipeline ELT que transforma la base transaccional **Northwind** en un modelo dimensional (star schema) usando **dbt**, sobre **PostgreSQL** levantado con **Docker**.

## 🎯 Objetivo

Convertir datos crudos de una base transaccional (ventas, clientes, productos) en un modelo limpio y testeado, capaz de responder preguntas reales de negocio.

## 🛠️ Stack

PostgreSQL (Docker) · dbt Core · Python · GitHub Actions · DBeaver

## 🏗️ Arquitectura

**Actual (local):** fuente y warehouse conviven en el mismo Postgres. Northwind se carga solo al crear el contenedor.

```
db/northwind.sql ──> PostgreSQL (public) ──> dbt: staging ──> marts
   (carga automática        
    al iniciar Docker)
```

**Objetivo:** Postgres queda como sistema transaccional, separado del warehouse, con ingesta automatizada.

```
PostgreSQL (fuente) ──> Ingesta incremental (Python) ──> Cloud Storage
    ──> BigQuery ──> dbt: staging ──> marts ──> Vertex AI

Orquestado con Airflow
```

## 📐 Modelo de datos

- **Staging:** 8 vistas, una por tabla fuente, con limpieza y tipado.
- **Marts:** star schema con 6 dimensiones y 2 tablas de hechos.

| Tabla de hechos | Grain |
|---|---|
| `fct_orders` | Una fila por orden |
| `fct_order_lines` | Una fila por producto dentro de una orden |

## ✅ Calidad de datos

25 tests en total:
- 24 genéricos (`unique`, `not_null`, `relationships`) para validar la integridad del modelo.
- 1 test singular que reconcilia el total de `freight` entre la fuente y `fct_orders`, para detectar pérdida o duplicación de datos.

## 🔁 Integración continua

En cada push, GitHub Actions recrea el proyecto desde cero en una máquina limpia: levanta Postgres, carga Northwind y corre `dbt build` con todos los modelos y tests. Si algo se rompe, el badge se pone en rojo; así me aseguro de que el proyecto funciona fuera de mi PC y de que ningún cambio rompe lo que ya estaba validado.

Las credenciales no están en el código: el perfil de `ci/profiles.yml` las lee de variables de entorno.

## 🚀 Cómo levantarlo

1. Copiá `.env.example` a `.env` y completá tus valores.
2. Levantá la base:

```bash
docker-compose up -d
```

La primera vez, Postgres ejecuta automáticamente `db/northwind.sql` y deja Northwind cargado en el esquema `public` de la base definida en `POSTGRES_DB`.

> **Ojo:** la carga corre solo cuando el volumen está vacío. Para recrear todo desde cero: `docker-compose down -v` (borra los datos) y volver a levantar.

3. Conectate (por ejemplo desde DBeaver) a `localhost:5432` con los datos de tu `.env`. En el campo **Database** poné el valor de `POSTGRES_DB`, no la base `postgres` por defecto, que está vacía.
4. Instalá dbt y construí el modelo:

```bash
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
cd project_dbt_transform
dbt build
```

Requiere configurar la conexión en `~/.dbt/profiles.yml` con los mismos datos del `.env`.

## 📊 Estado actual

- [x] Infraestructura local (Docker + Postgres)
- [x] Carga automática de Northwind al levantar Docker
- [x] Staging: 8 modelos
- [x] Marts: 6 dimensiones + 2 tablas de hechos
- [x] Tests de calidad (25 tests)
- [x] CI con GitHub Actions (`dbt build` en cada push)
- [x] Documentación con dbt docs
- [ ] Ingesta incremental a Cloud Storage y BigQuery
- [ ] Orquestación con Airflow
- [ ] Capa de IA (Text-to-SQL con Vertex AI)