select 
    od.order_id,
    od.unit_price,
    od.quantity,
    od.discount,
    od.product_id,
    o.order_date,
    o.customer_id,
    o.employee_id,
    o.shipper_id,
    -- Total de la línea con descuento aplicado
    (od.unit_price * od.quantity * (1 - od.discount)) as total_line_amount

from {{ ref('stg_order_details') }} as od
left join {{ ref('stg_orders') }} as o on od.order_id = o.order_id