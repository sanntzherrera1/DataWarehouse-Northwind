{% macro day_of_week_iso(col) %}
  {% if target.type == 'databricks' %}
    cast(extract(DAYOFWEEK_ISO FROM {{ col }}) as int)
  {% else %}
    cast(extract(isodow FROM {{ col }}) as int)
  {% endif %}
{% endmacro %}
