select
    cast(order_id as int)               as order_id,
    customer_id,
    cast(employee_id as int)            as employee_id,
    cast(order_date as date)            as order_date,
    cast(required_date as date)         as required_date,
    cast(shipped_date as date)          as shipped_date,
    cast(ship_via as int)               as shipper_id,
    cast(freight as numeric(10,2))      as freight,
    ship_name,
    ship_address,
    ship_city,
    ship_region,
    ship_postal_code,
    ship_country

from {{ source('northwind','orders') }}
