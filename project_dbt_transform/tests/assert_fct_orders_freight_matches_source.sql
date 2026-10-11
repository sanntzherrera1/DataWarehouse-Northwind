-- TEST: falla si el total de freight del modelo no coincide con el de la fuente
with fuente as (
    select sum(cast(freight as numeric(10,2))) as total
    from {{ source('northwind', 'orders') }}
),
modelo as (
    select sum(freight) as total
    from {{ ref('fct_orders') }}
)
select
    f.total as total_fuente,
    m.total as total_modelo
from fuente f, modelo m
where f.total <> m.total