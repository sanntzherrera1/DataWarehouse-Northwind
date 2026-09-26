
select
    e.employee_id,
    e.first_name,
    e.last_name,
    e.title,
    e.title_of_courtesy,
    e.birth_date,
    e.hire_date,
    e.address,
    e.city,
    e.region,
    e.postal_code,
    e.country,
    e.home_phone,
    e.extension,
    e.notes,
    e.reports_to,
    em.first_name || ' ' || em.last_name as supervisor_name
from {{ ref('stg_employees') }} as e
left join {{ ref('stg_employees') }} as em on e.reports_to = em.employee_id