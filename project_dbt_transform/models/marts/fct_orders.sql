select 
    o.order_date,
    o.required_date,
    o.shipped_date,
    o.ship_via as shipper_id,
    o.freight,
    o.ship_country,
    od.unit_price,
    od.quantity,
    od.discount,
    od.order_id,
    o.customer_id,
    o.employee_id,
    od.product_id,
    -- Esta es una metrica: Total de la línea (Precio * Cantidad - Descuento)
    (od.unit_price * od.quantity * (1 - od.discount)) as total_line_amount

from {{ ref('stg_order_details') }} as od
left join {{ ref('stg_orders') }} as o on od.order_id = o.order_id