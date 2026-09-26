select 
    c.category_id,
    c.category_name,
    c.description

from {{ref('stg_categories')}} as c