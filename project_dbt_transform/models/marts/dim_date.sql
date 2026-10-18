with days as (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('1996-01-01' as date)",
        end_date="cast('1999-01-01' as date)"
    ) }}

)

select
    cast(date_day as date)                        as date_day,
    cast(extract(year from date_day) as int)      as year,
    cast(extract(quarter from date_day) as int)   as quarter,
    cast(extract(month from date_day) as int)     as month,
    {{ month_name('date_day') }}                   as month_name,
    {{ day_of_week_iso('date_day') }}              as day_of_week,
    {{ day_of_week_iso('date_day') }} in (6, 7)   as is_weekend
from days
