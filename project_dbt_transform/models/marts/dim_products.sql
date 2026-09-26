select 
    p.product_id,
    p.product_name,
    p.supplier_id,
    p.category_id,
    c.category_name,
    p.quantity_per_unit,
    p.unit_price,
    p.units_in_stock,
    p.units_on_order,
    p.reorder_level,
    p.is_discontinued

from {{ref('stg_products')}} as p
left join {{ref('stg_categories')}} as c on p.category_id = c.category_id
