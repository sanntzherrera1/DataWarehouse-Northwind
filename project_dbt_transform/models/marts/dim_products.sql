-- trae categoría y proveedor para que las facts lleguen con un solo join.
select
    p.product_id,
    p.product_name,
    p.quantity_per_unit,
    p.unit_price,
    p.units_in_stock,
    p.units_on_order,
    p.reorder_level,
    p.is_discontinued,
    p.category_id,
    c.category_name,
    p.supplier_id,
    s.company_name as supplier_name,
    s.country      as supplier_country

from {{ ref('stg_products') }} as p
left join {{ ref('stg_categories') }} as c on p.category_id = c.category_id
left join {{ ref('stg_suppliers') }}  as s on p.supplier_id = s.supplier_id