select 
    s.supplier_id,
    s.company_name,
    s.contact_name,
    s.contact_title,
    s.address,
    s.city,
    s.region,
    s.postal_code,
    s.country,
    s.phone,
    s.fax,
    s.homepage
from {{ref('stg_suppliers')}} as s
