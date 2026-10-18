select
    cast(order_id as int) as order_id,
    cast(product_id as int) as product_id,
    cast(unit_price as numeric(10,2)) as unit_price,
    cast(quantity as int) as quantity,
    cast(discount as numeric(3,2)) as discount

from {{ source('northwind','order_details') }}
