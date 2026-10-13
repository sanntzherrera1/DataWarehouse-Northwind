select
    od.order_id,
    od.product_id,
    o.order_date,
    o.customer_id,
    o.employee_id,
    o.shipper_id,
    pr.product_name,
    pr.category_id,
    pr.supplier_id,
    od.unit_price,
    od.quantity,
    od.discount,
    -- Monto de la línea con descuento aplicado 
    (od.unit_price * od.quantity * (1 - od.discount)) as total_line_amount

from {{ ref('stg_order_details') }} as od
left join {{ ref('stg_orders') }} as o on od.order_id = o.order_id
left join {{ ref('stg_products') }} as pr on od.product_id = pr.product_id