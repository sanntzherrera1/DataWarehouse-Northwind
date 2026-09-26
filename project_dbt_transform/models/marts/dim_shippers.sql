select 
    shipper_id,
    company_name,
    phone
from {{ref('stg_shippers')}}