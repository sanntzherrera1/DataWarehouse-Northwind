with order_totals as (

    select order_id,sum(total_line_amount) as order_total,count(*) as line_count
    from {{ ref('int_order_lines_enriched') }}
    group by order_id

)

select
    o.order_id,
    o.order_date,
    o.required_date,
    o.shipped_date,
    o.shipper_id,
    o.customer_id,
    o.employee_id,
    o.ship_country,
    o.freight,
    ot.order_total,
    ot.line_count,
    {{ dbt.datediff("o.order_date", "o.shipped_date", "day") }} as days_to_ship

from {{ ref('stg_orders') }} as o
left join order_totals as ot on o.order_id = ot.order_id