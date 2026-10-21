select
    cast(product_id as int)             as product_id,
    product_name,
    cast(supplier_id as int)            as supplier_id,
    cast(category_id as int)            as category_id,
    quantity_per_unit,
    cast(unit_price as numeric(10,2))   as unit_price,
    cast(units_in_stock as int)         as units_in_stock,
    cast(units_on_order as int)         as units_on_order,
    cast(reorder_level as int)          as reorder_level,
    (cast(discontinued as int) = 1)     as is_discontinued

from {{ source('northwind','products') }}
