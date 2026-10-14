-- Calendario: una fila por día, de 1996-01-01 a 1998-12-31.
-- Cubre todas las fechas de orders. Se generan todos los días, haya ventas o no.
with days as (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('1996-01-01' as date)",
        end_date="cast('1999-01-01' as date)"
    ) }}

)

select
    cast(date_day as date)                   as date_day,
    extract(year from date_day)::int         as year,
    extract(quarter from date_day)::int      as quarter,
    extract(month from date_day)::int        as month,
    trim(to_char(date_day, 'Month'))         as month_name,
    extract(isodow from date_day)::int       as day_of_week,   -- 1 = lunes ... 7 = domingo
    extract(isodow from date_day) in (6, 7)  as is_weekend
from days