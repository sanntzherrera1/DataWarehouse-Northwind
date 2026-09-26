select
    cst.customer_id,
    cst.company_name,
    cst.contact_name,
    cst.contact_title,
    cst.address,
    cst.city,
    cst.region,
    cst.postal_code,
    cst.country,
    cst.phone,
    cst.fax
from {{ ref('stg_customers') }} as cst