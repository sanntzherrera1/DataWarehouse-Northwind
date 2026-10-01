-- TEST: Da error si el costo del envio no coincide con el de la fuente
with fuente as (
    select sum(freight) as total
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
where abs(f.total - m.total) > 0.01