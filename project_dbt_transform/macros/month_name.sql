{% macro month_name(col) %}
  {% if target.type == 'databricks' %}
    date_format({{ col }}, 'MMMM')
  {% else %}
    trim(to_char({{ col }}, 'Month'))
  {% endif %}
{% endmacro %}
