# Northwind Data Warehouse (dbt + PostgreSQL)

Proyecto de transformación por capas del dataset Northwind con **dbt**, sobre **PostgreSQL** local levantado con **Docker**.

## 🎯 Objetivo

Convertir datos crudos de una base transaccional (ventas, clientes, productos) en un modelo limpio y testeado, capaz de responder preguntas reales de negocio.

## 🛠️ Stack

PostgreSQL (Docker) · dbt Core · DBeaver

## 🚀 Cómo levantarlo

```bash
docker-compose up -d
python -m venv venv && venv\Scripts\activate
pip install dbt-core dbt-postgres
cd project_dbt_transform
dbt run
```

## 📊 Estado actual

- [x] Infraestructura local (Docker + Postgres)
- [x] Staging: 8 modelos (customers, orders, order_details, products, employees, categories, suppliers, shippers)
- [ ] Marts (dimensiones y hechos)
- [ ] Tests de calidad
- [ ] Documentación dbt docs
- [ ] Migración a BigQuery
- [ ] Capa de IA (Text-to-SQL con Vertex AI)