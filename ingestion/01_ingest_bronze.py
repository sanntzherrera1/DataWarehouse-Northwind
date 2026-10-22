# Databricks notebook source
# DBTITLE 1,Listar archivos crudos

display(dbutils.fs.ls("/Volumes/northwind/bronze/raw_files/"))

# COMMAND ----------

# DBTITLE 1,Ingesta de CSV a bronze

# Lista los CSV del volume y carga cada uno como tabla Delta en bronze (todo string)
raw_path = "/Volumes/northwind/bronze/raw_files/"
csv_files = [f.name.replace(".csv", "") for f in dbutils.fs.ls(raw_path) if f.name.endswith(".csv")]

print(f"Se encontraron {len(csv_files)} archivos CSV: {csv_files}\n")

for file_name in csv_files:
    df = spark.read.csv(f"{raw_path}{file_name}.csv", header=True)
    df.write.mode("overwrite").saveAsTable(f"northwind.bronze.{file_name}")
    print(f"✓ {file_name}.csv → northwind.bronze.{file_name} ({df.count()} filas)")

# COMMAND ----------

# DBTITLE 1,Verificar tablas de bronze
# MAGIC %sql
# MAGIC SHOW TABLES IN northwind.bronze;
