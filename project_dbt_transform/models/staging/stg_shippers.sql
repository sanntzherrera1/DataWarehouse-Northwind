select
    cast(shipper_id as int)             as shipper_id,
    company_name,
    phone

from {{ source('northwind','shippers') }}
