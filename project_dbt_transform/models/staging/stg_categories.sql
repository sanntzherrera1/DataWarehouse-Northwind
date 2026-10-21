select
    cast(category_id as int)            as category_id,
    category_name,
    description

from {{ source('northwind','categories') }}
