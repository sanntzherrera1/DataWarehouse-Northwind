# Northwind Data Warehouse (dbt + PostgreSQL)

Pipeline ELT que transforma la base transaccional **Northwind** en un modelo dimensional (star schema) usando **dbt**, sobre **PostgreSQL** levantado con **Docker**.

## 🎯 Objetivo

Convertir datos crudos de una base transaccional (ventas, clientes, productos) en un modelo limpio y testeado, capaz de responder preguntas reales de negocio.

## 🛠️ Stack

PostgreSQL (Docker) · dbt Core · Python · DBeaver

## 🏗️ Arquitectura

**Actual (local):** fuente y warehouse conviven en el mismo Postgres.

```
northwind.sql ──> PostgreSQL (public) ──> dbt: staging ──> marts
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

La integridad se valida con 24 tests (`unique`, `not_null`, `relationships`).

## 🚀 Cómo levantarlo

```bash
docker-compose up -d
# Cargar northwind.sql en la base (por ahora, manual)
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
cd project_dbt_transform
dbt build
```

Requiere configurar la conexión en `~/.dbt/profiles.yml`.

## 📊 Estado actual

- [x] Infraestructura local (Docker + Postgres)
- [x] Staging: 8 modelos
- [x] Marts: 6 dimensiones + 2 tablas de hechos
- [x] Tests de calidad (24 tests)
- [x] Documentación con dbt docs
- [ ] Carga automática de Northwind al levantar Docker
- [ ] Ingesta incremental a Cloud Storage y BigQuery
- [ ] Orquestación con Airflow
- [ ] Capa de IA (Text-to-SQL con Vertex AI)