-- TEST: falla si la suma de order_total en fct_orders no coincide
-- con la suma de total_line_amount en fct_order_lines
with lineas as (
    select sum(total_line_amount) as total
    from {{ ref('fct_order_lines') }}
),
ordenes as (
    select sum(order_total) as total
    from {{ ref('fct_orders') }}
)
select
    l.total as total_lineas,
    o.total as total_ordenes
from lineas l, ordenes o
where l.total is distinct fro  m o.total 