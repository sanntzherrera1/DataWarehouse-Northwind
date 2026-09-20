select 
    shipper_id,
    company_name,
    phone
from {{source('northwind','shippers')}}