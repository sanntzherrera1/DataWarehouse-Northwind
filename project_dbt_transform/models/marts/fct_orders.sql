select 
    o.order_id,
    o.order_date,
    o.required_date,
    o.shipped_date,
    o.shipper_id,
    o.freight,
    o.ship_country,
    o.customer_id,
    o.employee_id,
    {{ dbt.datediff("o.order_date", "o.shipped_date", "day") }} as days_to_ship

from {{ ref('stg_orders') }} as o  
