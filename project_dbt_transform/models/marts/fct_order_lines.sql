select
    ol.order_id,
    ol.product_id,
    ol.order_date,
    ol.customer_id,
    ol.employee_id,
    ol.shipper_id,
    ol.unit_price,
    ol.quantity,
    ol.discount,
    ol.total_line_amount

from {{ ref('int_order_lines_enriched') }} as ol