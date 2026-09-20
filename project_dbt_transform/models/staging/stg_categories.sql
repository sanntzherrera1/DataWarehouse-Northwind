select 
    category_id,
    category_name,
    description

from {{source('northwind','categories')}}